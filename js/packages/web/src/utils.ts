import type { FiltersContext, SearchResult } from "./types";

export const urlToParts = (url: string) => {
  const paths = parseURL(url).pathname.split("/");

  const parts = paths
    .map((path, _) => {
      const text = path.replace(/[-_]/g, " ");
      return text.charAt(0).toUpperCase() + text.slice(1);
    })
    .map((text) => (text.includes("#") ? text.split("#")[0] : text))
    .map((text) => (text.endsWith(".html") ? text.replace(".html", "") : text))
    .map(decodeURIComponent)
    .filter(Boolean)
    .slice(-4);

  return parts;
};

export const asyncSleep = async (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const stripURL = (url: string) => {
  try {
    const { pathname, search } = parseURL(url);
    return pathname + search;
  } catch {
    return url;
  }
};

export const withTimeout = (signal: AbortSignal, ms = 3000) => {
  const timeout = AbortSignal.timeout(ms);

  if ("any" in AbortSignal) {
    return AbortSignal.any([signal, timeout]);
  }

  return timeout;
};

export const parseURL = (url: string) => {
  const transformed = url.startsWith("http")
    ? url
    : url.startsWith("/")
      ? `https://example.com${url}`
      : `https://example.com/${url}`;

  return new URL(transformed);
};

export const applyFilters = (
  matches: SearchResult[],
  filters: FiltersContext,
): SearchResult[] => {
  return Object.entries(filters).reduce(
    (acc, [_, { fn, args }]) => fn(acc, args),
    matches,
  );
};

export async function* sseIterator(req: Request) {
  const res = await fetch(req);

  if (!res.ok) {
    throw new Error(res.statusText);
  }

  const reader = res.body?.pipeThrough(new TextDecoderStream()).getReader();

  if (!reader) {
    throw new Error("empty body");
  }

  let buffer = "";

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        break;
      }

      buffer += value;

      let events = buffer.split(/\r?\n\r?\n/);
      buffer = events.pop() || "";

      for (const event of events) {
        if (!event.trim()) {
          continue;
        }

        const dataLines = event
          .split(/\r?\n/)
          .filter((line) => line.startsWith("data: "));

        for (const line of dataLines) {
          const dataContent = line.slice(6);
          yield { data: dataContent };
        }
      }
    }
  } finally {
    reader.releaseLock();
  }
}
