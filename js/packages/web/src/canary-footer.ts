import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

import { GITHUB_REPO_URL } from "./constants";

@customElement("canary-footer")
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
      padding-top: 8px;
      text-align: end;
      font-size: 12px;
      color: var(--canary-color-gray-2);
      font-family: var(--canary-font-family);
    }

    a {
      color: var(--canary-color-gray-1);
    }
    a:hover {
      color: var(--canary-color-white);
    }
  `;
}
