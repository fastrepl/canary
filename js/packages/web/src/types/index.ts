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
) => Promise<Reference[] | null>;

type AskFunction = (
  id: number,
  query: string,
  handleDelta: (delta: Delta) => void,
  signal?: AbortSignal,
) => Promise<null>;

type FeedbackFunction = (
  url: string,
  data: { content: string },
) => Promise<null>;

export type QueryContext = string;

export type ModeContext = {
  options: Set<Mode>;
  current: Mode;
};

export enum Mode {
  Search = "Search",
  Ask = "Ask",
}

export type ThemeContext = "light" | "dark";

export type Framework = "starlight" | "docusaurus" | "vitepress";

export type TriggerShortcut = "cmdk" | "slash";

export type OperationContext = {
  search: SearchFunction;
  ask: AskFunction;
  feedback: FeedbackFunction;
};