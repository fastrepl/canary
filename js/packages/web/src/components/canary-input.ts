import { LitElement, css, html, nothing, type PropertyValues } from "lit";
import { property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { consume } from "@lit/context";
import { queryContext, modeContext, executionContext } from "../contexts";
import type { ModeContext, ExecutionContext, QueryContext } from "../types";

import { registerCustomElement } from "../decorators";
import { global, wrapper } from "../styles";
import { TaskStatus } from "../store/managers";
import { createEvent } from "../store";
import { MODE_ASK, MODE_SEARCH } from "../constants";

import "./canary-loading-spinner";

const NAME = "canary-input";

/**
 * @csspart container - Container
 * @csspart input - Input
 * @slot before - Before
 * @slot action-search - Action search
 * @slot action-ask - Action ask
 * @slot loading - Loading
 */
@registerCustomElement(NAME)
export class CanaryInput extends LitElement {
  @property({ type: Boolean })
  autofocus = false;

  @consume({ context: queryContext, subscribe: true })
  @state()
  private _query: QueryContext = { text: "", tags: [], sources: [] };

  @consume({ context: modeContext, subscribe: true })
  @state()
  private _mode?: ModeContext;

  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  @state()
  private _showLoading = false;

  private _loadingDebounceTimer: number | null = null;

  updated(changed: PropertyValues) {
    if (changed.has("_execution")) {
      if (this._loadingDebounceTimer !== null) {
        clearTimeout(this._loadingDebounceTimer);
      }

      const next =
        this._execution?.status === TaskStatus.PENDING ||
        this._execution?.status === TaskStatus.ERROR;

      if (next) {
        this._showLoading = true;
        return;
      }

      this._loadingDebounceTimer = window.setTimeout(() => {
        this._showLoading = false;
      }, 100);
    }
  }

  render() {
    return html`
      <div class="container" part="container">
        <slot name="before">
          <div class="i-heroicons-magnifying-glass"></div>
        </slot>
        <input
          type="text"
          part="input"
          .value=${this._query.text}
          autocomplete="off"
          spellcheck="false"
          placeholder="Search for anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
          autofocus=${ifDefined(this.autofocus || null)}
        />
        <span
          class=${classMap({
            hidden: !(
              this._mode?.current === MODE_ASK &&
              this._execution?.status === TaskStatus.COMPLETE
            ),
          })}
        >
          <slot name="action-search"> ${this._renderDefaultSearch()} </slot>
        </span>
        <span
          class=${classMap({
            hidden: !(
              this._mode?.current === MODE_SEARCH &&
              this._execution?.status === TaskStatus.COMPLETE &&
              this._is_question(this._query.text)
            ),
          })}
        >
          <slot name="action-ask"> ${this._renderDefaultAsk()} </slot>
        </span>
        <span class=${classMap({ hidden: !this._showLoading })}>
          <slot name="loading">
            <canary-loading-spinner></canary-loading-spinner>
          </slot>
        </span>
      </div>
    `;
  }

  private _renderDefaultSearch() {
    return html`
      <div class="action">
        <span>Search</span>
        <span class="i-heroicons-backspace"></span>
      </div>
    `;
  }

  private _renderDefaultAsk() {
    if (!this._mode?.options.has(MODE_ASK)) {
      return nothing;
    }

    return html`
      <div class="action">
        <span>Ask AI</span>
        <kbd>Tab</kbd>
      </div>
    `;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (
      e.key === "Tab" &&
      this._mode?.current === MODE_SEARCH &&
      this._mode?.options.has(MODE_ASK) &&
      this._is_question(this._query.text)
    ) {
      e.preventDefault();
      this.dispatchEvent(createEvent({ type: "set_mode", data: MODE_ASK }));
    }
  }

  private _handleInput(e: KeyboardEvent) {
    const text = (e.target as HTMLInputElement).value;
    this.dispatchEvent(createEvent({ type: "set_query", data: { text } }));
  }

  private _is_question(query: string) {
    return query.split(" ").length > 2 || query.endsWith("?");
  }

  static styles = [
    global,
    wrapper,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 8px;
        padding: 1px 12px;
      }

      input {
        width: 100%;
        height: 30px;
        outline: none;
        border: none;
        font-size: 1rem;
        color: var(--canary-color-gray-10);
        background-color: var(--canary-color-gray-100);
      }

      input::placeholder {
        color: var(--canary-color-gray-40);
        font-size: 0.875rem;
      }

      .hidden {
        visibility: hidden;
      }
    `,
    css`
      .action {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 4px;
        font-size: 0.7rem;
        line-height: 1;
      }
      .action span {
        line-height: 1;
        white-space: nowrap;
        color: var(--canary-color-gray-60);
      }
      kbd {
        border: 1px solid var(--canary-color-gray-90);
        padding: 2px 4px;
        border-radius: 4px;

        color: var(--canary-is-light, var(--canary-color-gray-50))
          var(--canary-is-dark, var(--canary-color-gray-20));
      }

      span.i-heroicons-backspace {
        height: 1.5em;
        width: 1.5em;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryInput;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
