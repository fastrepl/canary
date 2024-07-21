import { ReactiveController, ReactiveControllerHost } from "lit";
import { Task, StatusRenderer } from "@lit/task";

import { ContextConsumer } from "@lit/context";
import { providerContext, modeContext, queryContext } from "./contexts";

import {
  ProviderContext,
  QueryProviderContext,
  Mode,
  ModeContext,
  Reference,
} from "./types";
import { randomInteger } from "./utils";

export class SearchController {
  private _provider: ContextConsumer<{ __context__: ProviderContext }, any>;
  private _mode: ContextConsumer<{ __context__: ModeContext }, any>;
  private _query: ContextConsumer<{ __context__: QueryProviderContext }, any>;
  private _task: Task<[Mode, string], Reference[]>;

  constructor(host: ReactiveControllerHost & HTMLElement) {
    host.addController(this as ReactiveController);

    this._provider = new ContextConsumer(host, {
      context: providerContext,
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
        const search = this._provider.value?.search;

        if (!mode || mode !== Mode.Search || !query?.trim() || !search) {
          return [];
        }

        const result = await search(query, signal);
        return result as Reference[];
      },
      () => [this._mode.value?.current, this._query.value],
    );
  }

  render(renderFunctions: StatusRenderer<Reference[]>) {
    return this._task.render(renderFunctions);
  }
}

export class AskController {
  private host: ReactiveControllerHost;

  private _provider: ContextConsumer<{ __context__: ProviderContext }, any>;
  private _mode: ContextConsumer<{ __context__: ModeContext }, any>;
  private _query: ContextConsumer<{ __context__: QueryProviderContext }, any>;
  private _task: Task<[Mode, string], null>;

  loading = false;
  response: string = "";
  references: Reference[] = [];

  constructor(host: ReactiveControllerHost & HTMLElement) {
    (this.host = host).addController(this as ReactiveController);

    this._provider = new ContextConsumer(host, {
      context: providerContext,
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
        const ask = this._provider.value?.ask;

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

  appendReferences(references: Reference[]) {
    this.references = [...this.references, ...references];
    this.host.requestUpdate();
  }

  appendResponse(response: string) {
    this.response += response;
    this.host.requestUpdate();
  }

  render(renderFunctions: StatusRenderer<null>) {
    return this._task.render(renderFunctions);
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
