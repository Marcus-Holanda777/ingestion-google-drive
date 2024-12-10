FROM python:3.12-slim

WORKDIR /ingestion_google_driver

COPY ingestion_google_driver/* /ingestion_google_driver/

RUN pip install --no-cache-dir --upgrade -r /ingestion_google_driver/requirements.txt

EXPOSE 8080

CMD ["fastapi", "run", "ingestion_google_driver/main.py", "--proxy-headers", "--port", "8080"]