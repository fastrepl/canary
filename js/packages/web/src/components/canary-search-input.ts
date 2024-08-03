import { LitElement, html, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext, searchContext } from "../contexts";
import type { QueryContext, SearchContext } from "../types";

import { input } from "../styles";
import { TaskStatus } from "../constants";
import { customEvent } from "../events";

import "./canary-loading-spinner";

const NAME = "canary-search-input";

@customElement(NAME)
export class CanarySearchInput extends LitElement {
  @consume({ context: queryContext, subscribe: false })
  @state()
  private _query!: QueryContext;

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search!: SearchContext;

  render() {
    return html`
      <input
        type="text"
        value=${this._query}
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

    this._query = input.value;
    this.updateComplete.then(() => {
      this.dispatchEvent(
        customEvent({ name: "input-change", data: input.value }),
      );
    });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchInput;
  }
}
