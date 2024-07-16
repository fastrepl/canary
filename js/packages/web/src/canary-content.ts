import { LitElement, css, html, nothing } from "lit";
import {
  customElement,
  property,
  state,
  queryAssignedElements,
} from "lit/decorators.js";

import { provide, consume } from "@lit/context";
import {
  modeContext,
  defaultModeContext,
  type ModeContext,
  queryContext,
  providerContext,
  type ProviderContext,
} from "./contexts";

import "./canary-reference";
import "./canary-reference-skeleton";

import "./canary-error";
import "./canary-mode-tabs";
import "./canary-footer";

@customElement("canary-content")
export class CanaryContent extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider: ProviderContext | undefined = undefined;

  @provide({ context: modeContext })
  @property({ attribute: false })
  mode: ModeContext = defaultModeContext;

  @provide({ context: queryContext })
  @property()
  query = "";

  @queryAssignedElements({ slot: "input-search" })
  inputSearch!: Array<HTMLElement>;

  @queryAssignedElements({ slot: "input-ask" })
  inputAsk!: Array<HTMLElement>;

  firstUpdated() {
    let options = this.mode.options;

    if (this.inputSearch.length > 0) {
      options.add("Search");
    } else {
      options.delete("Search");
    }

    if (this.inputAsk.length > 0) {
      options.add("Ask");
    } else {
      options.delete("Ask");
    }

    this.mode = { ...this.mode, options };
  }

  render() {
    return html`
      <div class="container">
        <div class="input-wrapper">
          <slot
            name="input-search"
            @change=${this._handleChange}
            @tab=${this._handleTab}
          >
          </slot>
          <slot
            name="input-ask"
            @change=${this._handleChange}
            @tab=${this._handleTab}
          >
          </slot>

          <slot name="mode-tabs">
            <canary-mode-tabs @set=${this._handleModeSet}></canary-mode-tabs>
          </slot>
        </div>

        ${this.mode.current === "Search"
          ? html`<div class="callouts"><slot name="callout"></slot></div>`
          : nothing}
        ${this.mode.current === "Search"
          ? html`<slot name="panel-search"></slot>`
          : html`<slot name="panel-ask"></slot>`}

        <canary-footer></canary-footer>
      </div>
    `;
  }

  private _handleChange(e: CustomEvent) {
    this.query = e.detail;
  }

  private _handleTab(_: CustomEvent) {
    if (!this.mode.options || this.mode.options.size < 2) {
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
        padding: 8px 8px;
        border: none;
        border-radius: 8px;
        outline: none;
        color: var(--canary-color-gray-1);
        background-color: var(--canary-color-black);
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }

      div.input-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
        padding: 1px 6px;
      }

      div.callouts {
        display: flex;
        flex-direction: column;
      }
    `,
    css`
      .logo {
        padding-top: 8px;
        text-align: end;
        font-size: 12px;
        color: var(--canary-color-gray-2);
      }

      .logo a {
        text-decoration: none;
        color: var(--canary-color-gray-1);
      }
      .logo a:hover {
        text-decoration: underline;
        color: var(--canary-color-white);
      }
    `,
  ];
}
