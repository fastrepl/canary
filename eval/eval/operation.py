import os

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
        model_name="gpt-4o",
        base_url=os.environ["OPENAI_API_BASE"],
        api_key=os.environ["OPENAI_API_KEY"],
    )

    embeddings = OpenAIEmbeddings(
        model="text-embedding-3-small",
        base_url=os.environ["OPENAI_API_BASE"],
        api_key=os.environ["OPENAI_API_KEY"],
    )

    return (
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
        .to_json()
    )
