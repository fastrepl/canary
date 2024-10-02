import type { QueryContext, AskResponse } from "./index";

export type AskFunction = (
  payload: QueryContext,
  handleDelta: (data: AskResponse) => void,
  signal: AbortSignal,
) => Promise<null>;
