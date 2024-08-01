import { test, expect } from "vitest";

// @ts-ignore
import { parse } from "./tabs";

test("parse", () => {
  expect(() => parse("Docs:*;API:*")).toThrowError();

  expect(parse("Docs:*;API:/api/.+$")).toEqual([
    { name: "Docs", pattern: null },
    { name: "API", pattern: /\/api\/.+$/ },
  ]);
});
