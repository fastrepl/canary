import { LitElement, css, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { consume } from "@lit/context";
import { queryContext, askContext } from "../contexts";

import type { AskContext } from "../types";
import { createEvent, TaskStatus } from "../store";
import { input } from "../styles";

const NAME = "canary-ask-input";

@customElement(NAME)
export class CanaryAskInput extends LitElement {
  @property({ type: Boolean })
  autofocus = false;

  @consume({ context: queryContext, subscribe: true })
  @property({ type: String })
  query = "";

  @consume({ context: askContext, subscribe: true })
  @state()
  private _ask?: AskContext;

  render() {
    return html`
      <input
        type="text"
        part="input"
        value=${this.query}
        autocomplete="off"
        spellcheck="false"
        placeholder="Ask anything..."
        @input=${this._handleInput}
        @keydown=${this._handleKeyDown}
        onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        autofocus=${ifDefined(this.autofocus || null)}
      />
        class=${classMap({
          hidden: this._ask?.status !== TaskStatus.PENDING,
        })}
      >
        <slot name="loading">
          <canary-loading-spinner></canary-loading-spinner>
        </slot>
      </span>
    `;
  }

  static styles = [
    input,
    css`
      .hidden {
        visibility: hidden;
      }

      span {
        font-size: 0.625rem;
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
      e.stopPropagation();
      this.dispatchEvent(createEvent({ type: "set_query", data: this.query }));
    }
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskInput;
  }
}
