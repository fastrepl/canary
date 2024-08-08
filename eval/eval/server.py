import os

import modal
from fastapi import FastAPI, Response, status, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from eval import shared, operation

web_app = FastAPI()
security = HTTPBearer()


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != os.environ["AUTH_TOKEN"]:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return credentials.credentials


@web_app.post("/eval/new")
async def eval_new(input: shared.EvaluationInput, token=Depends(verify_token)):
    call = operation.evaluate.spawn(input)
    return {"id": call.object_id}


@web_app.get("/eval/result/{id}")
async def eval_result(id: str):
    return fetch_result(id)


@web_app.post("/synthesize/new")
async def eval_new(input: shared.SynthesizerInput, token=Depends(verify_token)):
    call = operation.synthesize.spawn(input)
    return {"id": call.object_id}


@web_app.get("/synthesize/result/{id}")
async def eval_result(id: str):
    return fetch_result(id)


@web_app.get("/health")
async def health():
    return Response(status_code=status.HTTP_200_OK)


@shared.app.function(image=shared.image, secrets=[modal.Secret.from_name("AUTH_TOKEN")])
@modal.asgi_app()
def fastapi_app():
    return web_app


def fetch_result(id: str):
    from modal.functions import FunctionCall

    function_call = FunctionCall.from_id(id)

    try:
        result = function_call.get(timeout=0)
    except TimeoutError:
        return Response(status_code=status.HTTP_202_ACCEPTED)
    return result
