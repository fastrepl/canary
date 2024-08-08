import os
import datetime

import modal
from datasets import Dataset
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

import ragas
from ragas.metrics import (
    context_precision,
    answer_relevancy,
    faithfulness,
    context_recall,
)

from eval import shared


@shared.app.function(
    image=shared.image,
    secrets=[modal.Secret.from_name("LITELLM_PROXY")],
)
def evaluate(dict):
    ds = Dataset.from_dict(dict)

    metrics = [
        faithfulness,
        answer_relevancy,
        context_recall,
        context_precision,
    ]

    llm = ChatOpenAI(
        model_name=shared.LANGUAGE_MODEL,
        base_url=os.environ["OPENAI_API_BASE"],
        api_key=os.environ["OPENAI_API_KEY"],
    )

    embeddings = OpenAIEmbeddings(
        model=shared.EMBEDDING_MODEL,
        base_url=os.environ["OPENAI_API_BASE"],
        api_key=os.environ["OPENAI_API_KEY"],
    )

    scores = (
        ragas.evaluate(
            dataset=ds,
            metrics=metrics,
            llm=llm,
            embeddings=embeddings,
            in_ci=True,
        )
        .to_pandas()
        .drop(columns=list(dict.keys()))
        .mean()
        .to_dict()
    )

    return with_metadata({"scores": scores})


def with_metadata(data):
    return {
        "language_model": shared.LANGUAGE_MODEL,
        "embedding_model": shared.EMBEDDING_MODEL,
        "ragas_version": shared.RAGAS_VERSION,
        "deepeval_version": shared.DEEPEVAL_VERSION,
        "timestamp": datetime.datetime.now().isoformat(),
        **data,
    }
