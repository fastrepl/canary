import { LitElement, html, css, noChange } from "lit";
import { customElement } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { scrollContainer } from "./styles";
import type { Reference } from "./types";

import { SearchController, KeyboardSelectionController } from "./controllers";

import "./canary-error";
import "./canary-reference";
import "./canary-reference-skeleton";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  private search = new SearchController(this);
  private selection = new KeyboardSelectionController<Reference>(this, {
    handleEnter: (item) => {
      window.open(item.url, "_blank");
    },
  });

  private _references: Reference[] | null = null;

  render() {
    return html`
      <div class="container">
        ${this.search.render({
          error: () => html`<canary-error></canary-error>`,
          pending: () => this._results(),
          complete: (references) => {
            if (!references) {
              return noChange;
            }

            this.selection.items = references;
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

    return html`${this._references.map(
      ({ title, url, excerpt }, index) => html`
        <canary-reference
          title=${title}
          url=${url}
          excerpt=${ifDefined(excerpt)}
          ?selected=${index === this.selection.index}
        ></canary-reference>
      `,
    )}`;
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
