import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { executionContext } from "../contexts";

import type { ExecutionContext } from "../types";
import { global } from "../styles";
import { createEvent } from "../store";
import { MODE_ASK } from "../constants";

const NAME = "canary-search-suggestions";

@customElement(NAME)
export class CanarySearchSuggestions extends LitElement {
  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  render() {
    const questions = this._execution?.search?.suggestion?.questions;
    if (!questions?.length) {
      return nothing;
    }

    return html`
      <div class="container">
        ${questions.map(
          (message) => html`
            <button class="item" @click=${() => this._handleClick(message)}>
              <span class="i-heroicons-chat-bubble-left"></span>
              <span class="message">${message}</span>
              <span class="arrow"> Ask AI </span>
            </button>
          `,
        )}
      </div>
    `;
  }

  private _handleClick(text: string) {
    this.dispatchEvent(createEvent({ type: "set_query", data: { text } }));
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
      }

      button {
        position: relative;
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 6px 8px;
        border-radius: 6px;
        border: none;

        color: var(--canary-is-light, var(--canary-color-gray-30))
          var(--canary-is-dark, var(--canary-color-gray-20));
        background-color: transparent;
      }
      button:hover {
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

      .message {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;

        font-size: 0.875rem;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchSuggestions;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
