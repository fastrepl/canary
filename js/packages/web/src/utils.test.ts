import { describe, test, expect } from "vitest";

import { stripURL, groupSearchReferences, urlToParts } from "./utils";

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
    expect(urlToParts("/docs/abc/Bcd/d/e#a")).toEqual(["Abc", "Bcd", "D", "E"]);
  });
});

describe("groupSearchReferences", () => {
  test.for([["empty", [], []]])("%s", ([_, input, expected]: any[]) => {
    expect(groupSearchReferences(input)).toEqual(expected);
  });
});

describe("stripURL", () => {
  test.each([
    ["https://example.com", "/"],
    ["https://example.com/docs/a/b", "/docs/a/b"],
    [
      "https://example.com/?name=Jonathan%20Smith&age=18",
      "/?name=Jonathan%20Smith&age=18",
    ],
    ["/", "/"],
    ["/docs/a/b", "/docs/a/b"],
    ["/?name=Jonathan%20Smith&age=18", "/?name=Jonathan%20Smith&age=18"],
  ])("%s", (input, expected) => {
    expect(stripURL(input)).toEqual(expected);
  });
});
