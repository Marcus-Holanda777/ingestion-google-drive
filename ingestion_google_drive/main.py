from fastapi import (
    FastAPI,
    Request,
    status
)


app = FastAPI()

@app.post("/", status_code=status.HTTP_200_OK)
async def receive_data(requests: Request):
    data = await requests.json()
    responses = data['responses']

    send_cloud_storage(responses)

    return {"status": "SuccessNovo"}


def send_cloud_storage(responses):
    print(responses)