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

export const queryContext = createContext<string>("");
export const modeContext = createContext<string>("Search");
export const searchReferencesContext = createContext<Reference[]>([]);
