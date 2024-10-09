import { LitElement, html } from "lit";
import { property, state } from "lit/decorators.js";

import { wrapper } from "../styles";
import { registerCustomElement } from "../decorators";

const NAME = "canary-media-query";

@registerCustomElement(NAME)
export class CanaryMediaQuery extends LitElement {
  @property({ type: String }) query = "";
  @state() matched = false;

  private mediaQueryList?: MediaQueryList;

  connectedCallback() {
    super.connectedCallback();

    if (!this.query) {
      throw new Error(`'query' is required for '${NAME}'`);
    }

    this.mediaQueryList = window.matchMedia(this.query);
    this.matched = this.mediaQueryList.matches;
    this.mediaQueryList.addEventListener("change", this.handleChange);
  }

  disconnectedCallback() {
    super.disconnectedCallback();

    this.mediaQueryList?.removeEventListener("change", this.handleChange);
  }

  private handleChange = (event: MediaQueryListEvent) => {
    this.matched = event.matches;
  };

  render() {
    return html`
      ${this.matched
        ? html`<slot></slot>`
        : html`<slot name="fallback"></slot>`}
    `;
  }

  static styles = wrapper;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryMediaQuery;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
