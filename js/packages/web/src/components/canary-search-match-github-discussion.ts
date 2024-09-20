import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-search-match-base";
import "./canary-snippet";
import "./canary-icon-tree";
import "./canary-logo-github";
import "./canary-badge";

import { SearchResult } from "../types";
import { global } from "../styles";

const NAME = "canary-search-match-github-discussion";

@customElement(NAME)
export class CanarySearchMatchGithubDiscussion extends LitElement {
  @property({ type: Object })
  match!: SearchResult;

  render() {
    if (this.match.type !== "github_discussion") {
      throw new Error();
    }

    return html`
      <div class="container" part="container">
        <canary-search-match-base url=${this.match.url} part="match-item">
          <canary-logo-github slot="title-icon"></canary-logo-github>
          <canary-snippet slot="title" .value=${this.match.title}>
          </canary-snippet>
          <canary-badge slot="title-badge" .name=${"DISCUSSION"}>
          </canary-badge>
          <canary-badge
            slot="title-badge"
            .name=${this.match.meta.answered
              ? "ANSWERED"
              : this.match.meta.closed
                ? "CLOSED"
                : "OPEN"}
          >
          </canary-badge>
          <canary-snippet slot="excerpt" .value=${this.match.excerpt}>
          </canary-snippet>
        </canary-search-match-base>
        ${this.match.sub_results.map(
          (sub_result, i) => html`
            <canary-search-match-base url=${sub_result.url} part="match-item">
              <canary-icon-tree
                slot="content-before"
                .last=${i === this.match.sub_results.length - 1}
              >
              </canary-icon-tree>
              <canary-snippet
                slot="title"
                class="title"
                .value=${sub_result.title}
              >
              </canary-snippet>
              <canary-snippet
                slot="excerpt"
                class="excerpt"
                .value=${sub_result.excerpt}
              >
              </canary-snippet>
            </canary-search-match-base>
          `,
        )}
      </div>
    `;
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }
    `,
    css`
      canary-logo-github::part(svg) {
        width: 0.875em;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchMatchGithubDiscussion;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
