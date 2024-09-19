import { LitElement, html, css, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { stripURL } from "../utils";
import type { SearchResult } from "../types";

const NAME = "canary-search-references";

import "./canary-reference";

@customElement(NAME)
export class CanarySearchReferences extends LitElement {
  @property({ type: Boolean })
  group = false;

  @property({ type: Array })
  references: SearchResult[] = [];

  render() {
    return html`<div class="container">
      ${this.group ? this._renderGroup() : this._render()}
    </div>`;
  }

  private _render() {
    return html`${this.references.flatMap(({ sub_results }) =>
      sub_results.map(
        ({ title, url, excerpt }) => html`
          <canary-reference
            url=${url}
            title=${title}
            excerpt=${ifDefined(excerpt)}
            ?selected=${false}
          ></canary-reference>
        `,
      ),
    )}`;
  }

  private _renderGroup() {
    return this.references.map((group) => {
      if (group.sub_results.length === 0) {
        return nothing;
      }

      if (group.title === null || group.sub_results.length < 2) {
        return html`
          <div class="group single" part="group">
            ${group.sub_results.map(
              ({ url, title, excerpt }) => html`
                <canary-reference
                  mode="none"
                  url=${url}
                  title=${title}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${false}
                ></canary-reference>
              `,
            )}
          </div>
        `;
      }

      return html`
        <div class="group multiple" part="group">
          <canary-reference
            mode="parent"
            url=${stripURL(group.url)}
            title=${group.title}
            excerpt=${ifDefined(group?.excerpt)}
          ></canary-reference>
          ${group.sub_results.map(
            ({ url, title, excerpt }, i) => html`
              <canary-reference
                mode="child"
                url=${url}
                title=${title}
                excerpt=${ifDefined(excerpt)}
                ?selected=${false}
                ?last=${i === group.sub_results.length - 1}
              ></canary-reference>
            `,
          )}
        </div>
      `;
    });
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .group {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchReferences;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
