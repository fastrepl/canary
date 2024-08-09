import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

const NAME = "canary-error";

@customElement(NAME)
export class CanaryError extends LitElement {
  render() {
    return html`
      <div class="container">
        <div class="icon i-heroicons-exclamation-triangle"></div>
        <span>Sorry, something went wrong. Please try again later.</span>
      </div>
    `;
  }

  static styles = [
    css`
      @unocss-placeholder;

      .icon {
        color: var(--canary-color-gray-20);
      }
    `,
    css`
      div.container {
        display: flex;
        gap: 8px;
        align-items: center;

        width: calc(100% - 32px);
        padding: 8px 16px;

        border-radius: 8px;
        border: 1px solid var(--canary-color-gray-95);

        color: var(--canary-color-gray-10);
        font-size: 14px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryError;
  }
}
