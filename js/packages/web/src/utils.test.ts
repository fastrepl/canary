import { describe, test, expect } from "vitest";

import { urlToParts } from "./utils";

describe("urlToParts", () => {
  test("with host", () => {
    expect(urlToParts("https://example.com/docs/ab-c/B_cd/d")).toEqual([
      "Docs",
      "Ab c",
      "B cd",
      "D",
    ]);
  });

  test("without host", () => {
    expect(urlToParts("/docs/abc/Bcd/d/e")).toEqual(["Abc", "Bcd", "D", "E"]);
  });
});
