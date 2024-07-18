import { LitElement, css, html } from "lit";
import {
  customElement,
  property,
  state,
  queryAssignedElements,
} from "lit/decorators.js";

import { provide, consume } from "@lit/context";
import {
  modeContext,
  type ModeContext,
  queryContext,
  providerContext,
  type ProviderContext,
} from "./contexts";

import "./canary-footer";

@customElement("canary-content")
export class CanaryContent extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider: ProviderContext | undefined = undefined;

  @provide({ context: modeContext })
  @property({ attribute: false })
  mode: ModeContext = {
    options: new Set(["Search", "Ask"]),
    current: "Search",
  };

  @provide({ context: queryContext })
  @property()
  query = "";

  @queryAssignedElements({ slot: "search" })
  searchElements!: Array<HTMLElement>;

  @queryAssignedElements({ slot: "ask" })
  askElements!: Array<HTMLElement>;

  firstUpdated() {
    let mode = this.mode.current;
    let options = this.mode.options;

    if (this.searchElements.length > 0) {
      options.add("Search");
    } else {
      options.delete("Search");
    }

    if (this.askElements.length > 0) {
      options.add("Ask");
    } else {
      options.delete("Ask");
    }

    if (this.searchElements.length > 0) {
      mode = "Search";
    } else {
      mode = "Ask";
    }

    this.mode = { current: mode, options };
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
        <canary-footer></canary-footer>
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

    if (this.mode.current === "Search") {
      this.mode = { ...this.mode, current: "Ask" };
    } else {
      this.mode = { ...this.mode, current: "Search" };
    }
  }

  private _handleModeSet(e: CustomEvent) {
    this.mode = { ...this.mode, current: e.detail };
  }

  static styles = [
    css`
      div.container {
        max-width: 500px;

        color: var(--canary-color-gray-1);
        background-color: var(--canary-color-black);

        outline: none;
        padding: 8px 8px;

        border: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }
    `,
  ];
}
