import { LitElement, html, css, nothing } from "lit";
import { customElement } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext, executionContext } from "../contexts";

import type { QueryContext, ExecutionContext } from "../types";
import { TaskStatus } from "../store";
import { global } from "../styles";

const NAME = "canary-search-empty";

@customElement(NAME)
export class CanarySearchEmpty extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  private _query?: QueryContext;

  @consume({ context: executionContext, subscribe: true })
  private _execution?: ExecutionContext;

  render() {
    if (
      !this._query ||
      !this._execution ||
      this._execution.status !== TaskStatus.COMPLETE ||
      this._execution.search.matches.length !== 0 ||
      this._query.length === 0
    ) {
      return nothing;
    }

    return html`
      <div class="container">
        <p>No results found.</p>
      </div>
    `;
  }

  static styles = [
    global,
    css`
      .container {
        width: 100%;
        padding: 0px 12px;
      }

      p {
        cursor: default;
        margin-left: 4px;
        font-size: 0.875rem;
        color: var(--canary-color-gray-40);
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchEmpty;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
