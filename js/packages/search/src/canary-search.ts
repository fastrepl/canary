import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { createRef } from "lit/directives/ref.js";

import "./canary-dialog";
import "./canary-panel";

@customElement("canary-search")
export class CanarySearch extends LitElement {
  @property() endpoint = "";
  @property() public_key = "";

  ref = createRef<HTMLDialogElement>();

  render() {
    return html`
      <slot @click=${this._handleOpen}></slot>
      <canary-dialog .ref=${this.ref}>
        <canary-panel
          endpoint=${this.endpoint}
          public_key=${this.public_key}
        ></canary-panel>
      </canary-dialog>
    `;
  }

  private _handleOpen() {
    this.ref.value?.showModal();
  }

  static styles = [
    css`
      ::slotted(*) {
        cursor: pointer;
      }
    `,
  ];
}
