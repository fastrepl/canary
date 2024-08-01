import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext } from "../contexts";
import type { QueryContext } from "../types";

import { input } from "../styles";
import "./canary-hero-icon";

const NAME = "canary-search-input";

@customElement(NAME)
export class CanarySearchInput extends LitElement {
  @consume({ context: queryContext, subscribe: false })
  @property({ reflect: true })
  query: QueryContext = "";

  render() {
    return html`
      <div class="container">
        <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
        <input
          type="text"
          value=${this.query}
          autocomplete="off"
          spellcheck="false"
          placeholder="Search for anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          autofocus
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        />
      </div>
    `;
  }

  static styles = input;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;

    this.query = input.value;
    this.updateComplete.then(() => {
      this.dispatchEvent(
        new CustomEvent("input-change", {
          detail: input.value,
          bubbles: true,
          composed: true,
        }),
      );
    });
  }

  private _handleKeyDown(e: KeyboardEvent) {
    const opts = { bubbles: true, composed: true };

    switch (e.key) {
      case "Enter":
        e.preventDefault();
        this.dispatchEvent(new CustomEvent("input-enter", opts));
        break;
      case "Tab":
        e.preventDefault();
        this.dispatchEvent(new CustomEvent("input-tab", opts));
        break;
    }
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchInput;
  }
}
