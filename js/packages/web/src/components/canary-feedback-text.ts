import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

const NAME = "canary-feedback-text";

@customElement(NAME)
export class CanaryFeedbackText extends LitElement {
  @property({ type: String }) name = "Field";
  @property({ type: String }) value = "";
  @property({ type: String }) placeholder = "";

  render() {
    return html`
      <div class="container">
        <label for=${this.name}>${this.name}</label>
        <input
          type="text"
          id=${this.name}
          value=${this.value}
          placeholder=${this.placeholder}
        />
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
      input {
        padding: 8px;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;

        color: var(--canary-color-gray-10);
        background-color: var(--canary-is-light, var(--canary-color-gray-95))
          var(--canary-is-dark, var(--canary-color-gray-80));
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFeedbackText;
  }
}
