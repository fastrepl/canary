import { LitElement, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext, searchContext } from "../contexts";
import type { SearchContext } from "../types";

import { input } from "../styles";
import { TaskStatus } from "../store/managers";

import "./canary-loading-spinner";
import { createEvent } from "../store";

const NAME = "canary-search-input";

@customElement(NAME)
export class CanarySearchInput extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @property({ type: String })
  query = "";

  @state()
  private _query = "";

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  private _timer: ReturnType<typeof setTimeout> | null = null;

  connectedCallback(): void {
    super.connectedCallback();
    this.dispatchEvent(createEvent({ type: "set_query", data: this.query }));
  }

  updated(changed: Map<string, any>) {
    if (changed.has("query")) {
      this._query = this.query;
    }
  }

  render() {
    if (!this._search) {
      return nothing;
    }

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
    const DEBOUNSE_MS = 50;

    const input = e.target as HTMLInputElement;
    this._query = input.value;

    if (this._timer) {
      clearTimeout(this._timer);
    }
    this._timer = setTimeout(() => {
      this.dispatchEvent(createEvent({ type: "set_query", data: input.value }));
    }, DEBOUNSE_MS);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchInput;
  }
}
