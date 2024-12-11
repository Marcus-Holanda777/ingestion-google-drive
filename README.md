# Ingestão de Dados a partir de planilhas do Google Drive em ambiente Cloud (GCP) - Camada RAW

O objetivo deste projeto é desenvolver uma automação que colete dados estáticos e dinâmicos de um Google Drive (simulando um cenário muito comum de empresas de pequeno - médio porte) e armazene esses dados em uma camada raw, visando uma evolução para aspectos analíticos (será explorado nos futuros projetos). 

Imagine o cenário de um formulário de pesquisa de mercado que contém as seguintes perguntas:
- Estado em que vive (Campo de Seleção Única)
- Cidade em que vive (Campo de Texto)
- Cargo atual (Campo de Seleção única com opções: Desenvolvedor Web, Desenvolvedor Mobile, Cientista de Dados, Analista de Dados, Engenheiro de Dados, Devops, Outro)
- Por onde adquire novos conhecimentos? (Campo de seleção múltipla com opções: Livros, Cursos Online, Artigos (Medium, Dev.to), Formações Universitárias (Graduação, Mestrado, Doutorado, MBA), Vídeos no Youtube, Eventos)
- Quais ferramentas utiliza hoje? (Campo de Seleçao múltipla: Python, Java, Rust, C#, Elixir, R, SQL, Google Cloud, Amazon Web Services, Azure, Databricks, Apache Spark, Apache Nifi, Apache Airbyte, Apache Airflow, Apache Kafka)

Esse formulário ficará aberto durante um mês, tendo ciclos de abertura e fechamento ao longo do ano. Ou seja, não será algo pontual e único. O objetivo é quando uma resposta for feita no formulário um gatilho seja feito e ocorra a ingestão dos dados para um bucket no Cloud Storage.

Será utilizado Cloud Run como local de execução do código para a realização de ingestão de dados, que será desenvolvido em Python, seguindo os princípios da programação orientada a objetos (POO) e as melhores práticas de programação.

O gatilho de execução será configurado por meio do App Script, se integrando com o Google Forms + Google Sheets. O Cloud Run será provisionado via Terraform, combinado com Cloud Build e repositório do GitHub. Ou seja, toda vez que um commit for aplicado na branch main;master, deverá ser feito uma implantação, replicando a lógica.

## Tecnologias Utilizadas
- Python: Linguagem de programação utilizada para o desenvolvimento da pipeline.
- Cloud Run: O ambiente na nuvem que executará o código Python, fornecendo escalabilidade e flexibilidade.
- Cloud Storage: Um ambiente na nuvem que permitirá armazenar os arquivos JSON, incluindo as respostas da API de forma segura e escalável.
- App Scripts: O Apps Script é uma plataforma JavaScript baseada na nuvem com a tecnologia do Google Drive que permite a integração e automação de tarefas nos produtos do Google.
- Terraform: Uma ferramenta que possibilita a provisionamento eficiente de toda a infraestrutura necessária, seguindo a metodologia de infraestrutura como código (IaC).
- Cloud Build: O Cloud Build executa sua compilação como uma série de etapas de compilação, em que cada etapa de compilação é executada em um contêiner Docker. A execução das etapas de construção é análoga à execução de comandos em um script.

## Arquitetura
![Arquitetura do projeto que será construído](imgs/arquitetura_ingestao_forms_com_cloud_run.png)

## Visão Geral do Fluxo

1. **Google App Script**: Captura automaticamente cada nova resposta do formulário.
2. **Script Python**: Recebe os dados do App Script, processa as informações e salva no Cloud Storage.
3. **Container Docker**: O script Python é empacotado em um container e implementado no Cloud Run.
4. **Terraform e Cloud Build**: Automatizam o provisionamento da infraestrutura e integração contínua com o repositório GitHub.
5. **Integração Final**: O App Script chama o Cloud Run para enviar as respostas capturadas.

---

## Requisitos

- Conta no Google Cloud Platform (GCP)
- Docker e Docker Compose instalados
- Terraform instalado
- Python (versão >= 3.8)
- Conta GitHub com repositório configurado

---

## Configuração do Projeto

### 1. Configuração do App Script
> [!IMPORTANT]  
> Crie primeiro o App Script antes de implementar o Cloud Run
> Certifique-se de que o Apps Script esteja no mesmo projeto GCP que o serviço Cloud Run 
> Habilite a tela de consentimento do OAuth em APIs e serviços no seu projeto do GCP [Aqui](https://support.google.com/cloud/answer/6158849?hl=en#)

1. No Google Formulários:
    - Crie um novo formulario em branco.
    ![form new](imgs/01_add_form.png)
    
    - Acione o editor de script.
    ![edit script](imgs/02_add_script.png)

    - Adicione um gatilho para acionar o script sempre que uma nova resposta for submetida ao Google Form.
    - Configure o gatilho para chamar o endpoint do Cloud Run.

### 2. Desenvolvimento do Script Python

1. Crie um script Python que:
    - Receba dados enviados pelo App Script via requisição HTTP.
    - Valide e processe os dados.
    - Armazene as informações no Cloud Storage.

2. Estrutura do script Python:

```python
from fastapi import (
    FastAPI,
    Request,
    status
)
from google.cloud import storage
import json
from datetime import datetime
import os

app = FastAPI()

bucket_name = os.getenv('BUCKET_NAME')

@app.post("/", status_code=status.HTTP_200_OK)
async def receive_data(requests: Request):
    data = await requests.json()
    responses = data['responses']

    send_cloud_storage(responses)
    return {"status": "Data entered successfully"}


def send_cloud_storage(responses):
    file_to = f'data/response_{datetime.now():%Y%m%d_%H%M}'

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(file_to)

    blob.upload_from_string(
        data=json.dumps(responses, indent=4, ensure_ascii=False),
        content_type='application/json'
    )
```

### 3. Container Docker

1. Crie um `Dockerfile` para empacotar o script Python:

```dockerfile
FROM python:3.12-slim

WORKDIR /ingestion_google_drive

COPY ingestion_google_drive/* /ingestion_google_drive/

RUN pip install --no-cache-dir --upgrade -r /ingestion_google_drive/requirements.txt

EXPOSE 8080

CMD ["fastapi", "run", "/ingestion_google_drive/main.py", "--port", "8080"]
```

2. Gere a imagem Docker:

```bash
docker build -t app-script-processor .
```

### 4. Configuração do Cloud Run

1. Suba o container para o Cloud Run:

```bash
gcloud run deploy app-script-processor \
    --image gcr.io/YOUR_PROJECT_ID/app-script-processor \
    --platform managed \
    --region YOUR_REGION \
    --allow-unauthenticated
```

2. Copie o endpoint gerado para configurar no App Script.

### 5. Automação com Terraform

1. Escreva os arquivos de configuração do Terraform para provisionar os recursos necessários:

- Cloud Storage
- Cloud Run
- Configurações do IAM
- Integração com o GitHub para CI/CD

2. Execute os comandos:

```bash
terraform init
terraform apply
```

### 6. Integração e Testes

1. Atualize o App Script para enviar os dados ao Cloud Run.
2. Realize testes enviando respostas ao formulário e verifique se os dados são processados e armazenados corretamente.

---

## Estrutura do Repositório

```plaintext
/
├── app/                # Código fonte do script Python
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── terraform/          # Configurações do Terraform
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md           # Documentação do projeto
```

---

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.
