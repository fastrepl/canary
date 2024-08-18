import {
  nothing,
  ReactiveController,
  ReactiveControllerHost,
  type TemplateResult,
} from "lit";

import { ContextConsumer } from "@lit/context";
import { queryContext } from "./contexts";

import type { QueryContext, TriggerShortcut } from "./types";

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
