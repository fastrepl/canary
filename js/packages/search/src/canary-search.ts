import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

@customElement("canary-search")
export class CanarySearch extends LitElement {
  @property({ type: Number })
  count = 0;

  render() {
    return html`
      <button @click=${this._onClick}>count is ${this.count}</button>
    `;
  }

  private _onClick() {
    this.count++;
  }

  static styles = css`
    button {
      padding: 2em;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
  }
}
