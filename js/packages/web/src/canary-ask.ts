import { consume } from "@lit/context";
import { LitElement, html, css, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";

import { modeContext, type ModeContext } from "./contexts";

import "./canary-mode-tabs";

const NAME = "canary-ask";

@customElement(NAME)
export class CanaryAsk extends LitElement {
  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode!: ModeContext;

  render() {
    return this.mode.current === "Ask"
      ? html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input"></slot>
              <slot name="mode-tabs">
                <canary-mode-tabs></canary-mode-tabs>
              </slot>
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
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAsk;
  }
}
