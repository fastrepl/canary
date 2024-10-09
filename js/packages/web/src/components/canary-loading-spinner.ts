import { LitElement, html, css } from "lit";

import { registerCustomElement } from "../decorators";

const NAME = "canary-loading-spinner";

@registerCustomElement(NAME)
export class CanaryLoadingSpinner extends LitElement {
  render() {
    return html` <span class="loader"></span> `;
  }

  static styles = css`
    .loader {
      width: 12px;
      height: 12px;
      border: 1px solid var(--canary-color-gray-40);
      border-bottom-color: transparent;
      border-radius: 50%;
      display: inline-block;
      box-sizing: border-box;
      animation: rotation 1s linear infinite;
    }

    @keyframes rotation {
      0% {
        transform: rotate(0deg);
      }
      100% {
        transform: rotate(360deg);
      }
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryLoadingSpinner;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
