import { LitElement, html, css, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import type { AskContext } from "../types";
import { askContext } from "../contexts";

import { StringArray } from "../converters";
import { MODE_ASK } from "../constants";

import "./canary-markdown";
import "./canary-reference";
import "./canary-loading-dots";

const NAME = "canary-ask-results";

@customElement(NAME)
export class CanaryAskResults extends LitElement {
  readonly MODE = MODE_ASK;

  @consume({ context: askContext, subscribe: true })
  @state()
  private _ask?: AskContext;

  @property({ converter: StringArray })
  languages = ["javascript", "python"];

  render() {
    if (!this._ask) {
      return nothing;
    }

    return html`
      <div class="container">
        <canary-markdown
          .languages=${this.languages}
          .content=${this._ask.response}
        ></canary-markdown>

        <div class="references">
          ${this._ask.references.map(
            (reference) =>
              html` <canary-reference
                title=${reference.title}
                url=${reference.url}
              ></canary-reference>`,
          )}
        </div>
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
}
