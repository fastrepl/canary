import { createContext } from "@lit/context";

import { type Reference } from "./core";

export type CloudProviderContext = {
  type: "cloud";
  endpoint: string;
  key: string;
};
export type PagefindProviderContext = { type: "pagefind" };
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

export const searchReferencesContext =
  createContext<Reference[]>("search-references");

export const askReferencesContext =
  createContext<Reference[]>("ask-references");

export const askResponseContext = createContext<string>("ask-response");
