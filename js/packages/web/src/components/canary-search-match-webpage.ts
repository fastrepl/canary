import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-search-match";
import "./canary-url-paths";
import "./canary-snippet";
import "./canary-icon-tree";

import { SearchResult } from "../types";
import { global } from "../styles";

const NAME = "canary-search-match-webpage";

@customElement(NAME)
export class CanarySearchMatchWebpage extends LitElement {
  @property({ type: Object })
  match!: SearchResult;

  render() {
    if (this.match.type !== "webpage") {
      throw new Error();
    }

    return html`
      <div class="container">
        <canary-search-match url=${this.match.url}>
          <canary-url-paths slot="url" .url=${this.match.url}>
          </canary-url-paths>
          <span slot="title-icon" class="i-heroicons-bookmark"></span>
          <canary-snippet slot="title" .value=${this.match.title}>
          </canary-snippet>
          <canary-snippet slot="excerpt" .value=${this.match.excerpt}>
          </canary-snippet>
        </canary-search-match>
        ${this.match.sub_results.map(
          (sub_result, i) => html`
            <canary-search-match>
              <canary-icon-tree
                slot="content-before"
                .last=${i === this.match.sub_results.length - 1}
              >
              </canary-icon-tree>
              <canary-snippet
                slot="title"
                class="title"
                .value=${sub_result.title}
              >
              </canary-snippet>
              <canary-snippet
                slot="excerpt"
                class="excerpt"
                .value=${sub_result.excerpt}
              >
              </canary-snippet>
            </canary-search-match>
          `,
        )}
      </div>
    `;
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchMatchWebpage;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
