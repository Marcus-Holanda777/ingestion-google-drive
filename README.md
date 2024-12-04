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