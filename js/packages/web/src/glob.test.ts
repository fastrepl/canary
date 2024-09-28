import { describe, test, expect } from "vitest";

import pm from "picomatch";

describe("picomatch", () => {
  test.each([
    ["*", "a", true],
    ["*", "a/b", false],
    ["**", "a", true],
    ["**", "a/b", true],
    ["**/*", "github.com/a", true],
    ["**/*", "https://github.com/a", true],
    ["**/github.com/*", "https://github.com/a", true],
    ["**/github.com/*", "https://example.com/a", false],
    ["**/a/**", "https://example.com/a/b", true],
    ["**/a/*", "https://example.com/a/b", true],
  ])("pm('%s')('%s')", (pattern, path, expected) => {
    expect(pm(pattern)(path)).toBe(expected);
  });
});
