import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ref, createRef } from "lit/directives/ref.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";
import { KeyboardSelectionController } from "../controllers";

import type { SearchContext, SearchReference } from "../types";
import { customEvent } from "../events";
import { TaskStatus } from "../constants";
import { scrollContainer } from "../styles";

import "./canary-error";
import "./canary-search-references";

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @property({ type: Boolean })
  group = false;

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search!: SearchContext;

  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(customEvent({ name: "modal-close" }));
      window.location.href = item.url;
    },
  });

  private _containerRef = createRef<HTMLElement>();

  render() {
    if (this._search.status === TaskStatus.COMPLETE) {
      this._selection.items = this._search.references;

      if (this._containerRef.value) {
        this._containerRef.value.scrollTop = 0;
      }
    }

    return html`
      <div ${ref(this._containerRef)} class="scroll-container">
        ${this._search.status === TaskStatus.ERROR
          ? html`<canary-error></canary-error>`
          : html`<canary-search-references
              .group=${this.group}
              .selected=${this._selection.index}
              .references=${this._search.references}
            ></canary-search-references>`}
      </div>
    `;
  }

  static styles = [
    scrollContainer,
    css`
      .scroll-container {
        padding: 0px 12px;
        max-height: 425px;
      }
      .skeleton-container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        height: 425px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
