import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

import { GITHUB_REPO_URL } from "../constants";

const NAME = "canary-footer";

@customElement(NAME)
export class CanaryFooter extends LitElement {
  render() {
    return html`
      <div class="container">
        Powered by
        <a href=${GITHUB_REPO_URL} target="_blank">🐤 Canary</a>
      </div>
    `;
  }

  static styles = css`
    .container {
      text-align: end;
      font-size: 0.75rem;
      color: var(--canary-color-gray-20);
    }

    a {
      color: var(--canary-color-gray-20);
    }
    a:hover {
      color: var(--canary-color-gray-10);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFooter;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
