import { LitElement, css, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { consume } from "@lit/context";
import { queryContext, executionContext } from "../contexts";
import type { ExecutionContext } from "../types";

import { TaskStatus } from "../store/managers";

import "./canary-loading-spinner";
import { createEvent } from "../store";
import { global, wrapper } from "../styles";

const NAME = "canary-input";

@customElement(NAME)
export class CanaryInput extends LitElement {
  @property({ type: Boolean })
  autofocus = false;

  @consume({ context: queryContext, subscribe: true })
  @state()
  private _query = "";

  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  render() {
    return html`
      <div class="container" part="container">
        <slot name="before">
          <div class="i-heroicons-magnifying-glass"></div>
        </slot>
        <input
          type="text"
          part="input"
          .value=${this._query}
          autocomplete="off"
          spellcheck="false"
          placeholder="Search for anything..."
          @input=${this._handleInput}
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
          autofocus=${ifDefined(this.autofocus || null)}
        />
        <span
          class=${classMap({
            hidden: this._execution?.status !== TaskStatus.PENDING,
          })}
        >
          <slot name="loading">
            <canary-loading-spinner></canary-loading-spinner>
          </slot>
        </span>
      </div>
    `;
  }

  private _handleInput(e: KeyboardEvent) {
    const data = (e.target as HTMLInputElement).value;
    this.dispatchEvent(createEvent({ type: "set_query", data }));
  }

  static styles = [
    global,
    wrapper,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 8px;
        padding: 1px 12px;
      }

      input {
        width: 100%;
        height: 30px;
        outline: none;
        border: none;
        font-size: 1rem;
        color: var(--canary-color-gray-10);
        background-color: var(--canary-color-gray-100);
      }

      input::placeholder {
        color: var(--canary-color-gray-40);
        font-size: 0.875rem;
      }

      .hidden {
        visibility: hidden;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryInput;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
