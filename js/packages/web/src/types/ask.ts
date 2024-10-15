import type { QueryContext, AskResponse } from "./index";
import type { Meta } from "./meta";

export type AskFunction = (
  query: QueryContext,
  meta: Meta,
  handleDelta: (data: AskResponse) => void,
  signal: AbortSignal,
) => Promise<null>;
