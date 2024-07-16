import { createContext } from "@lit/context";

import type { Delta } from "./types";

type SearchFunction = (query: string, signal?: AbortSignal) => Promise<any>;
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

export type ProviderContext =
  | MockProviderContext
  | PagefindProviderContext
  | CloudProviderContext;

export const providerContext = createContext<ProviderContext>({});

export type ModeContext = {
  options: Set<"Search" | "Ask">;
  current: "Search" | "Ask";
};
export const defaultModeContext: ModeContext = {
  options: new Set<"Search" | "Ask">(["Search"]),
  current: "Search",
};
export const modeContext = createContext<ModeContext>(defaultModeContext);

export const queryContext = createContext<string>("query");
