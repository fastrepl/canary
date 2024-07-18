import { LitElement, html, css, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import {
  queryContext,
  modeContext,
  providerContext,
  type ProviderContext,
  type ModeContext,
} from "./contexts";

import { Task } from "@lit/task";
import type { Reference } from "./types";

import { randomInteger } from "./utils";

import "./canary-markdown";
import "./canary-reference";
import "./canary-loading-dots";

@customElement("canary-ask-results")
export class CanaryAskResults extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider!: ProviderContext;

  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query = "";

  @state() loading = false;
  @state() response = "";
  @state() references: Reference[] = [];

  @property() hljs = "github";

  private _task = new Task(this, {
    task: async ([query], { signal }) => {
      console.log(this.mode.current, query);
      if (this.mode.current !== "Ask" || query === "") {
        return null;
      }

      this.response = "";
      this.references = [];
      this.loading = true;

      await this.provider.ask(
        randomInteger(),
        query,
        (delta) => {
          this.loading = false;

          if (delta.type === "progress") {
            this.response += delta.content;
          }
          if (delta.type === "references") {
            this.references = delta.items;
          }
        },
        signal,
      );

      return null;
    },
    args: () => [this.query],
  });

  render() {
    return this.query === ""
      ? nothing
      : html`
          <div class="container">
            ${this._task.render({
              initial: () => html`<canary-loading-dots></canary-loading-dots>`,
              pending: () =>
                html`${this.loading
                  ? html`<canary-loading-dots></canary-loading-dots>`
                  : this._content()}`,
              complete: () =>
                html`${this.loading
                  ? html`<canary-loading-dots></canary-loading-dots>`
                  : this._content()}`,
            })}
          </div>
        `;
  }

  private _content() {
    return html`
      <canary-markdown
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
