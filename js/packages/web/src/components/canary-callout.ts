import { LitElement, css, html } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { StringArray } from "../converters";
import { CalloutController } from "../controllers";

import { callout } from "../styles";

const NAME = "canary-callout";

@registerCustomElement(NAME)
export class CanaryCallout extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = [];

  @property({ type: String })
  url = "/";
  @property()
  message = "";

  private _callout = new CalloutController(this);

  render() {
    return this._callout.render(
      () => html`
        <button @click=${this._handleClick}>
          <span>${this.message}</span>
          <div>
            <slot name="logo"></slot>
            <div class="icon i-heroicons-arrow-up-right"></div>
          </div>
        </button>
      `,
      { forceShow: this.forceShow, keywords: this.keywords },
    );
  }

  private _handleClick() {
    window.open(this.url, "_blank");
  }

  static styles = [
    css`
      @unocss-placeholder;
    `,
    callout,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCallout;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
