import { consume } from "@lit/context";
import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { modeContext, queryContext } from "./contexts";
import type { ModeContext, QueryProviderContext } from "./types";

import type { Reference } from "./types";

import "./canary-mode-tabs";

const NAME = "canary-search";

@customElement(NAME)
export class CanarySearch extends LitElement {
  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query: QueryProviderContext = "";

  @state()
  selectedReference: Reference | null = null;

  render() {
    return this.mode.current === "Search"
      ? html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input"></slot>
              <slot name="mode-tabs">
                <canary-mode-tabs></canary-mode-tabs>
              </slot>
            </div>
            <div class="callouts">
              <slot name="callout"></slot>
            </div>
            <slot name="results"></slot>
          </div>
        `
      : nothing;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
    }

    .input-wrapper {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 4px;
      padding: 1px 6px;
    }

    .callouts {
      display: flex;
      flex-direction: column;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
}
