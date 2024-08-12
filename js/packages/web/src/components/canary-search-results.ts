import { LitElement, html, nothing } from "lit";
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
  @property({ type: Boolean })
  group = false;

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
    if (!this._search) {
      return nothing;
    }

    if (this._search.status === TaskStatus.COMPLETE) {
      this._selection.items = this._search.result.search;
    }

    return html`
      ${this._search.status === TaskStatus.ERROR
        ? html`<canary-error></canary-error>`
        : html`<canary-search-references
            .group=${this.group}
            .selected=${this._selection.index}
            .references=${this._search.result.search}
          ></canary-search-references>`}
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
