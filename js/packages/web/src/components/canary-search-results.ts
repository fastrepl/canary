import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";
import { KeyboardSelectionController } from "../controllers";

import type { SearchContext, SearchReference } from "../types";
import { TaskStatus } from "../store/managers";
import { MODAL_CLOSE_EVENT } from "./canary-modal";

import "./canary-error";
import "./canary-search-references";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @property({ type: String })
  header = "";

  @property({ type: Boolean })
  group = false;

  @property({ type: Number })
  limit = 12;

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(
        new CustomEvent(MODAL_CLOSE_EVENT, { bubbles: true, composed: true }),
      );
      window.location.href = item.url;
    },
  });

  render() {
    if (!this._search || this._search.result.search.length === 0) {
      return nothing;
    }

    const items = this._search.result.search.slice(0, this.limit);

    if (this._search.status === TaskStatus.COMPLETE) {
      this._selection.items = items;
    }

    return html`
      ${
        this._search.status === TaskStatus.ERROR
          ? html`<canary-error></canary-error>`
          : html` <div class="container">
              ${this.header && html`<div class="header">${this.header}</div>`}
              <div class="items">
                <canary-search-references
                  .group=${this.group}
                  .selected=${this._selection.index}
                  .references=${items}
                ></canary-search-references>
              </div>
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

      font-size: 0.875rem;
      color: var(--canary-color-gray-10);
    }

    .header {
      margin: 4px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
