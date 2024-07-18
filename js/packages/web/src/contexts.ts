import { createContext } from "@lit/context";

import type { Delta, Reference } from "./types";

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

export type ProviderContext =
  | MockProviderContext
  | PagefindProviderContext
  | CloudProviderContext;

export type ModeContext = {
  options: Set<"Search" | "Ask">;
  current: "Search" | "Ask";
};

const ctx = <T>(key: string) => createContext<T>(Symbol(key));

export const providerContext = ctx<ProviderContext>("provider");
export const modeContext = ctx<ModeContext>("mode");
export const queryContext = ctx<string>("query");
