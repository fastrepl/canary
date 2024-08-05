import { LitElement, css, html, nothing } from "lit";
import { customElement, state, property } from "lit/decorators.js";

import { type ModeContext } from "../types";
import { wrapper } from "../styles";

import { provide } from "@lit/context";
import { modeContext, queryContext } from "../contexts";

const NAME = "canary-content";

@customElement(NAME)
export class CanaryContent extends LitElement {
  @provide({ context: queryContext })
  @property()
  query = "";

  @provide({ context: modeContext })
  @state()
  mode: ModeContext = { options: new Set(), current: null };

  connectedCallback() {
    super.connectedCallback();
    this.addEventListener("register-mode", this._handleRegister);
  }

  disconnectedCallback() {
    this.removeEventListener("register-mode", this._handleRegister);
  }

  render() {
    return html`
      <div
        class="container"
        @mode-set=${this._handleModeSet}
        @input-change=${this._handleChange}
      >
        <slot name="mode"></slot>
        ${this.query ? html`<slot name="footer"></slot>` : nothing}
      </div>
    `;
  }

  private _handleChange(e: CustomEvent) {
    this.query = e.detail;
  }

  private _handleRegister(e: Event) {
    const mode = (e as CustomEvent).detail as string;

    const options = this.mode.options.add(mode);
    const current = this.mode.current ?? mode;
    this.mode = { current, options };
  }

  private _handleModeSet(e: CustomEvent) {
    this.mode = { ...this.mode, current: e.detail };
  }

  static styles = [
    wrapper,
    css`
      .container {
        width: 100%;
        max-width: 500px;

        outline: none;
        padding: 4px 0 12px;

        border: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);

        background-color: var(--canary-color-gray-100);
      }

      @media (min-width: 50rem) {
        .container {
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
