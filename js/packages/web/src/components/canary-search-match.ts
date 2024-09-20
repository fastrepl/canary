import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { wrapper } from "../styles";
import type { SearchResult } from "../types";

import "./canary-search-match-webpage";
import "./canary-search-match-github-issue";
import "./canary-search-match-github-discussion";

const NAME = "canary-search-match";

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

    if (this.match.type === "github_issue") {
      return html`<canary-search-match-github-issue
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-github-issue> `;
    }

    if (this.match.type === "github_discussion") {
      return html`<canary-search-match-github-discussion
        .match=${this.match}
        part="match-group"
        exportparts="match-item"
      >
      </canary-search-match-github-discussion>`;
    }
  }

  static styles = wrapper;
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
