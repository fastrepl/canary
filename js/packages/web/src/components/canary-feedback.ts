import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { MODAL_CLOSE_EVENT } from "./canary-modal";

const NAME = "canary-feedback";

@customElement(NAME)
export class CanaryFeedback extends LitElement {
  @property({ type: String }) title = "Submit feedback";

  render() {
    return html`
      <div class="container">
        <slot name="header">
          <h2>${this.title}</h2>
        </slot>
        <slot></slot>
        <slot name="actions">
          <div class="actions">
            <button class="cancel" @click=${this._handleCancel}>Cancel</button>
            <button class="send" @click=${this._handleSend}>Send</button>
          </div>
        </slot>
      </div>
    `;
  }
  private _handleCancel() {
    this.dispatchEvent(
      new CustomEvent(MODAL_CLOSE_EVENT, { bubbles: true, composed: true }),
    );
  }
  private _handleSend() {}

  static styles = [
    css`
      .container {
        width: 300px;
        font-size: 0.875rem;
        background-color: var(--canary-is-light, var(--canary-color-gray-100))
          var(--canary-is-dark, var(--canary-color-gray-70));

        display: flex;
        flex-direction: column;
        gap: 12px;

        padding: 12px;
        border: 1px solid var(--canary-color-gray-20);
        border-radius: 8px;
      }
    `,
    css`
      h2 {
        margin: 0px 0px 12px 0px;
        font-size: 18px;
        color: var(--canary-color-gray-10);
      }
    `,
    css`
      .actions {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: flex-end;
        gap: 4px;
      }

      button {
        cursor: pointer;
        width: 60px;
        font-weight: 500;

        padding: 8px;
        border: 1px solid var(--canary-color-gray-60);
        border-radius: 8px;
      }

      button.send {
        color: var(--canary-color-gray-90);
        background-color: var(--canary-color-gray-10);
      }

      button.cancel {
        color: var(--canary-color-gray-10);
        background-color: var(--canary-color-gray-90);
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFeedback;
  }
}
