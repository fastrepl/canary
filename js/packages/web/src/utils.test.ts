import { describe, test, expect } from "vitest";

import { urlToParts } from "./utils";

describe("urlToParts", () => {
  test("with host", () => {
    expect(urlToParts("https://example.com/docs/abc/Bcd/d")).toEqual([
      "Docs",
      "Abc",
      "Bcd",
      "D",
    ]);
  });

  test("without host", () => {
    expect(urlToParts("/docs/abc/Bcd/d/e")).toEqual(["Abc", "Bcd", "D", "E"]);
  });
});
