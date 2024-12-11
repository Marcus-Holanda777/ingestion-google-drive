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