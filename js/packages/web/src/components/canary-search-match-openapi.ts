import { LitElement, html, css, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-search-match-base";
import "./canary-icon-tree";
import "./canary-badge";
import "./canary-snippet-title";
import "./canary-snippet-excerpt";

import { MODAL_CLOSE_EVENT } from "./canary-modal";
import { SearchResult } from "../types";
import { global } from "../styles";

const NAME = "canary-search-match-openapi";

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
          <canary-snippet-title
            slot="title"
            .value=${this.match.title}
          ></canary-snippet-title>
          <canary-snippet-excerpt
            slot="excerpt"
            .value=${this.match.excerpt}
          ></canary-snippet-excerpt>
          ${this._render_subs()}
        </canary-search-match-base>
      </div>
    `;
  }

  private _render_subs() {
    if (!this.match.sub_results.length) {
      return nothing;
    }

    return html` <div class="sub-results" slot="sub-results">
      ${this.match.sub_results.map(
        (result) =>
          html`<div
            class="sub-result"
            @click=${(e: MouseEvent) => this._handleClickSub(e, result.url)}
          >
            <span class="i-heroicons-arrow-turn-down-right-solid"></span>
            <canary-snippet-excerpt
              .value=${result.excerpt}
            ></canary-snippet-excerpt>
          </div>`,
      )}
    </div>`;
  }

  private _handleClickSub(e: MouseEvent, url: string) {
    e.stopPropagation();
    this.dispatchEvent(
      new CustomEvent(MODAL_CLOSE_EVENT, { bubbles: true, composed: true }),
    );
    window.location.href = url;
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
