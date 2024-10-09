import { describe, test, expect, vi } from "vitest";

import { cache } from "./decorators/cache";

describe("cache", () => {
  test("no hit", () => {
    const impl = vi
      .fn()
      .mockImplementation(
        (a: number, b: number) => new Promise((resolve) => resolve(a + b)),
      );
    const fn = cache(impl);

    fn(1, 2).then((v: number) => expect(v).toEqual(3));
    fn(3, 4).then((v: number) => expect(v).toEqual(7));
    fn(5, 6).then((v: number) => expect(v).toEqual(11));
    expect(impl).toHaveBeenCalledTimes(3);
  });

  test("hit", async () => {
    const impl = vi
      .fn()
      .mockImplementation((n: number) => new Promise((resolve) => resolve(n)));
    const fn = cache(impl);

    fn(1).then((v: number) => expect(v).toEqual(1));
    fn(2).then((v: number) => expect(v).toEqual(2));
    fn(2).then((v: number) => expect(v).toEqual(2));
    expect(impl).toHaveBeenCalledTimes(3 - 1);
  });
});
