import { LitElement, html, css, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { map } from "lit/directives/map.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";
import type { SearchContext } from "../types";

import { global } from "../styles";

const NAME = "canary-search-suggestions";

@customElement(NAME)
export class CanarySearchSuggestions extends LitElement {
  @property({ type: String })
  header = "Ask AI";

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
        <div class="header">${this.header}</div>
        <div class="items">
          ${map(
            questions,
            (message) => html`
              <div class="item">
                <span class="icon i-heroicons-chat-bubble-left"></span>
                <span class="message">${message}</span>
                <span class="icon i-heroicons-chevron-right arrow "></span>
              </div>
            `,
          )}
        </div>
      </div>
    `;
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
      }

      .items {
        display: flex;
        flex-direction: column;
        gap: 6px;
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
        padding: 4px 8px;
      }
      .item:hover {
        background-color: var(--canary-is-light, var(--canary-color-gray-90))
          var(--canary-is-dark, var(--canary-color-gray-90));
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
