import os
import datetime
import tempfile

import modal
from datasets import Dataset
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from deepeval.synthesizer import Synthesizer
import ragas
from ragas.metrics import (
    context_precision,
    answer_relevancy,
    faithfulness,
    context_recall,
)

from eval import shared

metric_map = {
    shared.Metric.RAGAS_CONTEXT_PRECISION: context_precision,
    shared.Metric.RAGAS_CONTEXT_RECALL: context_recall,
    shared.Metric.RAGAS_ANSWER_RELEVANCE: answer_relevancy,
    shared.Metric.RAGAS_FAITHFULNESS: faithfulness,
}


@shared.app.function(
    image=shared.image,
    secrets=[modal.Secret.from_name("LITELLM_PROXY")],
    timeout=60 * 15,
)
def evaluate(input: shared.EvaluationInput):
    ds = Dataset.from_list(input.dataset)
    metrics = [metric_map[metric] for metric in input.metrics]

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
        .drop(columns=list(input.dataset[0].keys()))
        .mean()
        .to_dict()
    )

    return with_metadata({"scores": scores})


@shared.app.function(
    image=shared.image,
    secrets=[modal.Secret.from_name("LITELLM_PROXY")],
    timeout=60 * 15,
)
def synthesize(input: shared.SynthesizerInput):
    with tempfile.TemporaryDirectory() as td:
        paths = []

        for index, doc in enumerate(input.documents):
            path = os.path.join(td, f"doc-{index}.txt")
            with open(path, "w") as f:
                f.write(doc)
            paths.append(path)

        return Synthesizer().generate_goldens_from_docs(
            document_paths=paths,
            max_goldens_per_document=input.max_goldens_per_document,
            include_expected_output=True,
        )


def with_metadata(data):
    return {
        "language_model": shared.LANGUAGE_MODEL,
        "embedding_model": shared.EMBEDDING_MODEL,
        "ragas_version": shared.RAGAS_VERSION,
        "deepeval_version": shared.DEEPEVAL_VERSION,
        "timestamp": datetime.datetime.now().isoformat(),
        **data,
    }
