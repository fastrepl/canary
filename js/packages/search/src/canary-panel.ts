import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { Task } from "@lit/task";

import { type SearchResultItem } from "./types";

import "./icons/magnifying-glass";
import "./icons/question-mark-circle";
import "./canary-toggle";
import "./canary-input-search";
import "./canary-input-ask";

@customElement("canary-panel")
export class CanaryPanel extends LitElement {
  @property() endpoint = "";
  @property() public_key = "";
  @property() query = "";
  @property() mode = "Search";
  @state() askResult = "";
  @state() searchResult: SearchResultItem[] = [];

  private _task = new Task(this, {
    task: async ([mode, query], { signal }) => {
      if (query === "") {
        return [];
      }

      const op = mode === "Ask" ? "ask" : "search";

      const url = `${this.endpoint}/api/v1/${op}`;
      const params = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query, public_key: this.public_key }),
        signal,
      };

      const response = await fetch(url, params);
      if (!response.ok) {
        throw new Error();
      }

      if (op === "search") {
        return response.json();
      }

      const reader = response.body
        ?.pipeThrough(new TextDecoderStream())
        .getReader();

      if (!reader) {
        throw new Error();
      }

      let completion = "";
      while (true) {
        const { done, value } = await reader.read();
        if (done) {
          break;
        }

        const items = value
          .split("\n\n")
          .flatMap((s) => s.split("data: "))
          .filter(Boolean);

        completion += items.join("");
        this.askResult = completion;
      }

      return this.askResult;
    },
    args: () => [this.mode, this.query],
  });

  render() {
    return html`
      <div class="container">
        <div class="input-wrapper">
          ${this.mode === "Search"
            ? html`
                <canary-input-search
                  @change=${this._handleChange}
                  @toggle=${this._handleToggle}
                >
                </canary-input-search>
              `
            : html`
                <canary-input-ask
                  @change=${this._handleChange}
                  @toggle=${this._handleToggle}
                >
                </canary-input-ask>
              `}
          <canary-toggle
            left="Search"
            right="Ask"
            selected=${this.mode}
            @toggle=${this._handleToggle}
          ></canary-toggle>
        </div>

        <div class="results">${this.render_results()}</div>

        <div class="logo">
          Powered by
          <a href="https://github.com/fastrepl/canary" target="_blank">
            🐤 Canary
          </a>
        </div>
      </div>
    `;
  }

  render_results() {
    return html`
      ${this._task.render({
        initial: () => nothing,
        pending: () =>
          this.mode === "Search"
            ? html` ${Array(5).fill(html` <div class="row skeleton"></div> `)} `
            : html`
                <div class="row">
                  <span class="title">${this.query}</span>
                  <span class="preview">${this.askResult}</span>
                </div>
              `,
        complete:
          this.mode === "Search"
            ? (items: SearchResultItem[]) =>
                items.length === 0
                  ? nothing
                  : items.map(
                      ({ url, excerpt, meta }) => html`
                        <a class="row" href="${url}">
                          <span class="title">${meta.title}</span>
                          <span class="preview">${excerpt}</span>
                        </a>
                      `,
                    )
            : (completion: string) => html`
                <div class="row">
                  <span class="title">${this.query}</span>
                  <span class="preview">${completion}</span>
                </div>
              `,
        error: (_error) =>
          html`<div class="row error">
            <span class="title">Oops, something went wrong!</span>
          </div>`,
      })}
    `;
  }

  private _handleChange(e: CustomEvent) {
    this.query = e.detail;
  }

  private _handleToggle(e: CustomEvent) {
    this.mode = e.detail;
  }

  static styles = [
    css`
      div.container {
        padding: 8px 16px;
        border: none;
        outline: none;
      }

      div.input-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #9f9f9f;
        margin-bottom: 8px;
      }
    `,
    css`
      .row {
        height: 50px;
        padding: 12px 16px;
        border: 1px solid #e3e3e3;
        border-radius: 8px;

        display: flex;
        flex-direction: column;
        text-decoration: none;
        color: inherit;
      }

      .row:hover {
        background-color: var(--canary-brand);
        border-color: var(--canary-brand-border);
      }
    `,

    css`
      div.results {
        display: flex;
        flex-direction: column;
        gap: 8px;
        max-height: 50vh;
        overflow-y: hidden;
      }

      div.results:hover {
        overflow-y: auto;
      }

      .title {
        font-size: 16px;
      }

      .preview {
        font-size: 14px;
      }
    `,
    css`
      .skeleton {
        border: none;
        background-color: #e3e3e3;
        border-radius: 8px;
        animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
      }

      .skeleton:hover {
        background-color: #f1f1f1;
      }

      @keyframes pulse {
        0%,
        100% {
          opacity: 1;
        }
        50% {
          opacity: 0.5;
        }
      }
    `,
    css`
      .logo {
        padding-top: 8px;
        text-align: end;
        font-size: 12px;
        color: #9f9f9f;
      }

      .logo a {
        text-decoration: none;
        color: #9f9f9f;
      }
      .logo a:hover {
        text-decoration: underline;
        color: black;
      }
    `,
  ];
}
