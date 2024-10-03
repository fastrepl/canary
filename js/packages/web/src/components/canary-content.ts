import { LitElement, css, html } from "lit";
import { customElement, queryAssignedElements, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { consume } from "@lit/context";
import { queryContext } from "../contexts";

import { global, wrapper } from "../styles";

const NAME = "canary-content";

@customElement(NAME)
export class CanaryContent extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @state()
  private _query = "";

  @queryAssignedElements({ slot: "footer" })
  private _footers!: Array<Node>;

  render() {
    return html`
      <div class="container" part="container">
        <div class="head-container" part="head-container">
          <slot name="head"></slot>
        </div>
        <slot name="input"></slot>
        <slot name="mode"></slot>
        <div
          class=${classMap({
            footer: true,
            hide: !this._query || this._footers.length === 0,
          })}
        >
          <div class="footer">
            <slot name="footer"></slot>
          </div>
        </div>
      </div>
    `;
  }

  static styles = [
    global,
    wrapper,
    css`
      .container {
        width: 300px;

        outline: none;
        padding-top: 6px;
        padding-bottom: 8px;

        border: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);

        background-color: var(--canary-color-gray-100);
      }

      @media (min-width: 40rem) {
        .container {
          width: var(--canary-content-max-width, 550px);
        }
      }

      .head-container {
        padding-left: 12px;
        padding-right: 12px;
      }
    `,
    css`
      .footer {
        padding-top: 2px;
        padding-right: 6px;
      }

      .hide {
        display: none;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryContent;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
