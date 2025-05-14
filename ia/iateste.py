from typing import Optional, List
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
import pandas as pd
import json
import os

app = FastAPI(title="API de Recomendação de Produtos de Beleza")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Você pode restringir para apenas o IP do app Flutter
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Carregar dados
BASE_DIR = os.path.dirname(__file__)
DATA_PATH = os.path.join(BASE_DIR, '..', 'assets', 'data', 'cosmeticos.json')

with open(DATA_PATH, 'r', encoding='utf-8') as f:
    produtos = json.load(f)

df = pd.DataFrame(produtos)

# Pré-processamento
le_categoria = LabelEncoder()
le_sexo = LabelEncoder()

df['sexo_encoded'] = le_sexo.fit_transform(df['sexo'])
df['infantil_encoded'] = df['infantil'].map({'não': 0, 'sim': 1})
df['categoria_encoded'] = le_categoria.fit_transform(df['categorias'])
df['avaliacoes'] = pd.to_numeric(df['avaliacao'], errors='coerce')
df['preco'] = pd.to_numeric(df['preco'], errors='coerce')

X = df[['preco', 'avaliacoes', 'sexo_encoded', 'infantil_encoded']]
y = df['categoria_encoded']

# Treinando o modelo
rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
rf_model.fit(X, y)

# Schema para entrada do usuário
class PerfilUsuario(BaseModel):
    preco_medio: float
    avaliacao_minima: float
    sexo: str
    infantil: bool

@app.post("/recomendar_por_perfil")
def recomendar_por_perfil(perfil: PerfilUsuario):
    # Codificar entrada do usuário
    sexo_encoded = le_sexo.transform([perfil.sexo.lower()])[0]
    infantil_encoded = 1 if perfil.infantil else 0

    # Preparar entrada para o modelo
    entrada_usuario = [[
        perfil.preco_medio,
        perfil.avaliacao_minima,
        sexo_encoded,
        infantil_encoded
    ]]

    # Prever categoria mais provável
    categoria_prevista_encoded = rf_model.predict(entrada_usuario)[0]
    categoria_prevista = le_categoria.inverse_transform([categoria_prevista_encoded])[0]

    # Filtrar produtos dessa categoria
    df_recomendados = df[df['categorias'] == categoria_prevista]

    # Filtrar por preço e avaliação
    df_recomendados = df_recomendados[
        (df_recomendados['preco'] <= perfil.preco_medio) &
        (df_recomendados['avaliacoes'] >= perfil.avaliacao_minima)
    ]

    # Embaralhar e retornar até 10 produtos
    recomendados = df_recomendados.sample(frac=1).head(10)[['nome', 'preco', 'avaliacoes', 'categorias']].to_dict(orient='records')

    return {
        "categoria_prevista": categoria_prevista,
        "produtos_recomendados": recomendados
    }

# Endpoint antigo mantido
class RequisicaoFiltro(BaseModel):
    preco_max: Optional[float]
    avaliacao_max: Optional[float]
    categoria: Optional[str]
    sexo: Optional[str]
    infantil: Optional[bool]

@app.post("/recomendar_produtos")
def recomendar_produtos(filtros: RequisicaoFiltro):
    df_filtrado = df.copy()

    if filtros.preco_max is not None:
        df_filtrado = df_filtrado[df_filtrado['preco'] <= filtros.preco_max]

    if filtros.avaliacao_max is not None:
        df_filtrado = df_filtrado[df_filtrado['avaliacao'] <= filtros.avaliacao_max]

    if filtros.categoria:
        df_filtrado = df_filtrado[df_filtrado['categorias'].str.lower() == filtros.categoria.lower()]

    if filtros.sexo:
        df_filtrado = df_filtrado[df_filtrado['sexo'].str.lower() == filtros.sexo.lower()]

    if filtros.infantil is not None:
        df_filtrado = df_filtrado[df_filtrado['infantil'] == ('sim' if filtros.infantil else 'não')]

    resultados = df_filtrado[['nome', 'preco', 'avaliacoes', 'categorias']].head(10).to_dict(orient='records')

    return {"produtos": resultados}