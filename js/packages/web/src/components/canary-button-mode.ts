import { LitElement, css, html } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { createEvent } from "../store";

const NAME = "canary-button-mode";

@registerCustomElement(NAME)
export class CanaryModeButton extends LitElement {
  @property({ type: String }) text = "";
  @property({ type: String }) mode = "";

  render() {
    return html`
      <button type="button" @click=${this._handleClick}>
        <slot name="icon"></slot>
        <span>${this.text}</span>
      </button>
    `;
  }

  private _handleClick() {
    this.dispatchEvent(createEvent({ type: "set_mode", data: this.mode }));
  }

  static styles = css`
    button {
      display: flex;
      align-items: center;
      gap: 8px;

      width: calc(100% - 24px);
      align-self: center;
      margin-right: 12px;
      margin-left: 12px;
      padding: 8px 12px;

      border-radius: 8px;

      border: 1px solid var(--canary-is-light, var(--canary-color-gray-95))
        var(--canary-is-dark, var(--canary-color-gray-70));

      color: var(--canary-is-light, var(--canary-color-gray-20))
        var(--canary-is-dark, var(--canary-color-gray-20));

      background-color: var(--canary-color-gray-100);
    }
    button:hover {
      background-color: var(--canary-is-light, var(--canary-color-gray-95))
        var(--canary-is-dark, var(--canary-color-gray-80));
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryModeButton;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
