import { LitElement, html, css } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import type { ThemeContext } from "../types";
import { themeContext } from "../contexts";

import { MODE_ASK } from "../constants";
import { AskController } from "../controllers";
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

  private _ask = new AskController(this, { mode: this.MODE });

  render() {
    return html` <div class="scroll-container">
      <h2>${this._ask.query}</h2>

      ${this._ask.render({
        initial: () => html`<canary-loading-dots></canary-loading-dots>`,
        pending: () =>
          html`${this._ask.loading
            ? html`<canary-loading-dots></canary-loading-dots>`
            : this._content()}`,
        complete: () =>
          html`${this._ask.loading
            ? html`<canary-loading-dots></canary-loading-dots>`
            : this._content()}`,
      })}
    </div>`;
  }

  private _content() {
    return html`
      <canary-markdown
        .hljs=${this.theme === "dark" ? "github-dark" : "github"}
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
    `;
  }

  static styles = [
    scrollContainer,
    css`
      .scroll-container {
        width: calc(100% - 32px);
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
