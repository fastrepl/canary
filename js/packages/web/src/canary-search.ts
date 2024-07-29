import { consume } from "@lit/context";
import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { modeContext } from "./contexts";
import type { ModeContext } from "./types";

import "./canary-mode-tabs";
import "./canary-search-empty";

const NAME = "canary-search";

@customElement(NAME)
export class CanarySearch extends LitElement {
  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  render() {
    return this.mode?.current === "Search"
      ? html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input"></slot>
              <slot name="mode-tabs">
                <canary-mode-tabs></canary-mode-tabs>
              </slot>
            </div>
            <div class="body">
              <div class="callouts">
                <slot name="callout"></slot>
              </div>
              <slot name="results"></slot>
              <slot name="empty">
                <canary-search-empty></canary-search-empty>
              </slot>
            </div>
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

    .body {
      padding-left: 4px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
}
