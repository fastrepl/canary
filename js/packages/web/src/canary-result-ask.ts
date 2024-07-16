import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { askReferencesContext, askResponseContext } from "./contexts";

import { type Reference } from "./core";

import "./canary-markdown";
import "./canary-reference";
import "./canary-loading-dots";

@customElement("canary-result-ask")
export class CanaryResultAsk extends LitElement {
  @consume({ context: askResponseContext, subscribe: true })
  @property({ attribute: false })
  response = "";

  @consume({ context: askReferencesContext, subscribe: true })
  @property({ attribute: false })
  references: Reference[] = [];

  @property() hljs = "github";
  @state() loading = false;

  render() {
    return html`
      <div class="container">
        ${this.loading
          ? html`<canary-loading-dots></canary-loading-dots>`
          : this._notLoading()}
      </div>
    `;
  }

  private _notLoading() {
    return html` <canary-markdown
        .hljs=${this.hljs}
        .content=${this.response}
      ></canary-markdown>
      <div class="references">
        ${this.references.map(
          (reference) =>
            html` <canary-reference
              title=${reference.title}
              url=${reference.url}
            ></canary-reference>`,
        )}
      </div>`;
  }

  static style = css`
    .container {
      border: 1px solid var(--canary-color-gray-6);
      border-radius: 8px;
      padding: 0px 12px;
    }

    .references {
      display: flex;
      flex-direction: column;
      gap: 6px;
      padding-bottom: 8px;
    }
  `;
}
