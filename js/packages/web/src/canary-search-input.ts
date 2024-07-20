import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import { ModeContext, modeContext, queryContext } from "./contexts";

import { input } from "./styles";
import "./canary-hero-icon";

const NAME = "canary-search-input";

@customElement(NAME)
export class CanarySearchInput extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @property({ reflect: true })
  value = "";

  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode!: ModeContext;

  render() {
    return html`
      <div class="container">
        <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
        <input
          type="text"
          value=${this.value}
          autocomplete="off"
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

    const event = new CustomEvent("input-change", {
      detail: input.value,
      bubbles: true,
      composed: true,
    });
    this.dispatchEvent(event);
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
