import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { type Reference } from "./core";
import "./canary-reference";

@customElement("canary-search-results")
export class CanarySearchResults extends LitElement {
  @property({ attribute: false, type: Array }) items: Reference[] = [];
  @state() selectedIndex = 0;

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
