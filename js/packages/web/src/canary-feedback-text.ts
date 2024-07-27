import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

const NAME = "canary-feedback-text";

@customElement(NAME)
export class CanaryFeedbackText extends LitElement {
  @state() done = false;
  render() {
    if (this.done) {
      return nothing;
    }

    return html`
      <div class="container">
        <textarea autofocus></textarea>
        <button>Send Feedback</button>
      </div>
    `;
  }

  static styles = [
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 2px;

        padding: 1px;
        width: 300px;

        background-color: var(--canary-color-gray-95);
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;
      }

      textarea {
        width: 100%;
        font-size: 16px;
        height: 160px;
        resize: none;
        outline: none;
        padding: 8px;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;
        background-color: var(--canary-color-gray-100);
        color: var(--canary-color-gray-10);
      }

      button {
        cursor: pointer;
        padding: 8px;
        width: 100%;
        border: 1px solid var(--canary-color-primary-90);
        border-radius: 8px;
        font-weight: bold;
        color: var(--canary-color-gray-0);

        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-70));
      }
      button:hover {
        background-color: var(--canary-is-light, var(--canary-color-primary-90))
          var(--canary-is-dark, var(--canary-color-primary-60));
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
    [NAME]: CanaryFeedbackText;
  }
}
