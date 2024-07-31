import type { SearchReference } from "./types";

export const randomInteger = () => {
  return Math.floor(Math.random() * 1000000000000000);
};

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
  const groups: GroupedResult[] = [];
  let currentGroup: GroupedResult | null = null;

  for (const [index, ref] of references.entries()) {
    if (!ref.titles || ref.titles.length === 0) {
      groups.push({ name: null, items: [{ ...ref, index }] });
      currentGroup = null;
      continue;
    }

    const [pageTitle] = ref.titles;
    if (!currentGroup || currentGroup.name !== pageTitle) {
      currentGroup = { name: pageTitle, items: [] };
      groups.push(currentGroup);
    }
    currentGroup.items.push({ ...ref, index });
  }

  return groups;
};

export const asyncSleep = async (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};
