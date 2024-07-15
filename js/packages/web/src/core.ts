import { type ProviderContext } from "./contexts";

export const search = async (
  provider: ProviderContext | undefined | null,
  query: string,
  signal?: AbortSignal,
) => {
  if (!provider) {
    throw new Error("Provider not found");
  }

  if (provider.type === "cloud") {
    const url = `${provider.endpoint}/api/v1/search`;

    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ key: provider.key, query }),
      signal,
    };

    const response = await fetch(url, params);
    if (!response.ok) {
      throw new Error();
    }

    return response.json();
  }

  return [];
};

export const ask = async (
  provider: ProviderContext | undefined | null,
  id: number,
  query: string,
  handleDelta: (delta: Delta) => void = () => {},
  signal?: AbortSignal,
) => {
  if (!provider) {
    throw new Error("Provider not found");
  }

  if (provider.type === "cloud") {
    const url = `${provider.endpoint}/api/v1/ask`;
    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, key: provider.key, query }),
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
  }

  return null;
};

export type Delta =
  | DeltaError
  | DeltaProgress
  | DeltaComplete
  | DeltaReferences;

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

type DeltaReferences = {
  type: "references";
  items: Reference[];
};

export type Reference = {
  title: string;
  url: string;
  excerpt?: string;
};
