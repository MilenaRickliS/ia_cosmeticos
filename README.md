# 💄 API de Recomendação de Cosméticos com IA

Esta é uma API desenvolvida com **FastAPI** que recomenda produtos cosméticos com base nas preferências do usuário. A recomendação é feita por meio de um modelo de **machine learning (Random Forest)** treinado com dados reais de um catálogo de produtos.

## 🔍 Funcionalidades

- Recebe filtros personalizados do usuário:
  - ✅ Categoria
  - 💰 Preço máximo
  - ⭐ Avaliação mínima
  - 🚻 Sexo (masculino/feminino/neutro)
  - 👶 Produto infantil (sim/não)
- Realiza recomendações inteligentes com base nos filtros informados.
- Treina um modelo de classificação com dados de um catálogo JSON.

## 🧠 Modelo de Recomendação

O modelo de **Random Forest** é treinado utilizando os seguintes atributos do produto:

- Categoria
- Preço
- Avaliação
- Sexo
- Produto Infantil (Sim/Não)

A recomendação retorna os produtos mais adequados ao perfil informado, respeitando os filtros aplicados.

## 📊 Avaliação do Modelo

A API disponibiliza endpoints dedicados à **avaliação do modelo de recomendação** com base em métricas padrão de classificação (precisão, recall, F1-score e acurácia), além de comparações com diferentes **modelos baseline**.

### 🔹 1. Avaliação do modelo Random Forest

- **Endpoint:** `GET /avaliar_modelo`  
- **Descrição:** Avalia o modelo Random Forest treinado usando os dados de teste. Retorna métricas de desempenho e gera uma matriz de confusão em formato gráfico.

📈 Gráfico da matriz de confusão:  
`http://localhost:8000/grafico_matriz`


### 🔸 2. Baselines para Comparação

#### a) Baseline Aleatória

- **Endpoint:** `GET /avaliar_baseline_aleatoria`  
- **Descrição:** Gera previsões aleatórias com igual probabilidade entre as classes. Serve como referência de desempenho.

📈 Gráfico da matriz:  
`http://localhost:8000/grafico_matriz_baseline`


#### b) Baseline Moda (classe majoritária)

- **Endpoint:** `GET /avaliar_baseline_moda`  
- **Descrição:** Utiliza como previsão a classe mais frequente do conjunto de treino para todas as amostras do teste.

📈 Gráfico da matriz:  
`http://localhost:8000/grafico_matriz_baseline_moda`


#### c) Baseline Distribuição de Classes

- **Endpoint:** `GET /avaliar_baseline_distribuicao`  
- **Descrição:** Gera previsões aleatórias de acordo com a distribuição de classes observada no treino.

📈 Gráfico da matriz:  
`http://localhost:8000/grafico_matriz_baseline_distribuicao`


### 📐 Métricas Retornadas

Cada avaliação retorna as seguintes métricas:

- `acuracia`: Percentual de acertos gerais.
- `precisao_macro`: Precisão média entre todas as classes.
- `recall_macro`: Recall médio entre todas as classes.
- `f1_macro`: F1-score médio entre todas as classes.

Essas métricas permitem comparar o desempenho real do modelo com estratégias simples, garantindo que a IA esteja de fato aprendendo padrões úteis com os dados.


## 📁 Estrutura do Projeto

```
├── ai/iateste.py                     # AI FastAPI com as rotas de recomendação
├── assets/data/cosmeticos.json       # Catálogo de produtos cosméticos (dados de treino)
├── assets/imagens                    # Imagens dos produtos cosméticos 
├── assets/produtos/cosmeticos1.json  # Catálogo de produtos cosméticos (para carregamento no flutter)
├── lib/model/produto.dart            # Modelo de dados do produto no Flutter
├── lib/main.dart                     # Tela inicial do aplicativo Flutter
├── lib/detalhes.dart                 # Tela que mostra detalhes dos produtos
├── lib/favoritos.dart                # Tela que mostra os produtos favoritados
├── lib/escolha.dart                  # Tela de início da recomendação
├── lib/filtro.dart                   # Tela de filtros personalizados
├── lib/resultado.dart                # Tela de exibição dos resultados da recomendação
├── lib/detalhes_recomendados.dart    # Tela de detalhes dos produtos recomendados
```

## 🚀 Como Executar o Projeto

### 🔧 Backend (FastAPI)

1. Clone o repositório:

```bash
git https://github.com/MilenaRickliS/ia_cosmeticos.git
```

2. Crie o ambiente virtual e instale as dependências:

```bash
cd ia
python -m venv venv
source venv/bin/activate  # ou venv\Scripts\activate no Windows
pip install -r requirements.txt
```

3. Execute a API:

```bash
uvicorn iateste:app --reload --host 0.0.0.0
```

### 📱 Frontend (Flutter)

1. Vá para o diretório do app Flutter:

```bash
cd lib
flutter pub get
flutter run
```

2. Atualize IP na página filtro.dart:

```bash
final uri = Uri.parse('http://<SEUIPAQUI>>:8000/recomendar_por_perfil');
```


## 📡 Exemplo de Requisição

```http
POST /recomendar
Content-Type: application/json

{
  "categoria": "perfume",
  "preco_max": 100.0,
  "avaliacao_min": 4.0,
  "sexo": "feminino",
  "infantil": false
}
```

## 🛠 Tecnologias Utilizadas

- [Python](https://www.python.org/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [scikit-learn](https://scikit-learn.org/)
- [pandas](https://pandas.pydata.org/)
- [Flutter](https://flutter.dev/)
- [uvicorn](https://www.uvicorn.org/)

## 👩‍💻 Desenvolvedora

**Milena Rickli Silvério Kriger**  
🔗 [GitHub - MilenaRickliS](https://github.com/MilenaRickliS)

---

© 2025 - Projeto de Recomendação de Cosméticos com Inteligência Artificial