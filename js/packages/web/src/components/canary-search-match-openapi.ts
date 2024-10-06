import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-search-match-base";

import { SearchResult } from "../types";
import { global } from "../styles";

const NAME = "canary-search-match-openapi";

/**
 * @private NOT DONE YET
 */
@customElement(NAME)
export class CanarySearchMatchOpenAPI extends LitElement {
  @property({ type: Object })
  match!: SearchResult;

  render() {
    if (this.match.type !== "openapi") {
      throw new Error();
    }

    return html`
      <div class="container" part="container">
        <canary-search-match-base
          url=${this.match.url}
          exportparts="container:match-item"
        >
          <div slot="title" class="p">
            <span>POST</span>
            <span class="path">/job/openapi</span>
          </div>
        </canary-search-match-base>
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
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 6px;
      }

      .sub-results {
        display: flex;
        flex-direction: column;
        gap: 4px;
        margin-top: 4px;
      }

      .sub-result {
        display: flex;
        gap: 4px;
        align-items: center;
      }
      .sub-result:hover {
        text-decoration: underline;
      }

      .i-heroicons-arrow-turn-down-right-solid {
        opacity: 0.4;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchMatchOpenAPI;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
