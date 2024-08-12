import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import type { AskContext, AskReference, ThemeContext } from "../types";
import { askContext, themeContext } from "../contexts";

import { MODE_ASK } from "../constants";
import { scrollContainer } from "../styles";

import "./canary-markdown";
import "./canary-reference";
import "./canary-loading-dots";

const NAME = "canary-ask-results";

@customElement(NAME)
export class CanaryAskResults extends LitElement {
  readonly MODE = MODE_ASK;

  @consume({ context: themeContext, subscribe: true })
  @state()
  theme!: ThemeContext;

  @consume({ context: askContext, subscribe: true })
  @state()
  private _ask?: AskContext;

  render() {
    if (!this._ask) {
      return nothing;
    }

    return html`
      <div class="scroll-container">
        ${this._content(this._ask.response, this._ask.references)}
      </div>
    `;
  }

  private _content(response: string, references: AskReference[]) {
    return html`
      <canary-markdown
        .hljs=${this.theme === "dark" ? "github-dark" : "github"}
        .content=${response}
      ></canary-markdown>

      <div class="references">
        ${references.map(
          (reference) =>
            html` <canary-reference
              title=${reference.title}
              url=${reference.url}
            ></canary-reference>`,
        )}
      </div>
    `;
  }

  static styles = [
    scrollContainer,
    css`
      .scroll-container {
        border: 1px solid var(--canary-color-gray-95);
        border-radius: 8px;
      }

      .references {
        display: flex;
        flex-direction: column;
        gap: 6px;
        padding-top: 16px;
        padding-bottom: 8px;
      }

      h2 {
        font-size: 20px;
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
