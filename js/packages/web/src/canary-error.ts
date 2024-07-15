import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

import "./canary-hero-icon";

@customElement("canary-error")
export class CanaryError extends LitElement {
  render() {
    return html`
      <div class="container">
        <canary-hero-icon name="exclamation-triangle"></canary-hero-icon>
        <span>Sorry, something went wrong. Please try again later.</span>
      </div>
    `;
  }

  static styles = css`
    div.container {
      display: flex;
      gap: 8px;
      align-items: center;

      padding: 8px 16px;
      border-radius: 8px;
      border: 1px solid var(--canary-color-gray-6);

      color: var(--canary-color-white);
      font-family: var(--canary-font-family);
      font-size: 14px;
    }
  `;
}
