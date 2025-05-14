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
    categoria: Optional[str] = None

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
