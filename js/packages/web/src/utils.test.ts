import { describe, test, expect } from "vitest";

import { groupSearchReferences, urlToParts } from "./utils";

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
  test.for([
    ["empty", [], []],
    [
      "no sub-results",
      [
        { url: "", title: "a", titles: [] },
        { url: "", title: "b", titles: [] },
        { url: "", title: "c", titles: [] },
      ],
      [
        {
          name: null,
          items: [{ url: "", title: "a", titles: [], index: 0 }],
        },
        {
          name: null,
          items: [{ url: "", title: "b", titles: [], index: 1 }],
        },
        {
          name: null,
          items: [{ url: "", title: "c", titles: [], index: 2 }],
        },
      ],
      "with sub-results",
      [
        { url: "", title: "a", titles: ["a", "1"] },
        { url: "", title: "b", titles: ["a"] },
        { url: "", title: "c", titles: [] },
        { url: "", title: "d", titles: [] },
        { url: "", title: "e", titles: ["b"] },
        { url: "", title: "f", titles: ["b"] },
        { url: "", title: "g", titles: ["a"] },
        { url: "", title: "h", titles: ["c"] },
        { url: "", title: "i", titles: ["c"] },
      ],
      {
        name: "a",
        items: [
          { url: "", title: "a", titles: ["a", "1"], index: 0 },
          { url: "", title: "b", titles: ["a"], index: 1 },
        ],
      },
      {
        name: null,
        items: [{ url: "", title: "c", titles: [], index: 2 }],
      },
      {
        name: null,
        items: [{ url: "", title: "d", titles: [], index: 3 }],
      },
      {
        name: "b",
        items: [
          { url: "", title: "e", titles: ["b"], index: 4 },
          { url: "", title: "f", titles: ["b"], index: 5 },
        ],
      },
      {
        name: "a",
        items: [{ url: "", title: "g", titles: ["a"], index: 6 }],
      },
      {
        name: "c",
        items: [
          { url: "", title: "h", titles: ["c"], index: 7 },
          { url: "", title: "i", titles: ["c"], index: 8 },
        ],
      },
    ],
  ])("%s", ([_, input, expected]: any[]) => {
    expect(groupSearchReferences(input)).toEqual(expected);
  });
});
