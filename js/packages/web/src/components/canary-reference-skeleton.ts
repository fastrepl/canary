import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

const NAME = "canary-reference-skeleton";

@customElement(NAME)
export class CanaryReferenceSkeleton extends LitElement {
  render() {
    return html` <div class="skeleton"></div> `;
  }

  static styles = css`
    .skeleton {
      height: 100px;
      border: none;
      border-radius: 8px;
      padding: 12px 16px;
      background-color: var(--canary-color-gray-80);
    }

    .skeleton {
      animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
    }

    @keyframes pulse {
      0%,
      100% {
        opacity: 1;
      }
      50% {
        opacity: 0.5;
      }
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryReferenceSkeleton;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
