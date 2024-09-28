import { AskResponse } from "./schema";

export type AskFunction = (
  payload: { query: string },
  handleDelta: (data: AskResponse) => void,
  signal: AbortSignal,
) => Promise<null>;
