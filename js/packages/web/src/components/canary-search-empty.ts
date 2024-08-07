import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

const NAME = "canary-search-empty";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  render() {
    return html`
      <div class="container">
        <p>No results found.</p>
      </div>
    `;
  }

  static styles = css`
    .container {
      padding: 0px 12px;
    }

    p {
      cursor: default;
      margin-inline-start: 4px;
      margin-block-start: 4px;
      margin-block-end: 4px;
      font-size: 14px;
      color: var(--canary-color-gray-40);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
