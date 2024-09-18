import { vi, afterEach, beforeEach, describe, test, expect } from "vitest";
import { ExecutionManager, TaskStatus } from "./managers";

beforeEach(() => {
  vi.useFakeTimers();
});
afterEach(() => {
  vi.useRealTimers();
});

const SEARCH_DEBOUNCE_MS = 100;
const ASK_DEBOUNCE_MS = 400;

const createManager = () =>
  new ExecutionManager(document.createElement("div"), {
    searchDebounceMs: SEARCH_DEBOUNCE_MS,
    askDebounceMs: ASK_DEBOUNCE_MS,
  });

describe("ExecutionManager", () => {
  test("INTERNAL", () => {
    expect(SEARCH_DEBOUNCE_MS < ASK_DEBOUNCE_MS).toBe(true);
  });

  test.each([
    { method: "search", debounceMs: SEARCH_DEBOUNCE_MS },
    { method: "ask", debounceMs: ASK_DEBOUNCE_MS },
  ] as Array<{ method: "search" | "ask"; debounceMs: number }>)(
    "debounced $method",
    async ({ method, debounceMs }) => {
      const manager = createManager();
      const fn = vi.fn();

      expect(manager.ctx.status).toBe(TaskStatus.INITIAL);

      // moved to pending, but not executed yet
      manager[method]("query", { [method]: fn });
      expect(manager.ctx.status).toBe(TaskStatus.PENDING);
      await vi.advanceTimersByTimeAsync(debounceMs - 50);
      expect(manager.ctx.status).toBe(TaskStatus.PENDING);
      expect(fn).toHaveBeenCalledTimes(0);

      // finally executed after debounce
      await vi.advanceTimersByTimeAsync(100);
      expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);
      expect(fn).toHaveBeenCalledTimes(1);

      // multiple calls are ignored and only the last one is executed
      manager[method]("query", { [method]: fn });
      expect(manager.ctx.status).toBe(TaskStatus.PENDING);
      await vi.advanceTimersByTimeAsync(debounceMs - 50);
      manager[method]("query", { [method]: fn });
      await vi.advanceTimersByTimeAsync(debounceMs - 50);
      manager[method]("query", { [method]: fn });
      await vi.advanceTimersByTimeAsync(debounceMs);
      expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);
      expect(fn).toHaveBeenCalledTimes(1 + 1);
    },
  );

  test.each([
    { method: "search", debounceMs: SEARCH_DEBOUNCE_MS },
    { method: "ask", debounceMs: ASK_DEBOUNCE_MS },
  ] as Array<{ method: "search" | "ask"; debounceMs: number }>)(
    "aborted $method",
    async ({ method, debounceMs }) => {
      const manager = createManager();
      const LATENCY = 200;

      const fn =
        method === "search"
          ? vi
              .fn()
              .mockImplementationOnce((_input, signal) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    expect(signal.aborted).toBe(true);
                    resolve({ search: [] });
                  }, LATENCY);
                });
              })
              .mockImplementationOnce((_input, signal) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    expect(signal.aborted).toBe(false);
                    resolve({ search: [] });
                  }, LATENCY);
                });
              })
          : vi
              .fn()
              .mockImplementationOnce((_input, _delta, signal) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    expect(signal.aborted).toBe(true);
                    resolve({ ask: [] });
                  }, LATENCY);
                });
              })
              .mockImplementationOnce((_input, _delta, signal) => {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    expect(signal.aborted).toBe(false);
                    resolve({ ask: [] });
                  }, LATENCY);
                });
              });

      expect(manager.ctx.status).toBe(TaskStatus.INITIAL);

      manager[method]("query", { [method]: fn });
      expect(manager.ctx.status).toBe(TaskStatus.PENDING);
      await vi.advanceTimersByTimeAsync(debounceMs + 10);
      manager[method]("query", { [method]: fn });

      await vi.advanceTimersByTimeAsync(LATENCY + 1);

      expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);

      await vi.advanceTimersByTimeAsync(debounceMs + 10);
      expect(fn).toHaveBeenCalledTimes(1 + 1);
    },
  );

  test("pending", async () => {
    const manager = createManager();
    const operations = { search: vi.fn(), ask: vi.fn() };

    expect(manager.ctx.status).toBe(TaskStatus.INITIAL);

    // immediately transition to pending
    manager.search("query", operations);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);

    // finish search, back to complete
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS + 50);
    expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);

    // keep staying pending if search frequent enough
    manager.search("query", operations);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    manager.search("query", operations);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    manager.search("query", operations);
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);

    // back to complete if we wait too long
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);

    // debounce timer resets since we do 'ask' after 'search'
    manager.search("query", operations);
    await vi.advanceTimersByTimeAsync(SEARCH_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    manager.ask("query", operations);
    await vi.advanceTimersByTimeAsync(ASK_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    await vi.advanceTimersByTimeAsync(ASK_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);

    manager.ask("query", operations);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    await vi.advanceTimersByTimeAsync(ASK_DEBOUNCE_MS - 50);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    manager.ask("query", operations);
    expect(manager.ctx.status).toBe(TaskStatus.PENDING);
    await vi.advanceTimersByTimeAsync(ASK_DEBOUNCE_MS + 50);
    expect(manager.ctx.status).toBe(TaskStatus.COMPLETE);
  });
});
