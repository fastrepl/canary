import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";
import { Task } from "@lit/task";

import { highlighter } from "@nlux/highlighter";
import { createMarkdownStreamParser } from "@nlux/markdown";

import "./canary-radio";
import "./canary-input";
import "./canary-reference";
import "./canary-reference-skeleton";
import "./canary-footer";
import "./canary-loading-dots";

import { randomInteger } from "./utils";

import { type Reference, ask, search } from "./core";
import { content } from "./styles";

@customElement("canary-panel")
export class CanaryPanel extends LitElement {
  @property() key = "";
  @property() endpoint = "";
  @property() hljs = "github";

  @property() mode = "Search";
  @property({ reflect: true }) query = "";

  @state() askReferences: Reference[] = [];
  @state() responseContainer: HTMLDivElement = document.createElement("div");

  @state() searchReferences: Reference[] = [];
  @state() searchIndex = 0;

  connectedCallback() {
    super.connectedCallback();
    this.addEventListener("keydown", this._handleNavigation);
  }

  disconnectedCallback() {
    this.removeEventListener("keydown", this._handleNavigation);
    super.disconnectedCallback();
  }

  private _task = new Task(this, {
    task: async ([mode, query], { signal }) => {
      if (query === "") {
        return [];
      }

      if (mode === "Search") {
        const result = await search(
          this.key,
          this.endpoint,
          this.query,
          signal,
        );

        this.searchIndex = 0;
        this.searchReferences = result;
        return this.searchReferences;
      }

      if (mode === "Ask") {
        this.responseContainer.textContent = "";
        const parser = createMarkdownStreamParser(this.responseContainer, {
          syntaxHighlighter: highlighter,
          waitTimeBeforeStreamCompletion: 20 * 1000,
          showCodeBlockCopyButton: false,
        });

        await ask(
          this.key,
          this.endpoint,
          randomInteger(),
          this.query,
          (delta) => {
            if (delta.type === "progress") {
              parser.next(delta.content);
            }
            if (delta.type === "references") {
              this.askReferences = delta.items;
            }
          },
          signal,
        );

        return this.askReferences;
      }
    },
    args: () => [this.mode, this.query],
  });

  render() {
    return html`
      <link
        rel="stylesheet"
        href="https://unpkg.com/highlight.js@11.9.0/styles/${this.hljs}.css"
      />

      <div class="container">
        <div class="input-wrapper">
          ${this.mode === "Search"
            ? html`
                <canary-input-search
                  value=${this.query}
                  @change=${this._handleChange}
                  @toggle=${this._handleToggle}
                >
                </canary-input-search>
              `
            : html`
                <canary-input-ask
                  value=${this.query}
                  @change=${this._handleChange}
                  @toggle=${this._handleToggle}
                >
                </canary-input-ask>
              `}

          <slot name="radio">
            <canary-radio
              .options=${["Search", "Ask"]}
              selected=${this.mode}
              @change=${this._handleToggle}
            ></canary-radio>
          </slot>
        </div>

        ${this.mode === "Search"
          ? html`<div class="callouts"><slot name="callout"></slot></div>`
          : nothing}
        <div class="results">${this.results()}</div>

        <canary-footer></canary-footer>
      </div>
    `;
  }

  results() {
    return html`
      ${this._task.render({
        initial: () => nothing,
        pending: () =>
          this.mode === "Search"
            ? html` <div class="skeleton-container">
                ${Array(4).fill(
                  html`<canary-reference-skeleton></canary-reference-skeleton>`,
                )}
              </div>`
            : html`
                <div class="ai-message">
                  ${
                    this.responseContainer.textContent == ""
                      ? html`<canary-loading-dots></canary-loading-dots>`
                      : this.responseContainer
                  }

             <div class="references">
                          ${this.askReferences.map(
                            (item) =>
                              html` <canary-reference
                                title=${item.title}
                                url=${item.url}
                              ></canary-reference>`,
                          )}
                        </div>
                      </div>
                  </div>
                </div>
              `,
        complete:
          this.mode === "Search"
            ? (items) =>
                !items || items.length === 0
                  ? nothing
                  : items.map(
                      ({ title, url, excerpt }, index) => html`
                        <canary-reference
                          title=${title}
                          url=${url}
                          excerpt=${ifDefined(excerpt)}
                          ?selected=${index === this.searchIndex}
                        ></canary-reference>
                      `,
                    )
            : (items) =>
                this.query === ""
                  ? nothing
                  : html`
                      <div class="ai-message">
                        ${this.responseContainer}
                        <div class="references">
                          ${(items ?? []).map(
                            (item) =>
                              html` <canary-reference
                                title=${item.title}
                                url=${item.url}
                              ></canary-reference>`,
                          )}
                        </div>
                      </div>
                    `,
        error: (error) => {
          console.error(error);
          return html` <div class="error">
            <span class="title">Oops, something went wrong!</span>
          </div>`;
        },
      })}
    `;
  }

  private _handleNavigation(e: KeyboardEvent) {
    switch (e.key) {
      case "ArrowUp":
        e.preventDefault();
        this._moveSelection(-1);
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveSelection(1);
        break;
      case "Enter":
        if (this.mode === "Search") {
          e.preventDefault();
          window.open(this.searchReferences[this.searchIndex].url);
        }
        break;
    }
  }

  private _moveSelection(delta: number) {
    const next = this.searchIndex + delta;
    if (next > -1 && next < this.searchReferences.length) {
      this.searchIndex = next;
    }
  }

  private _handleChange(e: CustomEvent) {
    this.query = e.detail;
  }

  private _handleToggle(e: CustomEvent) {
    if (this.mode === "Ask") {
      this.query = "";
    }

    this.mode = e.detail;
  }

  static styles = [
    content,
    css`
      div.container {
        padding: 8px 8px;
        border: none;
        border-radius: 8px;
        outline: none;
        color: var(--canary-color-gray-1);
        background-color: var(--canary-color-black);
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }

      div.input-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 4px;
        padding: 1px 8px;
      }
    `,
    css`
      .ai-message {
        border: 1px solid var(--canary-color-gray-6);
        border-radius: 8px;
        padding: 0px 12px;
      }
    `,
    css`
      div.references {
        display: flex;
        flex-direction: column;
        gap: 6px;
        padding-bottom: 8px;
      }

      div.callouts {
        display: flex;
        flex-direction: column;
      }

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
    `,
    css`
      .skeleton-container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        height: 350px;
      }
    `,
    css`
      .logo {
        padding-top: 8px;
        text-align: end;
        font-size: 12px;
        color: var(--canary-color-gray-2);
      }

      .logo a {
        text-decoration: none;
        color: var(--canary-color-gray-1);
      }
      .logo a:hover {
        text-decoration: underline;
        color: var(--canary-color-white);
      }
    `,
  ];
}
