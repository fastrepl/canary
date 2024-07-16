import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

@customElement("canary-reference-skeleton")
export class CanaryReferenceSkeleton extends LitElement {
  render() {
    return html` <div class="skeleton"></div> `;
  }

  static styles = css`
    .skeleton {
      height: 50px;
      border: none;
      border-radius: 8px;
      padding: 12px 16px;

      background-color: var(--canary-color-gray-5);
    }

    .skeleton:hover {
      background-color: var(--canary-color-gray-4);
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
