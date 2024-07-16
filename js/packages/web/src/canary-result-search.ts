import { LitElement, html, css } from "lit";
import { customElement, state, property } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { type Reference } from "./core";
import "./canary-reference";

import { consume } from "@lit/context";
import { searchReferencesContext } from "./contexts";

import { StringRegexRecord } from "./converters";

@customElement("canary-result-search")
export class CanaryResultSearch extends LitElement {
  @consume({ context: searchReferencesContext, subscribe: true })
  @state()
  items: Reference[] = [];

  @state() selectedIndex = 0;

  @property({ converter: StringRegexRecord, reflect: true })
  groups = {};

  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("keydown", this._handleNavigation);
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this._handleNavigation);
    super.disconnectedCallback();
  }

  render() {
    return html`
      <div class="container">
        ${this.items.map(
          ({ title, url, excerpt }, index) => html`
            <canary-reference
              title=${title}
              url=${url}
              excerpt=${ifDefined(excerpt)}
              ?selected=${index === this.selectedIndex}
              @mouseover=${() => {
                this.selectedIndex = index;
              }}
            ></canary-reference>
          `,
        )}
      </div>
    `;
  }

  private _handleNavigation = (e: KeyboardEvent) => {
    switch (e.key) {
      case "ArrowUp":
        e.preventDefault();
        this._moveSelection(-1);
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveSelection(1);
        break;
      case "Enter":
        e.preventDefault();

        const item = this.items?.[this.selectedIndex];
        if (item) {
          window.open(item.url, "_blank");
        }
        break;
    }
  };

  private _moveSelection(delta: number) {
    const next = this.selectedIndex + delta;
    if (next > -1 && next < this.items.length) {
      this.selectedIndex = next;
    }
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 8px;
      max-height: 50vh;
      overflow-y: hidden;
    }

    .container:hover {
      overflow-y: auto;
    }
  `;
}
