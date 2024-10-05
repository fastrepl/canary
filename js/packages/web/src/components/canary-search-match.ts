import { LitElement, html, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";

import { wrapper } from "../styles";
import type { SearchResult } from "../types";

import "./canary-search-match-webpage";

const NAME = "canary-search-match";

const OPENAPI_ELEMENT_NAME = "canary-search-match-openapi";
const GITHUB_ISSUE_ELEMENT_NAME = "canary-search-match-github-issue";
const GITHUB_DISCUSSION_ELEMENT_NAME = "canary-search-match-github-discussion";

/**
 * @csspart match-group - Match group
 * @csspart match-item - Match item
 */
@customElement(NAME)
export class CanarySearchMatch extends LitElement {
  @property({ type: Object })
  match!: SearchResult;

  render() {
    if (this.match.type === "webpage") {
      return html`<canary-search-match-webpage
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-webpage> `;
    }

    if (this.match.type === "openapi") {
      if (!this.is_element_defined(OPENAPI_ELEMENT_NAME)) {
        this._log_element_not_defined(OPENAPI_ELEMENT_NAME);
        return nothing;
      }

      return html`<canary-search-match-openapi
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-openapi> `;
    }

    if (this.match.type === "github_issue") {
      if (!this.is_element_defined(GITHUB_ISSUE_ELEMENT_NAME)) {
        this._log_element_not_defined(GITHUB_ISSUE_ELEMENT_NAME);
        return nothing;
      }

      return html`<canary-search-match-github-issue
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-github-issue> `;
    }

    if (this.match.type === "github_discussion") {
      if (!this.is_element_defined(GITHUB_DISCUSSION_ELEMENT_NAME)) {
        this._log_element_not_defined(GITHUB_DISCUSSION_ELEMENT_NAME);
        return nothing;
      }

      return html`<canary-search-match-github-discussion
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-github-discussion>`;
    }
  }

  static styles = wrapper;

  private is_element_defined(name: string) {
    return globalThis.customElements.get(name) !== undefined;
  }

  private _log_element_not_defined(name: string) {
    console.error(`${name} is not defined. Please make sure to import it.`);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchMatch;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
