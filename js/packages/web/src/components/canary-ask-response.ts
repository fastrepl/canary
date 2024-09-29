import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { AskResponse } from "../types";

import { global } from "../styles";

import "./canary-markdown";
import "./canary-ask-block-reference";
import "./canary-reference-skeleton";

const NAME = "canary-ask-response";

@customElement(NAME)
export class CanaryAskResponse extends LitElement {
  @property({ type: Object })
  response!: AskResponse;

  render() {
    if (
      !this.response ||
      !this.response?.blocks ||
      !this.response?.blocks?.length
    ) {
      return html`
        <div class="container">
          <canary-reference-skeleton></canary-reference-skeleton>
          <canary-reference-skeleton></canary-reference-skeleton>
        </div>
      `;
    }

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
            return html`<canary-markdown
              .content=${block.text}
            ></canary-markdown>`;
          }
        })}
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
        gap: 12px;
        background-color: var(--canary-color-gray-100);
        margin-bottom: 6px;
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
