import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { provide } from "@lit/context";
import { themeContext } from "../contexts";
import { createStore, EVENT_NAME } from "../store";

import type { Framework, ThemeContext } from "../types";
import { wrapper } from "../styles";

import "./canary-styles";

const NAME = "canary-root";

@customElement(NAME)
export class CanaryRoot extends LitElement {
  @property({ type: String })
  framework: Framework = "starlight";

  @provide({ context: themeContext })
  @property({ type: String, reflect: true })
  theme: ThemeContext = "light";

  @property({ type: String })
  query = "";

  private _store = createStore(this);

  connectedCallback() {
    super.connectedCallback();

    this.addEventListener(EVENT_NAME, (e) => {
      this._store.send(e.detail);
    });
  }

  firstUpdated() {
    if (this.query) {
      this._store.send({ type: "set_query", data: "..." });
      setTimeout(() => {
        this._store.send({ type: "set_query", data: this.query });
      }, 200);
    }
  }

  render() {
    return html`<canary-styles framework=${this.framework} theme=${this.theme}>
      <slot></slot>
    </canary-styles>`;
  }

  static styles = wrapper;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryRoot;
  }
}
