import { describe, test, expect, vi } from "vitest";

import { cache } from "./decorators";

describe("cache", () => {
  test("no hit", () => {
    const impl = (a: number, b: number) => a + b;
    const fn = cache(impl);

    expect(fn(1, 2)).toEqual(3);
    expect(fn(3, 4)).toEqual(7);
    expect(fn(5, 6)).toEqual(11);
  });

  test("hit", () => {
    const impl = vi.fn().mockImplementation((n: number) => n);
    const fn = cache(impl);

    expect(fn(1)).toEqual(1);
    expect(fn(2)).toEqual(2);
    expect(fn(1)).toEqual(1);
    expect(impl).toHaveBeenCalledTimes(1 + 1 + 0);
  });
});
