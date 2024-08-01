import { LitElement, css, html, nothing } from "lit";
import {
  customElement,
  property,
  queryAssignedElements,
} from "lit/decorators.js";

import { Mode, type ModeContext } from "../types";
import { wrapper } from "../styles";

import { provide } from "@lit/context";
import { modeContext, queryContext } from "../contexts";

const NAME = "canary-content";

@customElement(NAME)
export class CanaryContent extends LitElement {
  @provide({ context: modeContext })
  @property({ attribute: false })
  mode: ModeContext = {
    options: new Set([Mode.Search, Mode.Ask]),
    current: Mode.Search,
  };

  @provide({ context: queryContext })
  @property()
  query = "";

  @queryAssignedElements({ slot: "search" })
  searchElements!: Array<HTMLElement>;

  @queryAssignedElements({ slot: "ask" })
  askElements!: Array<HTMLElement>;

  firstUpdated() {
    let current = this.mode.current;
    let options = this.mode.options;

    if (this.searchElements.length > 0) {
      options.add(Mode.Search);
    } else {
      options.delete(Mode.Search);
    }

    if (this.askElements.length > 0) {
      options.add(Mode.Ask);
    } else {
      options.delete(Mode.Ask);
    }

    if (this.searchElements.length > 0) {
      current = Mode.Search;
    } else {
      current = Mode.Ask;
    }

    this.mode = { current, options };
  }

  render() {
    return html`
      <div
        class="container"
        @mode-set=${this._handleModeSet}
        @input-tab=${this._handleTab}
        @input-change=${this._handleChange}
      >
        <slot name="search"></slot>
        <slot name="ask"></slot>
        ${this.query ? html`<slot name="footer"></slot>` : nothing}
      </div>
    `;
  }

  private _handleChange(e: CustomEvent) {
    this.query = e.detail;
  }

  private _handleTab(_: CustomEvent) {
    if (this.mode.options.size < 2) {
      return;
    }

    if (this.mode?.current === "Search") {
      this.mode = { ...this.mode, current: Mode.Ask };
    } else {
      this.mode = { ...this.mode, current: Mode.Search };
    }
  }

  private _handleModeSet(e: CustomEvent) {
    this.mode = { ...this.mode, current: e.detail };
  }

  static styles = [
    wrapper,
    css`
      div.container {
        width: calc(100% - 16px);
        max-width: 500px;

        outline: none;
        padding: 4px 8px 12px;

        border: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);

        background-color: var(--canary-color-gray-100);
      }

      @media (min-width: 50rem) {
        div.container {
          width: 500px;
        }
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryContent;
  }
}
