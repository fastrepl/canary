import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { unsafeHTML } from "lit/directives/unsafe-html.js";
import { Task } from "@lit/task";

import { highlighter } from "@nlux/highlighter";
import { createMarkdownStreamParser } from "@nlux/markdown";

import "./icons/magnifying-glass";
import "./icons/question-mark-circle";
import "./icons/light-bulb";
import "./icons/user";

import "./canary-toggle";
import "./canary-input-search";
import "./canary-input-ask";

import { GITHUB_REPO_URL } from "./constants";
import { randomInteger } from "./utils";

import * as core from "./core";
import type { SearchResultItem } from "./core";
import { content } from "./styles";

@customElement("canary-panel")
export class CanaryPanel extends LitElement {
  @property() endpoint = "";
  @property() query = "";
  @property() mode = "Search";
  @state() askResult = "";
  @state() searchResult: SearchResultItem[] = [];
  @state() responseContainer: HTMLDivElement = document.createElement("div");

  private _task = new Task(this, {
    task: async ([mode, query], { signal }) => {
      if (query === "") {
        return [];
      }

      if (mode === "Search") {
        const result = await core.search(this.endpoint, this.query, signal);
        return result;
      }

      const parser = createMarkdownStreamParser(this.responseContainer, {
        syntaxHighlighter: highlighter,
      });

      if (mode === "Ask") {
        await core.ask(
          this.endpoint,
          randomInteger(),
          this.query,
          (delta) => {
            if (delta.type === "progress") {
              parser.next(delta.content);
            }
          },
          signal,
        );

        return this.askResult;
      }
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
          Powered by <a href=${GITHUB_REPO_URL} target="_blank">🐤 Canary</a>
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
            ? html`
                ${Array(Math.round(Math.random() * 3) + 2).fill(
                  html`<div class="row skeleton"></div>`,
                )}
              `
            : html`
                <div class="messages"></div>
                  <div class="user-message">
                    <hero-user class="icon"></hero-user>
                    <span>${this.query}</span>  
                  </div>
                  <div class="ai-message">
                    <hero-light-bulb class="icon"></hero-light-bulb>
                    ${this.responseContainer}
                  </div>
                </div>
              `,
        complete:
          this.mode === "Search"
            ? (items: SearchResultItem[]) =>
                items.length === 0
                  ? nothing
                  : items.map(
                      ({ title, url, excerpt }) => html`
                        <a class="row" href="${url}">
                          <span class="title">${title}</span>
                          <span class="preview">${unsafeHTML(excerpt)}</span>
                        </a>
                      `,
                    )
            : () => html`
                <div class="messages"></div>
                  <div class="user-message">
                    <hero-user class="icon"></hero-user>
                    <span>${this.query}</span>  
                  </div>
                  <div class="ai-message">
                    <hero-light-bulb class="icon"></hero-light-bulb>
                    ${this.responseContainer}
                  </div>
                </div>
                `,
        error: (error) => {
          console.error(error);
          return html` <div class="row error">
            <span class="title">Oops, something went wrong!</span>
          </div>`;
        },
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
    content,
    css`
      div.container {
        padding: 8px 16px;
        border: none;
        outline: none;
      }

      div.input-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
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
        gap: 4px;
        text-decoration: none;
        color: inherit;
      }

      .row:hover {
        background-color: var(--canary-brand);
        border-color: var(--canary-brand-border);
      }
    `,
    css`
      .messages {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }

      .user-message {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 6px;
        border: 1px solid #e3e3e3;
        border-radius: 8px;
        padding: 4px;
        width: fit-content;
      }

      .ai-message {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 6px;
        border: 1px solid #e3e3e3;
        border-radius: 8px;
        padding: 4px;
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
        font-weight: 500;
        font-size: 16px;
      }

      .preview {
        font-size: 14px;
      }

      mark {
        background-color: var(--canary-brand);
        color: black;
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
      .icon {
        display: flex;
        margin-top: 2px;
        margin-bottom: auto;
        width: 1rem;
        height: 1rem;
      }

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
