import { LitElement, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";
import type { SearchContext } from "../types";

import { input } from "../styles";
import { TaskStatus } from "../store/managers";

import "./canary-loading-spinner";
import { createEvent } from "../store";

const NAME = "canary-search-input";

@customElement(NAME)
export class CanarySearchInput extends LitElement {
  @property({ type: String })
  query = "";

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search!: SearchContext;

  connectedCallback(): void {
    super.connectedCallback();
    this.dispatchEvent(createEvent({ type: "set_query", data: this.query }));
  }

  render() {
    return html`
      <input
        type="text"
        value=${this.query}
        autocomplete="off"
        spellcheck="false"
        placeholder="Search for anything..."
        @input=${this._handleInput}
        autofocus
        onfocus="this.setSelectionRange(this.value.length,this.value.length);"
      />
      ${this._search.status === TaskStatus.PENDING
        ? html`<canary-loading-spinner></canary-loading-spinner>`
        : nothing}
    `;
  }

  static styles = input;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;

    this.query = input.value;
    this.updateComplete.then(() => {
      this.dispatchEvent(createEvent({ type: "set_query", data: input.value }));
    });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchInput;
  }
}
