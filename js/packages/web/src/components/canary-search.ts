import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume, provide } from "@lit/context";
import { modeContext, searchContext } from "../contexts";
import { SearchController } from "../controllers";

import type { ModeContext, SearchContext } from "../types";
import { DEBOUNCE_MS, MODE_SEARCH, TaskStatus } from "../constants";
import { createEvent } from "../store";

import "./canary-mode-tabs";
import "./canary-search-empty";

const NAME = "canary-search";

@customElement(NAME)
export class CanarySearch extends LitElement {
  readonly MODE = MODE_SEARCH;

  @consume({ context: modeContext, subscribe: true })
  @state()
  private _mode!: ModeContext;

  @provide({ context: searchContext })
  @state()
  private _search: SearchContext = {
    status: TaskStatus.INITIAL,
    references: [],
  };

  private _searchTask = new SearchController(this, {
    mode: this.MODE,
    debounceTimeoutMs: DEBOUNCE_MS,
  });

  connectedCallback() {
    super.connectedCallback();
    this.dispatchEvent(createEvent({ type: "register_mode", data: this.MODE }));
  }

  updated() {
    if (this._search.status !== this._searchTask.status) {
      this._search = {
        status: this._searchTask.status,
        references: this._searchTask.references ?? this._search.references,
      };
    }
  }

  render() {
    return this._mode.current !== this.MODE
      ? nothing
      : html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input-before">
                <div class="icon i-heroicons-magnifying-glass"></div>
              </slot>
              <slot name="input"></slot>
              <slot name="input-after"></slot>
            </div>
            <div class="body">
              <div class="callouts">
                <slot name="callout"></slot>
              </div>
              <div class="results">
                <slot name="result"></slot>
                ${this.renderEmpty()}
              </div>
            </div>
          </div>
        `;
  }

  renderEmpty() {
    if (
      this._searchTask.status === TaskStatus.COMPLETE &&
      this._searchTask.query &&
      !this._searchTask.references?.length
    ) {
      return html`
        <slot name="empty">
          <canary-search-empty></canary-search-empty>
        </slot>
      `;
    }

    return nothing;
  }

  static styles = [
    css`
      @unocss-placeholder;

      .icon {
        color: var(--canary-color-gray-20);
      }
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
      }

      .input-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
        padding: 1px 12px;
      }

      .callouts {
        display: flex;
        flex-direction: column;
        padding: 0px 12px;
      }

      .results {
        display: flex;
        flex-direction: column;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
}
