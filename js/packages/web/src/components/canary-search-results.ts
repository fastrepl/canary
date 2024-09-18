import { LitElement, css, html, nothing } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { executionContext } from "../contexts";

import type { ExecutionContext } from "../types";
import { TaskStatus } from "../store/managers";

import "./canary-error";
import "./canary-search-references";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @property({ type: String })
  header = "";

  @property({ type: Boolean })
  group = false;

  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  render() {
    if (!this._execution) {
      return nothing;
    }

    const references = Object.values(this._execution.search.sources).flatMap(
      ({ hits }) => hits,
    );

    if (references.length === 0) {
      return nothing;
    }

    return html`
      ${
        this._execution.status === TaskStatus.ERROR
          ? html`<canary-error></canary-error>`
          : html` <div class="container">
              <canary-search-references
                .group=${this.group}
                .references=${references}
              ></canary-search-references>
            </div>`
      }
          </div>
      </div>
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
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
