import {
  nothing,
  ReactiveController,
  ReactiveControllerHost,
  type TemplateResult,
} from "lit";
import { Task, StatusRenderer } from "@lit/task";

import { ContextConsumer } from "@lit/context";
import { operationContext, modeContext, queryContext } from "./contexts";

import {
  Mode,
  ModeContext,
  QueryContext,
  TriggerShortcut,
  OperationContext,
  AskReference,
  SearchReference,
} from "./types";
import { asyncSleep, randomInteger } from "./utils";

const wrapRenderer = <T>(renderer: StatusRenderer<T>) => {
  return {
    ...renderer,
    error: (e) => {
      console.error(e);
      return renderer?.error?.(e);
    },
  } as StatusRenderer<T>;
};

export class SearchController {
  private host: ReactiveControllerHost & HTMLElement;

  private _query: ContextConsumer<{ __context__: QueryContext }, any>;
  private _operation: ContextConsumer<{ __context__: OperationContext }, any>;
  private _mode: ContextConsumer<{ __context__: ModeContext }, any>;

  private _id = 0;
  private _debounceTimeoutMs: number;
  private _task: Task<
    [
      OperationContext["search"] | undefined,
      OperationContext["beforeSearch"] | undefined,
      Mode,
      string,
    ],
    SearchReference[] | null
  >;

  constructor(
    host: ReactiveControllerHost & HTMLElement,
    debounceTimeoutMs = 0,
  ) {
    (this.host = host).addController(this as ReactiveController);
    this._debounceTimeoutMs = debounceTimeoutMs;

    this._operation = new ContextConsumer(host, {
      context: operationContext,
      subscribe: true,
    });

    this._mode = new ContextConsumer(host, {
      context: modeContext,
      subscribe: true,
    });

    this._query = new ContextConsumer(host, {
      context: queryContext,
      subscribe: true,
    });

    this._task = new Task(
      host,
      async ([search, beforeSearch, mode, query], { signal }) => {
        if (!mode || mode !== Mode.Search || !query?.trim() || !search) {
          return null;
        }
        const id = ++this._id;
        beforeSearch?.(query);
        await asyncSleep(this._debounceTimeoutMs);

        if (id !== this._id) {
          return null;
        }

        const result = await search(query, signal);
        if (id !== this._id) {
          return null;
        }

        this._afterSearch(query, result);
        return result as SearchReference[] | null;
      },
      () => [
        this._operation.value?.search,
        this._operation.value?.beforeSearch,
        this._mode.value?.current,
        this._query.value,
      ],
    );
  }

  private _afterSearch(query: string, result: SearchReference[] | null) {
    const empty = query !== "" && result !== null && result.length === 0;

    this.host.dispatchEvent(
      new CustomEvent("empty", {
        bubbles: true,
        composed: true,
        detail: empty,
      }),
    );
  }

  get query() {
    return this._query.value;
  }

  render(renderFunctions: StatusRenderer<SearchReference[] | null>) {
    return this._task.render(wrapRenderer(renderFunctions));
  }
}

export class AskController {
  private host: ReactiveControllerHost;

  private _operation: ContextConsumer<{ __context__: OperationContext }, any>;
  private _mode: ContextConsumer<{ __context__: ModeContext }, any>;
  private _query: ContextConsumer<{ __context__: QueryContext }, any>;
  private _task: Task<[Mode, string], null>;

  loading = false;
  response: string = "";
  references: AskReference[] = [];

  constructor(host: ReactiveControllerHost & HTMLElement) {
    (this.host = host).addController(this as ReactiveController);

    this._operation = new ContextConsumer(host, {
      context: operationContext,
      subscribe: false,
    });

    this._mode = new ContextConsumer(host, {
      context: modeContext,
      subscribe: true,
    });

    this._query = new ContextConsumer(host, {
      context: queryContext,
      subscribe: true,
    });

    this._task = new Task(
      host,
      async ([mode, query], { signal }) => {
        const ask = this._operation.value?.ask;

        if (!mode || mode !== Mode.Ask || !query?.trim() || !ask) {
          return null;
        }

        this.setLoading();

        await ask(
          randomInteger(),
          query,
          (delta) => {
            this.setNotLoading();

            if (delta.type === "progress") {
              this.appendResponse(delta.content);
            }
            if (delta.type === "references") {
              this.appendReferences(delta.items);
            }
          },
          signal,
        );
        return null;
      },
      () => [this._mode.value?.current, this._query.value],
    );
  }

  setLoading() {
    this.loading = true;
    this.response = "";
    this.references = [];
    this.host.requestUpdate();
  }

  setNotLoading() {
    if (this.loading) {
      this.loading = false;
      this.host.requestUpdate();
    }
  }

  appendReferences(references: AskReference[]) {
    this.references = [...this.references, ...references];
    this.host.requestUpdate();
  }

  appendResponse(response: string) {
    this.response += response;
    this.host.requestUpdate();
  }

  render(renderFunctions: StatusRenderer<null>) {
    return this._task.render(wrapRenderer(renderFunctions));
  }
}

export class KeyboardSelectionController<T> {
  private host: ReactiveControllerHost;

  private _items: T[] = [];
  private _index = -1;
  private handleEnter?: (item: T) => void;

  constructor(
    host: ReactiveControllerHost,
    opts?: { handleEnter?: (item: T) => void },
  ) {
    (this.host = host).addController(this as ReactiveController);
    this.handleEnter = opts?.handleEnter;
  }

  hostConnected() {
    document.addEventListener("keydown", this._handleKeyDown);
  }

  hostDisconnected() {
    document.removeEventListener("keydown", this._handleKeyDown);
  }

  private _handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case "ArrowUp":
        e.preventDefault();
        this._moveSelection(-1);
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveSelection(1);
        break;
      case "Enter":
        if (this.handleEnter && this._items.length > 0) {
          this.handleEnter(this._items[this.index]);
        }
        break;
    }
  };

  private _moveSelection(delta: number) {
    const next = this._index + delta;
    this.index = next;
  }

  get index() {
    return this._index;
  }

  set index(index: number) {
    if (index < 0 || index >= this._items.length) {
      return;
    }

    this._index = index;
    this.host.requestUpdate();
  }

  set items(items: T[]) {
    if (items.length !== this._items.length) {
      this._index = 0;
    }

    this._items = items;
    this.host.requestUpdate();
  }
}

export class KeyboardTriggerController {
  private host: ReactiveControllerHost & HTMLElement;
  private _key: TriggerShortcut;

  constructor(
    host: ReactiveControllerHost & HTMLElement,
    key: TriggerShortcut,
  ) {
    (this.host = host).addController(this as ReactiveController);
    this._key = key;
  }

  hostConnected() {
    document.addEventListener("keydown", this._handleKeyDown);
  }

  hostDisconnected() {
    document.removeEventListener("keydown", this._handleKeyDown);
  }

  private _handleKeyDown = (e: KeyboardEvent) => {
    const isShortcut = () => {
      if (this._key === "cmdk") {
        return e.key === "k" && (e.metaKey || e.ctrlKey);
      }

      if (this._key === "slash") {
        return e.key === "/";
      }
    };

    if (isShortcut()) {
      e.preventDefault();

      this.host.dispatchEvent(
        new MouseEvent("click", {
          bubbles: true,
          cancelable: true,
        }),
      );
    }
  };
}

export class CalloutController {
  private _query: ContextConsumer<{ __context__: QueryContext }, any>;

  constructor(host: ReactiveControllerHost & HTMLElement) {
    host.addController(this as ReactiveController);

    this._query = new ContextConsumer(host, {
      context: queryContext,
      subscribe: true,
    });
  }

  render(
    fn: () => TemplateResult,
    options?: { forceShow?: boolean; keywords?: string[] },
  ) {
    const show =
      options?.forceShow ||
      (options?.keywords ?? []).some((keyword) =>
        (this._query.value ?? "").includes(keyword),
      );

    return show ? fn() : nothing;
  }
}
