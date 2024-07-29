import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { SearchController } from "./controllers";
import { consume } from "@lit/context";
import { queryContext } from "./contexts";

const NAME = "canary-search-empty";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @state()
  query: string = "";

  private search = new SearchController(this);

  render() {
    return html`
      <div class="container">
        ${this.search.render({
          complete: (references) => {
            if (this.query === "" || references?.length) {
              return nothing;
            }

            return html`<p>No results found.</p>`;
          },
        })}
      </div>
    `;
  }

  static styles = css`
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
