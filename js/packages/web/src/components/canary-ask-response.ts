import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { AskResponse } from "../types";

import "./canary-markdown";
import "./canary-ask-block-reference";

const NAME = "canary-ask-response";

@customElement(NAME)
export class CanaryAskResponse extends LitElement {
  @property({ type: Object })
  response!: AskResponse;

  render() {
    return html`
      <div class="container">
        ${this.response.blocks.map((block) => {
          if (block.type === "reference") {
            return html`
              <canary-ask-block-reference
                .block=${block}
              ></canary-ask-block-reference>
            `;
          } else {
            return html`<div>${block.text}</div>`;
          }
        })}
      </div>
    `;
  }

  static styles = [
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 1rem;
        background-color: var(--canary-color-gray-100);
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskResponse;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
