FROM python:3.12-slim

WORKDIR /ingestion_google_drive

COPY ingestion_google_drive/* /ingestion_google_drive/

RUN pip install --no-cache-dir --upgrade -r /ingestion_google_drive/requirements.txt

ENV PORT 8080

CMD ["fastapi", "run", "ingestion_google_drive/main.py"]