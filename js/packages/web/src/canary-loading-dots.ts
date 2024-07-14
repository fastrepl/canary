import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

@customElement("canary-loading-dots")
export class CanaryLoadingDots extends LitElement {
  render() {
    return html`
      <svg viewBox="0 0 24 24" fill="currentColor">
        <circle class="dot" cx="4" cy="12" r="3" />
        <circle class="dot dot-delay-1" cx="12" cy="12" r="3" />
        <circle class="dot dot-delay-2" cx="20" cy="12" r="3" />
      </svg>
    `;
  }

  static styles = css`
    svg {
      width: 24px;
      padding-top: 8px;
      color: var(--canary-color-gray-2);
    }

    .dot {
      animation: spinner-bounce 1.05s infinite;
    }
    .dot-delay-1 {
      animation-delay: 0.1s;
    }
    .dot-delay-2 {
      animation-delay: 0.2s;
    }

    @keyframes spinner-bounce {
      0%,
      57.14% {
        animation-timing-function: cubic-bezier(0.33, 0.66, 0.66, 1);
        transform: translate(0);
      }
      28.57% {
        animation-timing-function: cubic-bezier(0.33, 0, 0.66, 0.33);
        transform: translateY(-6px);
      }
      100% {
        transform: translate(0);
      }
    }
  `;
}
