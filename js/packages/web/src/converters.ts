import type { PropertyDeclaration } from "lit";

export const StringArray: PropertyDeclaration["converter"] = {
  fromAttribute: (v, _) => String(v).split(","),
  toAttribute: (v, _) => (Array.isArray(v) ? v.join(",") : v),
};

export const StringRegexRecord: PropertyDeclaration["converter"] = {
  fromAttribute: (v, _) => {
    if (typeof v !== "string") {
      return {};
    }

    return v.split(";").reduce(
      (acc, pair) => {
        const [key, value] = pair.split(":");

        if (key && value) {
          return { ...acc, [key.trim()]: new RegExp(value.trim()) };
        }

        return acc;
      },
      {} as Record<string, RegExp>,
    );
  },
  toAttribute: (v, _) => {
    if (typeof v !== "object" || v === null) {
      return "";
    }

    return Object.entries(v)
      .map(([key, value]) => `${key}:${value.toString()}`)
      .join(";");
  },
};
