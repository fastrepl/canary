import { LitElement, html, css } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";

const NAME = "canary-feedback-textarea";

@registerCustomElement(NAME)
export class CanaryFeedbackTextarea extends LitElement {
  @property({ type: String }) name = "Field";
  @property({ type: String }) value = "";
  @property({ type: String }) placeholder = "";

  render() {
    return html`
      <div class="container">
        <label for=${this.name}>${this.name}</label>
        <!-- prettier-ignore -->
        <textarea id=${this.name} placeholder=${this.placeholder}>
          ${this.value}
        </textarea>
      </div>
    `;
  }

  static styles = [
    css`
      .container {
        display: flex;
        flex-direction: column;
        border-radius: 8px;
        gap: 6px;
      }

      label {
        color: var(--canary-is-light, var(--canary-color-gray-30))
          var(--canary-is-dark, var(--canary-color-gray-20));
      }
    `,
    css`
      textarea {
        width: 100%;
        font-size: 1rem;
        height: 160px;
        resize: none;
        outline: none;
        padding: 8px;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;

        color: var(--canary-color-gray-10);
        background-color: var(--canary-is-light, var(--canary-color-gray-95))
          var(--canary-is-dark, var(--canary-color-gray-80));
      }
    `,
    css`
      textarea {
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        box-sizing: border-box;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFeedbackTextarea;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
