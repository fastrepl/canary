import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ifDefined } from "lit/directives/if-defined.js";

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
  @property({ type: Boolean })
  autofocus = false;

  @consume({ context: queryContext, subscribe: true })
  @state()
  private _query = "";

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

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
        onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        autofocus=${ifDefined(this.autofocus || null)}
      />
      <span
        class=${classMap({
          hidden: this._search.status !== TaskStatus.PENDING,
        })}
      >
        <canary-loading-spinner></canary-loading-spinner>
      </span>
    `;
  }

  private _handleInput(e: KeyboardEvent) {
    this._query = (e.target as HTMLInputElement).value;
    this.dispatchEvent(createEvent({ type: "set_query", data: this._query }));
  }

  static styles = [
    input,
    css`
      .hidden {
        visibility: hidden;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchInput;
  }
}
