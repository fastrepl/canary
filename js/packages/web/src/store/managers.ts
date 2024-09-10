import { ContextProvider } from "@lit/context";

import type {
  OperationContext,
  SearchContext,
  AskContext,
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
  private _ctx: ContextProvider<{ __context__: SearchContext }, any>;
  private _abortController = new AbortController();

  private _options: SearchManagerOptions;
  private _callId = 0;

  private _initialState: SearchContext = {
    status: TaskStatus.INITIAL,
    result: { references: {}, suggestion: { questions: [] } },
  };

  constructor(host: HTMLElement, options: SearchManagerOptions) {
    this._options = options;
    this._ctx = new ContextProvider(host, {
      context: searchContext,
      initialValue: this._initialState,
    });
  }

  get ctx() {
    return this._ctx.value;
  }

  set ctx(ctx: SearchContext) {
    this._ctx.setValue(ctx);
  }

  abort() {
    if (this.ctx.status === TaskStatus.PENDING) {
      this._abortController?.abort(ABORT_REASON_MANAGER);
    }
  }

  async run(query: string, operations: OperationContext) {
    if (!operations.search) {
      return;
    }

    if (this.ctx.status === TaskStatus.PENDING) {
      this._abortController.abort(ABORT_REASON_MANAGER);
    }
    this.transition({ status: TaskStatus.PENDING });

    const callId = ++this._callId;
    operations.beforeSearch?.(query);
    await asyncSleep(this._options.debounceMs);

    if (callId !== this._callId) {
      this.transition({ status: TaskStatus.INITIAL });
      return;
    }

    this._abortController = new AbortController();
    try {
      const result = await operations.search(
        { query },
        this._abortController.signal,
      );

      this.transition({ status: TaskStatus.COMPLETE, result });
    } catch (e) {
      if (e === ABORT_REASON_MANAGER) {
        this.transition({ status: TaskStatus.INITIAL });
        return;
      }

      console.error(e);
      this.transition({ status: TaskStatus.ERROR });
    }
  }

  private transition(diff: Partial<SearchContext>) {
    this.ctx = { ...this.ctx, ...diff };
  }
}

export class AskManager {
  private _ctx: ContextProvider<{ __context__: AskContext }, any>;
  private _abortController = new AbortController();

  private _initialState: AskContext = {
    status: TaskStatus.INITIAL,
    response: "",
    references: [],
    progress: false,
    query: "",
  };

  constructor(host: HTMLElement) {
    this._ctx = new ContextProvider(host, {
      context: askContext,
      initialValue: this._initialState,
    });
  }

  abort() {
    if (this.ctx.status === TaskStatus.PENDING) {
      this._abortController?.abort(ABORT_REASON_MANAGER);
    }
  }

  get ctx() {
    return this._ctx.value;
  }

  set ctx(ctx: AskContext) {
    this._ctx.setValue(ctx);
  }

  async run(query: string, pattern: string, operations: OperationContext) {
    if (!operations.ask || query.length === 0) {
      return;
    }

    if (this.ctx.status === TaskStatus.PENDING) {
      this._abortController.abort(ABORT_REASON_MANAGER);
    }
    this.transition({
      ...this._initialState,
      status: TaskStatus.PENDING,
      query,
    });

    this._abortController = new AbortController();

    try {
      await operations.ask(
        { id: crypto.randomUUID(), query, pattern },
        this._handleDelta.bind(this),
        this._abortController.signal,
      );
      this.transition({ status: TaskStatus.COMPLETE, progress: false });
    } catch (e) {
      if (e === ABORT_REASON_MANAGER) {
        return;
      }

      console.error(e);
      this.transition({ status: TaskStatus.ERROR });
    }
  }

  private _handleDelta(delta: Delta) {
    if (delta.type === "progress") {
      const response = this.ctx.response + delta.content;
      this.transition({ response, progress: true });
    }

    if (delta.type === "complete") {
      this.transition({ response: delta.content, progress: false });
    }

    if (delta.type === "references") {
      this.transition({ references: delta.items });
    }
  }

  private transition(diff: Partial<AskContext>) {
    this.ctx = { ...this.ctx, ...diff };
  }
}
