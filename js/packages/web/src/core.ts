// This should be moved to @getcanary/core at some point

export const search = async (
  key: string,
  endpoint: string,
  query: string,
  signal?: AbortSignal,
) => {
  const url = `${endpoint}/api/v1/search`;

  const params = {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ key, query }),
    signal,
  };

  const response = await fetch(url, params);
  if (!response.ok) {
    throw new Error();
  }

  return response.json();
};

export const ask = async (
  key: string,
  endpoint: string,
  id: number,
  query: string,
  handleDelta: (delta: Delta) => void = () => {},
  signal?: AbortSignal,
) => {
  const url = `${endpoint}/api/v1/ask`;
  const params = {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id, key, query }),
    signal,
  };

  const response = await fetch(url, params);
  if (!response.ok) {
    throw new Error();
  }

  const reader = response.body
    ?.pipeThrough(new TextDecoderStream())
    .getReader();

  if (!reader) {
    throw new Error();
  }

  while (true) {
    try {
      const { done, value } = await reader.read();
      if (done) {
        break;
      }

      value
        .split("\n\n")
        .flatMap((s) => s.split("data: "))
        .filter(Boolean)
        .map((s) => JSON.parse(s) as Delta)
        .forEach(handleDelta);
    } catch (error) {
      if (error instanceof Error && error.name !== "AbortError") {
        console.error(error);
      }

      break;
    }
  }

  return null;
};

export type Delta = DeltaError | DeltaProgress | DeltaComplete;

type DeltaError = {
  type: "error";
  reason: string;
};

type DeltaProgress = {
  type: "progress";
  content: string;
};

type DeltaComplete = {
  type: "complete";
};

export type SearchResultItem = {
  title: string;
  url: string;
  excerpt: string;
};
