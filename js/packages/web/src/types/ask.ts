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
  items: AskReference[];
};

export type AskReference = {
  url: string;
  title: string;
};

export type Delta =
  | DeltaError
  | DeltaProgress
  | DeltaComplete
  | DeltaReferences;

export type AskFunction = (
  id: number,
  query: string,
  handleDelta: (delta: Delta) => void,
  signal?: AbortSignal,
) => Promise<null>;
