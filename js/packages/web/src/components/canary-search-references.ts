import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { groupSearchReferences, stripURL } from "../utils";
import type { SearchReference } from "../types";

const NAME = "canary-search-references";

import "./canary-reference";

@customElement(NAME)
export class CanarySearchReferences extends LitElement {
  @property({ type: Boolean })
  group = false;

  @property({ type: Array })
  references: SearchReference[] = [];

  render() {
    return html`<div class="container">
      ${this.group ? this._renderGroup() : this._render()}
    </div>`;
  }

  private _render() {
    return html`${this.references.map(
      ({ title, url, excerpt }) => html`
        <canary-reference
          url=${url}
          title=${title}
          excerpt=${ifDefined(excerpt)}
          ?selected=${false}
        ></canary-reference>
      `,
    )}`;
  }

  private _renderGroup() {
    return groupSearchReferences(this.references).map((group) => {
      if (group.title === null || group.items.length < 2) {
        return html`
          <div class="group single">
            ${group.items.map(
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

      const parent = group.items.find((item) => item.titles?.length === 0);
      const children = group.items.filter((item) => item.titles?.length);

      return html`
        <div class="group multiple">
          <canary-reference
            mode="parent"
            url=${stripURL(children[0].url)}
            title=${group.title}
            excerpt=${ifDefined(parent?.excerpt)}
          ></canary-reference>
          ${children.map(
            ({ url, title, excerpt }, i) => html`
              <canary-reference
                mode="child"
                url=${url}
                title=${title}
                excerpt=${ifDefined(excerpt)}
                ?selected=${false}
                ?last=${i === children.length - 1}
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
    .group.multiple {
      margin: 2px 0;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchReferences;
  }
}
