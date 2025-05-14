from fastapi import FastAPI, Query
from pydantic import BaseModel
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
import random

app = FastAPI(title="API de Recomendação de Produtos de Beleza")

# Dados
produtos = [
    {
        "id": '1', 
        "nome": "Shampoo Hidratante", 
        "marca": "Marca A", 
        "imagem": "assets/shampoo-hidratante.png", 
        "preco": '29.99', 
        "categoria": "Cabelos", 
        "descricao": "Shampoo hidratante para cabelos secos e danificados, promovendo brilho e maciez.", 
        "avaliacoes": '4.5', 
        "sexo": "neutro", 
        "infantil": "não"
    },
    {
        "id": '2', 
        "nome": "Creme Hidratante Corporal", 
        "marca": "Marca B", 
        "imagem": "assets/creme-hidratante.png", 
        "preco": '49.90', 
        "categoria": "Corpo", 
        "descricao": "Creme hidratante corporal com fórmula enriquecida para pele extra-seca.", 
        "avaliacoes": '4.8', 
        "sexo": "feminino", 
        "infantil": "não"
    },
    {
        "id": '3', 
        "nome": "Protetor Solar FPS 50", 
        "marca": "Marca C", 
        "imagem": "assets/protetor-50.png", 
        "preco": '59.90', 
        "categoria": "Rosto", 
        "descricao": "Protetor solar para o rosto com alta proteção contra raios UVA e UVB.", 
        "avaliacoes": '4.7', 
        "sexo": "neutro", 
        "infantil": "não"
    },
    {
        "id": '4', 
        "nome": "Shampoo Baby", 
        "marca": "Marca D", 
        "imagem": "assets/shampoo-baby.png", 
        "preco": '19.90', 
        "categoria": "Cabelos", 
        "descricao": "Shampoo para bebês, suave e sem lágrimas, ideal para peles sensíveis.", 
        "avaliacoes": '4.9', 
        "sexo": "neutro", 
        "infantil": "sim"
    },
    {
        "id": '5', 
        "nome": "Perfume Floral", 
        "marca": "Marca E", 
        "imagem": "assets/perfume-floral.png", 
        "preco": '139.90', 
        "categoria": "Perfumes", 
        "descricao": "Perfume floral com notas de rosas e jasmins, ideal para o dia a dia.", 
        "avaliacoes": '4.3', 
        "sexo": "feminino", 
        "infantil": "não"
    },
    {
        "id": '6', 
        "nome": "Desodorante Masculino", 
        "marca": "Marca F", 
        "imagem": "assets/desodorante-masc.png", 
        "preco": '29.90', 
        "categoria": "Higiene Pessoal", 
        "descricao": "Desodorante com fragrância masculina de longa duração e proteção contra suor.", 
        "avaliacoes": '4.6', 
        "sexo": "masculino", 
        "infantil": "não"
    }
]

df = pd.DataFrame(produtos)

# Pré-processamento
le = LabelEncoder()
df['sexo_encoded'] = le.fit_transform(df['sexo'])
df['infantil_encoded'] = df['infantil'].map({'não': 0, 'sim': 1})
df['categoria_encoded'] = le.fit_transform(df['categoria'])
df['avaliacoes'] = pd.to_numeric(df['avaliacoes'])
df['preco'] = pd.to_numeric(df['preco'])

X = df[['preco', 'avaliacoes', 'sexo_encoded', 'infantil_encoded']]
y = df['categoria_encoded']

# Modelos
dt_model = DecisionTreeClassifier(random_state=42)
rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
dt_model.fit(X, y)
rf_model.fit(X, y)

# Heurística de gênero
def recomendacao_heuristica_genero(sexo):
    if sexo == 'feminino':
        return "Perfumes, Corpo"
    elif sexo == 'masculino':
        return "Higiene Pessoal"
    else:
        return "Qualquer categoria"

# Recomendação aleatória baseada em preço
def recomendacao_aleatoria_preco(preco_max):
    produtos_baratos = df[df['preco'] <= preco_max]
    if produtos_baratos.empty:
        return None
    return random.choice(produtos_baratos['nome'].tolist())

# Request schema
class RequisicaoRecomendacao(BaseModel):
    sexo: str
    preco_max: float

@app.post("/recomendar")
def recomendar_produto(dados: RequisicaoRecomendacao):
    sexo = dados.sexo.lower()
    preco_max = dados.preco_max

    if sexo not in ['masculino', 'feminino', 'neutro']:
        return {"erro": "Sexo inválido. Use masculino, feminino ou neutro."}

    recomendacao_genero = recomendacao_heuristica_genero(sexo)
    produto_preco = recomendacao_aleatoria_preco(preco_max)

    if produto_preco is None:
        produto_preco = "Nenhum produto encontrado nesse valor."

    return {
        "genero": sexo,
        "recomendacao_por_genero": recomendacao_genero,
        "recomendacao_por_preco": produto_preco
    }
