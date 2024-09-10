import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";

import type { SearchContext } from "../types";
import { TaskStatus } from "../store/managers";

import "./canary-error";
import "./canary-search-references";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @property({ type: String })
  header = "";

  @property({ type: Boolean })
  group = false;

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  render() {
    if (!this._search) {
      return nothing;
    }

    const references = Object.values(this._search.result.references).flat();

    if (references.length === 0) {
      return nothing;
    }

    return html`
      ${
        this._search.status === TaskStatus.ERROR
          ? html`<canary-error></canary-error>`
          : html` <div class="container">
              <canary-search-references
                .group=${this.group}
                .references=${references}
              ></canary-search-references>
            </div>`
      }
          </div>
      </div>
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
