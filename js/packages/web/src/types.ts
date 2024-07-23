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

type SearchFunction = (
  query: string,
  signal?: AbortSignal,
) => Promise<Reference[]>;

type AskFunction = (
  id: number,
  query: string,
  handleDelta: (delta: Delta) => void,
  signal?: AbortSignal,
) => Promise<any>;

export type CloudProviderContext = {
  type: "cloud";
  endpoint: string;
  key: string;
  search: SearchFunction;
  ask: AskFunction;
};

export type PagefindProviderContext = {
  type: "pagefind";
  search: SearchFunction;
  ask: AskFunction;
};

export type MockProviderContext = {
  type: "mock";
  search: SearchFunction;
  ask: AskFunction;
};

export type QueryContext = string;

export type ProviderContext =
  | MockProviderContext
  | PagefindProviderContext
  | CloudProviderContext;

export type ModeContext = {
  options: Set<Mode>;
  current: Mode;
};

export enum Mode {
  Search = "Search",
  Ask = "Ask",
}

export type ThemeContext = "light" | "dark";
