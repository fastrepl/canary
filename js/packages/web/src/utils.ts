import type { SearchReference } from "./types";

export const urlToParts = (url: string) => {
  let paths: string[] = [];
  try {
    paths = new URL(url).pathname.split("/");
  } catch {
    paths = url.split("/");
  }

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
  name: string | null;
  items: (SearchReference & { index: number })[];
};

export const groupSearchReferences = (
  references: SearchReference[],
): GroupedResult[] => {
  const groups: Map<string, GroupedResult> = new Map();

  for (const [index, ref] of references.entries()) {
    const url = new URL(ref.url);
    const pathKey = `${url.protocol}//${url.host}${url.pathname}`;

    if (!groups.has(pathKey)) {
      groups.set(pathKey, { name: ref.titles?.[0] ?? ref.title, items: [] });
    }

    const group = groups.get(pathKey)!;
    group.items.push({ ...ref, index });
  }

  return Array.from(groups.values());
};

export const asyncSleep = async (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const stripURL = (url: string) => {
  try {
    const { pathname, search } = new URL(url);
    return pathname + search;
  } catch {
    return url;
  }
};
