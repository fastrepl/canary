import { LitElement, html, css, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { map } from "lit/directives/map.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";

import type { SearchContext } from "../types";
import { global } from "../styles";
import { createEvent } from "../store";
import { MODE_ASK } from "../constants";

const NAME = "canary-search-suggestions";

@customElement(NAME)
export class CanarySearchSuggestions extends LitElement {
  @property({ type: String })
  header = "";

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  render() {
    const questions = this._search?.result.suggestion?.questions;
    if (!questions?.length) {
      return nothing;
    }

    return html`
      <div class="container">
        ${this.header && html`<div class="header">${this.header}</div>`}
        <div class="items">
          ${map(
            questions,
            (message) => html`
              <div class="item" @click=${() => this._handleClick(message)}>
                <span class="i-heroicons-chat-bubble-left"></span>
                <span class="message">${message}</span>
                <span class="i-heroicons-chevron-right arrow "></span>
              </div>
            `,
          )}
        </div>
      </div>
    `;
  }

  private _handleClick(message: string) {
    this.dispatchEvent(createEvent({ type: "set_query", data: message }));
    this.dispatchEvent(createEvent({ type: "set_mode", data: MODE_ASK }));
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

        font-size: 0.875rem;
        color: var(--canary-color-gray-10);
      }

      .header {
        margin: 4px;
        margin-bottom: -1px;
      }

      .items {
        display: flex;
        flex-direction: column;
      }

      .message {
        width: calc(100% - 2em);
      }

      .item {
        position: relative;
        cursor: pointer;

        display: flex;
        align-items: center;
        gap: 12px;
        padding: 6px 12px;
        border-radius: 8px;
      }
      .item:hover {
        background-color: var(--canary-is-light, var(--canary-color-gray-95))
          var(--canary-is-dark, var(--canary-color-gray-70));
      }

      .arrow {
        position: absolute;
        right: 8px;
        opacity: 0;
      }
      .item:hover .arrow {
        opacity: 0.5;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchSuggestions;
  }
}
