import { LitElement, css, html, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";
import { Task } from "@lit/task";

import "./icons/magnifying-glass";
import { type SearchResultItem } from "./shared";

@customElement("canary-panel")
export class CanaryPanel extends LitElement {
  @property() endpoint = "";
  @property() query = "";
  @property({ type: Array }) result: SearchResultItem[] = [];

  private _task = new Task(this, {
    task: async ([query], { signal }) => {
      const url = `${this.endpoint}/api/v1/search`;
      const params = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query }),
        signal,
      };

      const response = await fetch(url, params);
      if (!response.ok) {
        throw new Error();
      }
      return response.json();
    },
    args: () => [this.query],
  });

  render() {
    return html`
      <div class="container">
        <div class="search-wrapper">
          <div class="hero-magnifying-glass"><hero-magnifying-glass /></div>
          <input
            type="search"
            autocomplete="off"
            autofocus
            placeholder="Search for anything..."
            @input=${this._handleInput}
          />
        </div>

        <div class="results-wrapper">
          <button class="ask row">Ask AI</button>
          <div class="results">${this.render_results()}</div>
        </div>
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
        pending: () => html`
          ${Array(5).fill(html` <div class="row skeleton"></div> `)}
        `,
        complete: (items: SearchResultItem[]) =>
          items.map(
            ({ url, excerpt, meta }) => html`
              <a class="row" href="${url}">
                <span class="title">${meta.title}</span>
                <span class="preview">${excerpt}</span>
              </a>
            `,
          ),
        error: (error) => html`<p>Oops, something went wrong: ${error}</p>`,
      })}
    `;
  }

  private _handleInput(e: Event) {
    const input = e.target as HTMLInputElement;
    this.query = input.value;
  }

  static styles = [
    css`
      .hero-magnifying-glass {
        width: 1rem;
        height: 1rem;
      }

      div.container {
        padding: 8px 16px;
        border: none;
        outline: none;
      }

      div.results-wrapper {
        display: flex;
        flex-direction: column;
        gap: 8px;
      }

      div.search-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #9f9f9f;
      }
    `,
    css`
      input {
        width: 60vw;
        max-width: 600px;
        height: 40px;
        outline: none;
        border: none;
        font-size: 16px;
        font-weight: 100;
      }

      input::placeholder {
        color: #9f9f9f;
        font-size: 14px;
      }
    `,
    css`
      button.ask {
        padding: 12px 16px;
        width: 100%;
        background-color: transparent;
        border: none;
        outline: none;
        text-align: start;
        font-size: 16px;
        color: #9f9f9f;
        font-weight: 100;
      }

      button.ask:hover {
        background-color: var(--canary-brand);
      }
    `,
    css`
      .row {
        height: 50px;
        padding: 12px 16px;
        border: 1px solid #e3e3e3;
        border-radius: 8px;
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

      a.row {
        display: flex;
        flex-direction: column;
        text-decoration: none;
        color: inherit;
      }

      a.row .title {
        font-size: 16px;
      }

      a.row .preview {
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
        padding-top: 14px;
        text-align: end;
        font-size: 14px;
        color: #9f9f9f;
      }

      .logo a {
        text-decoration: none;
        color: #9f9f9f;
      }
      .logo a:hover {
        text-decoration: underline;
        color: #9f9f9f;
      }
    `,
  ];
}
