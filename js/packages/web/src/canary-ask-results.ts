import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { AskController } from "./controllers";

import "./canary-markdown";
import "./canary-reference";
import "./canary-loading-dots";

const NAME = "canary-ask-results";

@customElement(NAME)
export class CanaryAskResults extends LitElement {
  @property() hljs = "github";

  private ask = new AskController(this);

  render() {
    return html` <div class="container">
      ${this.ask.render({
        initial: () => html`<canary-loading-dots></canary-loading-dots>`,
        pending: () =>
          html`${this.ask.loading
            ? html`<canary-loading-dots></canary-loading-dots>`
            : this._content()}`,
        complete: () =>
          html`${this.ask.loading
            ? html`<canary-loading-dots></canary-loading-dots>`
            : this._content()}`,
      })}
    </div>`;
  }

  private _content() {
    return html`
      <canary-markdown
        .hljs=${this.hljs}
        .content=${this.ask.response}
      ></canary-markdown>

      <div class="references">
        ${this.ask.references.map(
          (reference) =>
            html` <canary-reference
              title=${reference.title}
              url=${reference.url}
            ></canary-reference>`,
        )}
      </div>
    `;
  }

  static styles = css`
    .container {
      border: 1px solid var(--canary-color-gray-6);
      border-radius: 8px;
      padding: 2px 12px;
    }

    .references {
      display: flex;
      flex-direction: column;
      gap: 6px;
      padding-bottom: 8px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskResults;
  }
}
