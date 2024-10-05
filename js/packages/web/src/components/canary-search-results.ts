import { LitElement, css, html, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { executionContext } from "../contexts";

import type { ExecutionContext } from "../types";
import { TaskStatus } from "../store/managers";

import "./canary-error";
import "./canary-search-match";

const NAME = "canary-search-results";

/**
 * @csspart container - Container
 * @csspart match-group - Match group
 * @csspart match-item - Match item
 */
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
            <div class="container" part="container">
              ${matches.map(
                (match) =>
                  html`<canary-search-match
                    exportparts="match-group,match-item"
                    .match=${match}
                  ></canary-search-match>`,
              )}
            </div>
          `}
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 6px;
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
