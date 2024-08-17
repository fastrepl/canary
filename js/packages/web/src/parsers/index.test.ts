import { describe, test, expect } from "vitest";

import { parseTabs } from "./index";

describe("tabs", () => {
  test("basic", () => {
    expect(() => parseTabs("Docs:*;API:*")).toThrowError();

    expect(parseTabs("Docs:*;API:/api/.+$")).toEqual([
      { name: "Docs", pattern: null },
      { name: "API", pattern: /\/api\/.+$/ },
    ]);
  });
});
