import modal
from pydantic import BaseModel, Field
from enum import Enum

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


class Metric(str, Enum):
    RAGAS_CONTEXT_PRECISION = "ragas_context_precision"
    RAGAS_CONTEXT_RECALL = "ragas_context_recall"
    RAGAS_ANSWER_RELEVANCE = "ragas_answer_relevance"
    RAGAS_FAITHFULNESS = "ragas_faithfulness"


class EvaluationInput(BaseModel):
    metrics: list[Metric] = Field(default_factory=list)
    dataset: list[dict] = Field(default_factory=list)


class SynthesizerInput(BaseModel):
    documents: list[str] = Field(default_factory=list)
    max_goldens_per_document: int = Field(default=2)
