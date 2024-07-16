import { createContext } from "@lit/context";

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
