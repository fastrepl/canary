import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { scrollContainer } from "./styles";
import type { Reference } from "./types";

import { SearchController, KeyboardSelectionController } from "./controllers";

import "./canary-reference";
import "./canary-reference-skeleton";
import "./canary-error";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  private search = new SearchController(this);
  private selection = new KeyboardSelectionController<Reference>(this, {
    handleEnter: (item) => {
      window.open(item.url, "_blank");
    },
  });

  render() {
    return html`
      <div class="container">
        ${this.search.render({
          initial: () =>
            html` <div class="skeleton-container">
              ${Array(4).fill(
                html`<canary-reference-skeleton></canary-reference-skeleton>`,
              )}
            </div>`,
          pending: () =>
            html` <div class="skeleton-container">
              ${Array(5).fill(
                html`<canary-reference-skeleton></canary-reference-skeleton>`,
              )}
            </div>`,
          complete: (references) => {
            this.selection.items = references;

            return html`${references.map(
              ({ title, url, excerpt }, index) => html`
                <canary-reference
                  title=${title}
                  url=${url}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${index === this.selection.index}
                  @mouseover=${() => {
                    this.selection.index = index;
                  }}
                ></canary-reference>
              `,
            )}`;
          },
          error: () => html`<canary-error></canary-error>`,
        })}
      </div>
    `;
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
