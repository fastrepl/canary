import type { PropertyDeclaration } from "lit";

export const StringArray: PropertyDeclaration["converter"] = {
  fromAttribute: (v, _) => String(v).split(","),
  toAttribute: (v, _) => (Array.isArray(v) ? v.join(",") : v),
};
