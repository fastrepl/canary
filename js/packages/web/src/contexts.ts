import { createContext } from "@lit/context";

import type { Delta } from "./types";

export type CloudProviderContext = {
  type: "cloud";
  endpoint: string;
  key: string;
  search: (query: string, signal?: AbortSignal) => Promise<any>;
  ask: (
    id: number,
    query: string,
    handleDelta: (delta: Delta) => void,
    signal?: AbortSignal,
  ) => Promise<any>;
};

export type PagefindProviderContext = {
  type: "pagefind";
  search: (query: string, signal?: AbortSignal) => Promise<any>;
  ask: (
    id: number,
    query: string,
    handleDelta: (delta: Delta) => void,
    signal?: AbortSignal,
  ) => Promise<any>;
};

export type ProviderContext = PagefindProviderContext | CloudProviderContext;
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
