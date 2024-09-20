import { LitElement, html, css, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import type { ExecutionContext } from "../types";
import { executionContext } from "../contexts";

import { StringArray } from "../converters";
import { MODE_ASK } from "../constants";

import "./canary-markdown";
import "./canary-loading-dots";

const NAME = "canary-ask-results";

@customElement(NAME)
export class CanaryAskResults extends LitElement {
  readonly MODE = MODE_ASK;

  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  @property({ converter: StringArray })
  languages = ["javascript", "python"];

  render() {
    if (!this._execution?.ask) {
      return nothing;
    }

    return html`
      <div class="container">
        <canary-markdown
          .languages=${this.languages}
          .content=${this._execution.ask.response}
        ></canary-markdown>
      </div>
    `;
  }

  static styles = [
    css`
      .container {
        margin-top: 8px;
      }

      .references {
        display: flex;
        flex-direction: column;
        gap: 6px;
        padding-top: 16px;
        padding-bottom: 8px;
      }

      h2 {
        font-size: 1.25rem;
        margin: 10px 0px 20px 0px;
        color: var(--canary-color-gray-0);
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskResults;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
