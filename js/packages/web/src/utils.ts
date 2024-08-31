import type { SearchReference } from "./types";

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

type GroupedResult = {
  title: string | null;
  items: (SearchReference & { index: number })[];
};

export const groupSearchReferences = (
  references: SearchReference[],
): GroupedResult[] => {
  const groups: Map<string, GroupedResult> = new Map();

  for (const [index, ref] of references.entries()) {
    const url = parseURL(ref.url);
    const pathKey = `${url.protocol}//${url.host}${url.pathname}`;

    if (!groups.has(pathKey)) {
      groups.set(pathKey, { title: ref.titles?.[0] ?? ref.title, items: [] });
    }

    const group = groups.get(pathKey)!;
    const lastAddedIndex =
      group.items.length > 0 ? group.items[group.items.length - 1].index : 999;

    if (index - lastAddedIndex <= 3) {
      group.items.push({ ...ref, index });
    } else {
      groups.set(`${pathKey}-${index}`, {
        title: ref.titles?.[0] ?? ref.title,
        items: [{ ...ref, index }],
      });
    }
  }

  return Array.from(groups.values());
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
