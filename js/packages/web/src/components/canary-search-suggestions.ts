import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";

import type { SearchContext } from "../types";
import { global } from "../styles";
import { createEvent } from "../store";
import { MODE_ASK } from "../constants";

const NAME = "canary-search-suggestions";

@customElement(NAME)
export class CanarySearchSuggestions extends LitElement {
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
        ${questions.map(
          (message) => html`
            <div class="item" @click=${() => this._handleClick(message)}>
              <span class="i-heroicons-chat-bubble-left"></span>
              <span class="message">${message}</span>
              <span class="arrow">
                Ask AI
              </span>
            </div>
          `,
        )}
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

        font-size: 0.875rem;
        color: var(--canary-color-gray-10);
      }

      .message {
        width: calc(100% - 2em);
      }

      .item {
        position: relative;
        cursor: pointer;

        display: flex;
        align-items: center;
        gap: 8px;
        padding: 4px 8px;
        border-radius: 6px;
      }
      .item:hover {
        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-70));
      }

      .arrow {
        position: absolute;
        right: 8px;
        opacity: 0;
        font-size: 0.75rem;
      }
      .item:hover .arrow {
        opacity: 0.6;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchSuggestions;
  }
}
