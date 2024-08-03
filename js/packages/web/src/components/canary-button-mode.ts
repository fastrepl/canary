import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { customEvent } from "../events";

import "./canary-hero-icon";

const NAME = "canary-button-mode";

@customElement(NAME)
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
    this.dispatchEvent(customEvent({ name: "mode-set", data: this.mode }));
  }

  static styles = css`
    button {
      display: flex;
      align-items: center;
      gap: 8px;

      width: 100%;
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
}
