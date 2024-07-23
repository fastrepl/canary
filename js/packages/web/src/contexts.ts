import { createContext } from "@lit/context";

const ctx = <T>(key: string) => createContext<T>(Symbol(key));

import type {
  ProviderContext,
  ModeContext,
  ThemeContext,
  QueryContext,
} from "./types";

export const providerContext = ctx<ProviderContext>("provider");
export const modeContext = ctx<ModeContext>("mode");
export const queryContext = ctx<QueryContext>("query");
export const themeContext = ctx<ThemeContext>("theme");
