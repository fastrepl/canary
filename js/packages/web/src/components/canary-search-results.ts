import { LitElement, css, html, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { executionContext } from "../contexts";

import type { ExecutionContext } from "../types";
import { TaskStatus } from "../store/managers";

import "./canary-error";
import "./canary-search-match-webpage";
import "./canary-search-match-github-issue";
import "./canary-search-match-github-discussion";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  render() {
    if (!this._execution) {
      return nothing;
    }

    const { matches } = this._execution.search;

    if (matches.length === 0) {
      return nothing;
    }

    return html`
      ${this._execution.status === TaskStatus.ERROR
        ? html`<canary-error></canary-error>`
        : html`
            <div class="container">
              ${matches.map((match) => {
                switch (match.type) {
                  case "webpage":
                    return html`<canary-search-match-webpage
                      .match=${match}
                      part="match-group"
                      exportparts="match-item"
                    >
                    </canary-search-match-webpage>`;
                  case "github_issue":
                    return html`<canary-search-match-github-issue
                      part="match-group"
                      .match=${match}
                      exportparts="match-item"
                    >
                    </canary-search-match-github-issue>`;
                  case "github_discussion":
                    return html`<canary-search-match-github-discussion
                      .match=${match}
                      part="match-group"
                      exportparts="match-item"
                    ></canary-search-match-github-discussion>`;
                  default:
                    throw new Error();
                }
              })}
            </div>
          `}
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
