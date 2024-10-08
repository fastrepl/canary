import { LitElement, html, css } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";

import "./canary-tooltip";

const NAME = "canary-trigger-logo";

@registerCustomElement(NAME)
export class CanaryTriggerLogo extends LitElement {
  @property({ type: String }) text = "Search";

  render() {
    return html`
      <canary-tooltip text=${this.text}>
        <button aria-label=${this.text}>🐤</button>
      </canary-tooltip>
    `;
  }

  static styles = css`
    button {
      cursor: pointer;
      font-size: var(--canary-font-size-logo, 2rem);
      background-color: transparent;
      border: none;
      outline: none;
      padding: 0;
      margin: 0;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTriggerLogo;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
