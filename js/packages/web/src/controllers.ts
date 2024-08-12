import {
  nothing,
  ReactiveController,
  ReactiveControllerHost,
  type TemplateResult,
} from "lit";

import { ContextConsumer } from "@lit/context";
import { queryContext } from "./contexts";

import type { QueryContext, TriggerShortcut } from "./types";

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
