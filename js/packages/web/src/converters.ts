import type { PropertyDeclaration } from "lit";

export const StringArray: PropertyDeclaration["converter"] = {
  fromAttribute: (v, _) => String(v).split(","),
  toAttribute: (v, _) => (Array.isArray(v) ? v.join(",") : v),
};

export const StringRecord: PropertyDeclaration["converter"] = {
  fromAttribute: (v, _) =>
    String(v)
      .split(";")
      .reduce(
        (acc, pair) => {
          const [key, value] = pair.split(":");
          if (key && value) {
            acc[key.trim()] = value.trim();
          }
          return acc;
        },
        {} as Record<string, string>,
      ),
  toAttribute: (v, _) => {
    if (!v) {
      return "";
    }
    if (typeof v !== "object") {
      return v;
    }

    return Object.entries(v).reduce((acc, [key, value]) => {
      return `${acc}${key}:${value};`;
    }, "");
  },
};
