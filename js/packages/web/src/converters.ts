import type { ComplexAttributeConverter } from "lit";

export const StringArray: Required<ComplexAttributeConverter<string[]>> = {
  fromAttribute: (v, _) => String(v).split(","),
  toAttribute: (v, _) => (Array.isArray(v) ? v.join(",") : v),
};
