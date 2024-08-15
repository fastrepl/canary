import { LitElement, html, css, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import { modeContext, queryContext } from "../contexts";

import type { ModeContext, QueryContext } from "../types";
import { global } from "../styles";

import { createEvent } from "../store";
import { MODE_ASK } from "../constants";

const NAME = "canary-search-options";

@customElement(NAME)
export class CanarySearchOptions extends LitElement {
  @property({ type: String })
  header = "Suggested";

  @consume({ context: modeContext, subscribe: true })
  private _mode!: ModeContext;

  @consume({ context: queryContext, subscribe: true })
  private _query!: QueryContext;

  render() {
    if (this._mode.current !== this._mode.default || this._query.length > 0) {
      return nothing;
    }

    return html`
      <div class="container">
        <div class="header">${this.header}</div>
        <div class="items">
          <div class="item" @click=${() => this._handleClick(MODE_ASK)}>
            <span class="i-heroicons-chat-bubble-left"></span>
            <span>Ask AI Assistant</span>
          </div>
        </div>
      </div>
    `;
  }

  private _handleClick(mode: string) {
    this.dispatchEvent(createEvent({ type: "set_mode", data: mode }));
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 4px;

        width: 100%;
        padding: 0px 12px;

        font-size: 0.75rem;
        color: var(--canary-color-gray-40);
      }

      .items {
        display: flex;
        flex-direction: column;
        gap: 2px;

        font-size: 0.875rem;
      }

      .item {
        cursor: pointer;
        border: none;
        border-radius: 8px;
        padding: 6px 12px;
      }
      .item:hover {
        background-color: var(--canary-is-light, var(--canary-color-gray-90))
          var(--canary-is-dark, var(--canary-color-gray-60));
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchOptions;
  }
}
