import { ContextProvider } from "@lit/context";

import type {
  OperationContext,
  SearchContext,
  SearchFunction,
  AskContext,
  AskReference,
  Delta,
} from "../types";
import { asyncSleep } from "../utils";
import { askContext, searchContext } from "../contexts";

// https://github.com/lit/lit/blob/main/packages/task/src/task.ts
export type TaskStatus = (typeof TaskStatus)[keyof typeof TaskStatus];
export const TaskStatus = {
  INITIAL: 0,
  PENDING: 1,
  COMPLETE: 2,
  ERROR: 3,
} as const;

type SearchManagerOptions = {
  debounceMs: number;
};

const ABORT_REASON_MANAGER = "manager";

export class SearchManager {
  ctx: ContextProvider<{ __context__: SearchContext }, any>;

  private _options: SearchManagerOptions;
  private _callId = 0;
  private _abortController = new AbortController();

  constructor(host: HTMLElement, options: SearchManagerOptions) {
    this._options = options;
    this.ctx = new ContextProvider(host, {
      context: searchContext,
      initialValue: { status: TaskStatus.INITIAL, references: [] },
    });
  }

  abort() {
    if (this.ctx.value.status === TaskStatus.PENDING) {
      this._abortController?.abort(ABORT_REASON_MANAGER);
    }
  }

  async run(query: string, operations: OperationContext) {
    if (!operations.search) {
      return;
    }

    if (this.ctx.value.status === TaskStatus.PENDING) {
      this._abortController.abort(ABORT_REASON_MANAGER);
    }
    this.transition(TaskStatus.PENDING);

    const callId = ++this._callId;
    operations.beforeSearch?.(query);
    await asyncSleep(this._options.debounceMs);

    if (callId !== this._callId) {
      return;
    }

    this._abortController = new AbortController();
    try {
      const result = await operations.search(
        query,
        this._abortController.signal,
      );
      this.transition(TaskStatus.COMPLETE, result);
    } catch (e) {
      if (e === ABORT_REASON_MANAGER) {
        return;
      }

      console.error(e);
      this.transition(TaskStatus.ERROR);
    }
  }

  private transition(
    status: TaskStatus,
    result?: Awaited<ReturnType<SearchFunction>>,
  ) {
    const next = {
      ...this.ctx.value,
      status,
      ...(result && { references: result }),
    };

    this.ctx.setValue(next);
  }
}

export class AskManager {
  ctx: ContextProvider<{ __context__: AskContext }, any>;

  private _abortController = new AbortController();

  constructor(host: HTMLElement) {
    this.ctx = new ContextProvider(host, {
      context: askContext,
      initialValue: {
        status: TaskStatus.INITIAL,
        response: "",
        references: [],
        progress: false,
        query: "",
      },
    });
  }

  abort() {
    if (this.ctx.value.status === TaskStatus.PENDING) {
      this._abortController?.abort(ABORT_REASON_MANAGER);
    }
  }

  async run(query: string, operations: OperationContext) {
    if (!operations.search || !operations.ask) {
      return;
    }

    if (this.ctx.value.status === TaskStatus.PENDING) {
      this._abortController.abort(ABORT_REASON_MANAGER);
    }
    this.transition({ status: TaskStatus.PENDING, query });

    this._abortController = new AbortController();

    const references = await operations.search(
      query,
      this._abortController.signal,
    );
    this.transition({ status: TaskStatus.PENDING, references });

    await operations.ask(
      crypto.randomUUID(),
      query,
      this._handleDelta.bind(this),
      this._abortController.signal,
    );
    this.transition({ status: TaskStatus.COMPLETE, progress: false });
  }

  private _handleDelta(delta: Delta) {
    if (delta.type === "progress") {
      const response = this.ctx.value.response + delta.content;
      this.transition({ response, progress: true });
    }
  }

  private transition(diff: Partial<AskContext>) {
    const next = {
      ...this.ctx.value,
      ...diff,
    };

    this.ctx.setValue(next);
  }
}
