import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { askContext } from "../contexts";

import type { AskContext } from "../types";
import { createEvent, TaskStatus } from "../store";
import { input } from "../styles";

const NAME = "canary-ask-input";

@customElement(NAME)
export class CanaryAskInput extends LitElement {
  @property({ type: String })
  query = "";

  @consume({ context: askContext, subscribe: true })
  @state()
  private _ask?: AskContext;

  render() {
    return html`
      <input
        type="text"
        value=${this.query}
        autocomplete="off"
        spellcheck="false"
        placeholder="Ask anything..."
        @input=${this._handleInput}
        @keydown=${this._handleKeyDown}
        autofocus
        onfocus="this.setSelectionRange(this.value.length,this.value.length);"
      />
      ${this._ask?.status === TaskStatus.PENDING
        ? html`<canary-loading-spinner></canary-loading-spinner>`
        : nothing}
    `;
  }

  static styles = [
    input,
    css`
      span {
        font-size: 10px;
        color: var(--canary-color-gray-30);
      }
    `,
  ];

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    this.query = input.value;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Enter") {
      e.preventDefault();
      this.dispatchEvent(createEvent({ type: "set_query", data: this.query }));
    }
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskInput;
  }
}
