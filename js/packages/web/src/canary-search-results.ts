import { LitElement, html, css, noChange } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { SearchReference } from "./types";
import { scrollContainer } from "./styles";
import { SearchController, KeyboardSelectionController } from "./controllers";

import "./canary-error";
import "./canary-search-references";
import "./canary-reference-skeleton";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @property({ type: Boolean }) group = false;

  private _search = new SearchController(this, 250);
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
      <div class="container">
        ${this._search.render({
          error: () => html`<canary-error></canary-error>`,
          pending: () => this._results(),
          complete: (references) => {
            if (!references) {
              return noChange;
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
      return this._skeletons(5);
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
