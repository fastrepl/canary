import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import {
  defaultModeContext,
  ModeContext,
  modeContext,
  queryContext,
} from "./contexts";

import { input } from "./styles";
import "./canary-hero-icon";

@customElement("canary-input-ask")
export class CanaryInputAsk extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @property({ reflect: true })
  value = "";

  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode: ModeContext = defaultModeContext;

  render() {
    return html`
      <style>
        :host {
          flex-grow: ${this.mode.current === "Search" ? "0" : "1"};
          display: ${this.mode.current === "Search" ? "none" : "block"};
        }
      </style>

      <div class="container">
        <canary-hero-icon name="question-mark-circle"></canary-hero-icon>
        <input
          type="text"
          value=${this.value}
          autocomplete="off"
          placeholder="Ask anything..."
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
    this.value = input.value;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Enter") {
      e.preventDefault();
      const event = new CustomEvent("change", {
        detail: this.value,
        bubbles: true,
        composed: true,
      });
      this.dispatchEvent(event);

      this.value = "";
      (e.target as HTMLInputElement).value = "";
    }

    if (e.key === "Tab") {
      e.preventDefault();
      const event = new CustomEvent("tab", { bubbles: true, composed: true });
      this.dispatchEvent(event);
    }
  }
}
