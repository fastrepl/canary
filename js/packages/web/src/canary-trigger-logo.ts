import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

import "./canary-tooltip";

const NAME = "canary-trigger-logo";

@customElement(NAME)
export class CanaryTriggerLogo extends LitElement {
  render() {
    return html`
      <canary-tooltip text="Search">
        <button aria-label="Search">🐤</button>
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
}
