import { LitElement, html, css, noChange, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ref, createRef } from "lit/directives/ref.js";

import type { SearchReference } from "../types";
import { scrollContainer } from "../styles";
import { DEBOUNCE_MS, MODE_SEARCH } from "../constants";
import { SearchController, KeyboardSelectionController } from "../controllers";

import "./canary-error";
import "./canary-search-references";
import "./canary-reference-skeleton";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  readonly MODE = MODE_SEARCH;

  @property({ type: Boolean }) group = false;

  private _ref = createRef<HTMLElement>();

  private _search = new SearchController(this, {
    mode: this.MODE,
    debounceTimeoutMs: DEBOUNCE_MS,
  });

  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(
        new CustomEvent("close", { bubbles: true, composed: true }),
      );
      window.location.href = item.url;
    },
  });

  private _references: SearchReference[] | null = null;

  render() {
    return html`
      <div ${ref(this._ref)} class="container">
        ${this._search.render({
          error: () => html`<canary-error></canary-error>`,
          pending: () => this._results(),
          complete: (references) => {
            if (!references) {
              return noChange;
            }
            if (this._ref.value) {
              this._ref.value.scrollTop = 0;
            }

            this._selection.items = references;
            this._references = references;

            return this._results();
          },
        })}
      </div>
    `;
  }

  private _results() {
    if (!this._references) {
      return this._search.query ? this._skeletons(5) : nothing;
    }

    return html`<canary-search-references
      .group=${this.group}
      .selected=${this._selection.index}
      .references=${this._references}
    ></canary-search-references>`;
  }

  private _skeletons(n: number) {
    return html` <div class="skeleton-container">
      ${Array(n).fill(
        html`<canary-reference-skeleton></canary-reference-skeleton>`,
      )}
    </div>`;
  }

  static styles = [
    scrollContainer,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        max-height: 425px;
      }
      .skeleton-container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        height: 425px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
