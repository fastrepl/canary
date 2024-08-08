import modal

PYTHON_VERSION = "3.11"
RAGAS_VERSION = "0.1.13"
DEEPEVAL_VERSION = "0.21.74"
FASTAPI_VERSION = "0.112.0"
LANGUAGE_MODEL = "gpt-4o"
EMBEDDING_MODEL = "text-embedding-3-small"

app = modal.App(name="canary-eval")
image = (
    modal.Image.debian_slim(python_version=PYTHON_VERSION)
    .pip_install(f"fastapi=={FASTAPI_VERSION}")
    .pip_install(f"ragas=={RAGAS_VERSION}")
    .pip_install(f"deepeval=={DEEPEVAL_VERSION}")
)
