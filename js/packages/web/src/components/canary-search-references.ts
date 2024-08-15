import { LitElement, html, css, type PropertyValues } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { groupSearchReferences } from "../utils";
import type { SearchReference } from "../types";

const NAME = "canary-search-references";

import "./canary-reference";

@customElement(NAME)
export class CanarySearchReferences extends LitElement {
  @property({ type: Boolean }) group = false;
  @property({ type: Number }) selected = 0;
  @property({ type: Array }) references: SearchReference[] = [];

  @state() _selectedRef: SearchReference | null = null;

  connectedCallback(): void {
    super.connectedCallback();
    this._selectedRef = this.references[this.selected];
  }

  render() {
    return html`<div class="container">
      ${this.group ? this._renderGroup() : this._render()}
    </div>`;
  }

  updated(changed: PropertyValues<this>) {
    const selected = changed.get("selected");
    if (selected !== undefined) {
      this._selectedRef = this.references[selected];
    }
  }

  private _render() {
    return html`${this.references.map(
      ({ title, url, excerpt }, index) => html`
        <canary-reference
          url=${url}
          title=${title}
          excerpt=${ifDefined(excerpt)}
          ?selected=${index === this.selected}
        ></canary-reference>
      `,
    )}`;
  }

  private _renderGroup() {
    return html`${groupSearchReferences(this.references).map((group) => {
      if (group.name === null) {
        return html`${group.items.map(
          ({ url, title, excerpt, index }) => html`
            <canary-reference
              url=${url}
              title=${title}
              excerpt=${ifDefined(excerpt)}
              ?selected=${index === this.selected}
            ></canary-reference>
          `,
        )}`;
      }

      return html` <label>${group.name}</label>
        ${group.items.map(
          ({ url, title, excerpt, index }) => html`
            <canary-reference
              url=${url}
              title=${title}
              excerpt=${ifDefined(excerpt)}
              ?selected=${index === this.selected}
            ></canary-reference>
          `,
        )}`;
    })}`;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    label {
      font-size: 1rem;
      margin-top: 4px;
      margin-left: 4px;
      color: var(--canary-color-gray-10);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchReferences;
  }
}
