# uvicorn iateste:app --reload --host 0.0.0.0
#pip install -r requirements.txt

from typing import Optional, List
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split, GridSearchCV
import pandas as pd
import numpy as np
from numpy import unique
import matplotlib.pyplot as plt
import seaborn as sns
import json
import os

app = FastAPI(title="API de Recomendação de Produtos de Beleza")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Carregar dados
BASE_DIR = os.path.dirname(__file__)
DATA_PATH = os.path.join(BASE_DIR, '..', 'assets', 'data', 'cosmeticos.json')
PLOT_PATH = os.path.join(BASE_DIR, "matriz_confusao.png") 
BASELINE_PLOT_PATH = os.path.join(BASE_DIR, "matriz_confusao_baseline.png")

with open(DATA_PATH, 'r', encoding='utf-8') as f:
    produtos = json.load(f)

df = pd.DataFrame(produtos)

# Pré-processamento
le_categoria = LabelEncoder()
le_sexo = LabelEncoder()

df['sexo_encoded'] = le_sexo.fit_transform(df['sexo'])
df['infantil_encoded'] = df['infantil'].astype(int)
df['categoria_encoded'] = le_categoria.fit_transform(df['categorias'])
df['avaliacoes'] = pd.to_numeric(df['avaliacao'], errors='coerce')
df['preco'] = pd.to_numeric(df['preco'], errors='coerce')
df['faixa_preco'] = pd.cut(df['preco'], bins=[0, 50, 100, 200, 500, 10000], labels=False)
df['faixa_avaliacao'] = pd.cut(df['avaliacoes'], bins=[0, 2, 3, 4, 4.5, 5], labels=False)

X = df[['preco', 'avaliacoes', 'sexo_encoded', 'infantil_encoded', 'faixa_preco', 'faixa_avaliacao']]
y = df['categoria_encoded']

# Separar treino/teste
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# GridSearchCV com RandomForest balanceado
params = {
    'n_estimators': [100, 200],
    'max_depth': [None, 10, 20],
    'min_samples_split': [2, 5]
}
grid = GridSearchCV(RandomForestClassifier(class_weight='balanced', random_state=42), param_grid=params, cv=5)
grid.fit(X_train, y_train)

rf_model = grid.best_estimator_

# Schema
class PerfilUsuario(BaseModel):
    preco_medio: float
    avaliacao_minima: float
    sexo: str
    infantil: bool
    categoria: str

# Endpoint de recomendação por perfil
@app.post("/recomendar_por_perfil")
def recomendar_por_perfil(perfil: PerfilUsuario):
    sexo_encoded = le_sexo.transform([perfil.sexo.lower()])[0]
    infantil_encoded = 1 if perfil.infantil else 0

    if perfil.categoria:
        categoria_prevista = perfil.categoria
    else:
        entrada_usuario = [[
            perfil.preco_medio,
            perfil.avaliacao_minima,
            sexo_encoded,
            infantil_encoded,
            pd.cut([perfil.preco_medio], bins=[0, 50, 100, 200, 500, 10000], labels=False)[0],
            pd.cut([perfil.avaliacao_minima], bins=[0, 2, 3, 4, 4.5, 5], labels=False)[0]
        ]]
        categoria_prevista_encoded = rf_model.predict(entrada_usuario)[0]
        categoria_prevista = le_categoria.inverse_transform([categoria_prevista_encoded])[0]

    df_recomendados = df[df['categorias'] == categoria_prevista]
    df_recomendados = df_recomendados[
        (df_recomendados['preco'] <= perfil.preco_medio) &
        (df_recomendados['avaliacoes'] >= perfil.avaliacao_minima) &
        (df_recomendados['sexo'] == perfil.sexo.lower()) &
        (df_recomendados['infantil'] == perfil.infantil)
    ]

    recomendados = df_recomendados.sample(frac=1).head(10)[
        ['id', 'nome', 'preco', 'marca', 'imagem', 'descricao', 'avaliacoes', 'categorias', 'sexo', 'infantil']
    ].to_dict(orient='records')

    return {
        "categoria_prevista": categoria_prevista,
        "produtos_recomendados": recomendados
    }

# Avaliar modelo
@app.get("/avaliar_modelo")
def avaliar_modelo():
    y_pred = rf_model.predict(X_test)
    report = classification_report(y_test, y_pred, target_names=le_categoria.classes_, output_dict=True)
    matrix = confusion_matrix(y_test, y_pred)

    # Gráfico da matriz de confusão
    plt.figure(figsize=(10, 8))
    sns.heatmap(matrix, annot=True, fmt='d', xticklabels=le_categoria.classes_, yticklabels=le_categoria.classes_, cmap="Purples")
    plt.xlabel('Predito')
    plt.ylabel('Real')
    plt.title('Matriz de Confusão - RandomForest')
    plt.tight_layout()
    plt.savefig(PLOT_PATH)
    plt.close()

    return {
        "acuracia": report['accuracy'],
        "precisao_macro": report['macro avg']['precision'],
        "recall_macro": report['macro avg']['recall'],
        "f1_macro": report['macro avg']['f1-score'],
        "grafico_matriz_confusao": "http://localhost:8000/grafico_matriz"
    }

# Retorna gráfico salvo
@app.get("/grafico_matriz")
def get_grafico_matriz():
    return FileResponse(path=PLOT_PATH, media_type='image/png', filename="matriz_confusao.png")


@app.get("/avaliar_baseline_aleatoria")
def avaliar_baseline_aleatoria():
    classes_possiveis = list(le_categoria.classes_)
    n_classes = len(classes_possiveis)

    np.random.seed(42)
    y_pred_aleatorio = np.random.choice(n_classes, size=len(y_test))

    classes_presentes = np.unique(y_test)

    report = classification_report(y_test, y_pred_aleatorio, labels=classes_presentes, target_names=[classes_possiveis[i] for i in classes_presentes], output_dict=True)
    matrix = confusion_matrix(y_test, y_pred_aleatorio, labels=classes_presentes)

    # Plot da matriz de confusão da baseline
    plt.figure(figsize=(10, 8))
    sns.heatmap(matrix, annot=True, fmt='d', xticklabels=[classes_possiveis[i] for i in classes_presentes],   yticklabels=[classes_possiveis[i] for i in classes_presentes], cmap="Oranges")
    plt.xlabel('Predito')
    plt.ylabel('Real')
    plt.title('Matriz de Confusão - Baseline Aleatória')
    plt.tight_layout()
    plt.savefig(BASELINE_PLOT_PATH)
    plt.close()

    return {
        "acuracia": report['accuracy'],
        "precisao_macro": report['macro avg']['precision'],
        "recall_macro": report['macro avg']['recall'],
        "f1_macro": report['macro avg']['f1-score'],
        "grafico_matriz_confusao_baseline": "http://localhost:8000/grafico_matriz_baseline"
    }

@app.get("/grafico_matriz_baseline")
def get_grafico_matriz_baseline():
    if not os.path.exists(BASELINE_PLOT_PATH):
        return {"error": "Arquivo não encontrado."}
    return FileResponse(BASELINE_PLOT_PATH, media_type="image/png")

@app.get("/avaliar_baseline_moda")
def avaliar_baseline_moda():
    # Descobrir a classe mais frequente no conjunto de treino
    classe_mais_frequente = y_train.mode()[0]

    # Criar vetor de previsões com essa classe para todo o conjunto de teste
    y_pred_moda = np.full_like(y_test, fill_value=classe_mais_frequente)

    # Agora que y_pred_moda existe, podemos concatenar
    labels_presentes = np.unique(np.concatenate((y_test, y_pred_moda)))

    report = classification_report(
        y_test, y_pred_moda,
        labels=labels_presentes,
        target_names=le_categoria.inverse_transform(labels_presentes),
        zero_division=0,
        output_dict=True
    )
    matrix = confusion_matrix(y_test, y_pred_moda)

    # Gráfico matriz confusão
    plt.figure(figsize=(10, 8))
    sns.heatmap(matrix, annot=True, fmt='d', xticklabels=le_categoria.classes_, yticklabels=le_categoria.classes_, cmap="Blues")
    plt.xlabel('Predito')
    plt.ylabel('Real')
    plt.title('Matriz de Confusão - Baseline Moda (classe majoritária)')
    plt.tight_layout()
    plt.savefig("matriz_confusao_baseline_moda.png")
    plt.close()

    return {
        "acuracia": report['accuracy'],
        "precisao_macro": report['macro avg']['precision'],
        "recall_macro": report['macro avg']['recall'],
        "f1_macro": report['macro avg']['f1-score'],
        "grafico_matriz_confusao_baseline_moda": "http://localhost:8000/grafico_matriz_baseline_moda"
    }


@app.get("/grafico_matriz_baseline_moda")
def get_grafico_matriz_baseline_moda():
    path = "matriz_confusao_baseline_moda.png"
    if not os.path.exists(path):
        return {"error": "Arquivo não encontrado."}
    return FileResponse(path, media_type="image/png")


@app.get("/avaliar_baseline_distribuicao")
def avaliar_baseline_distribuicao():
    # Frequência das classes no treino
    freq_classes = y_train.value_counts(normalize=True).sort_index()

    # Gerar previsões aleatórias baseadas na distribuição das classes
    np.random.seed(42)
    y_pred_distribuicao = np.random.choice(freq_classes.index, size=len(y_test), p=freq_classes.values)

    report = classification_report(y_test, y_pred_distribuicao, target_names=le_categoria.classes_, output_dict=True)
    matrix = confusion_matrix(y_test, y_pred_distribuicao)

    # Gráfico matriz confusão (opcional)
    plt.figure(figsize=(10, 8))
    sns.heatmap(matrix, annot=True, fmt='d', xticklabels=le_categoria.classes_, yticklabels=le_categoria.classes_, cmap="Greens")
    plt.xlabel('Predito')
    plt.ylabel('Real')
    plt.title('Matriz de Confusão - Baseline Distribuição de Classes')
    plt.tight_layout()
    plt.savefig("matriz_confusao_baseline_distribuicao.png")
    plt.close()

    return {
        "acuracia": report['accuracy'],
        "precisao_macro": report['macro avg']['precision'],
        "recall_macro": report['macro avg']['recall'],
        "f1_macro": report['macro avg']['f1-score'],
        "grafico_matriz_confusao_baseline_distribuicao": "http://localhost:8000/grafico_matriz_baseline_distribuicao"
    }

@app.get("/grafico_matriz_baseline_distribuicao")
def get_grafico_matriz_baseline_distribuicao():
    path = "matriz_confusao_baseline_distribuicao.png"
    if not os.path.exists(path):
        return {"error": "Arquivo não encontrado."}
    return FileResponse(path, media_type="image/png")

