FROM python:3.12-slim

WORKDIR /ingestion_google_driver

COPY . .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

EXPOSE 8080

CMD ["fastapi", "run", "main.py", "--proxy-headers", "--port", "8080"]