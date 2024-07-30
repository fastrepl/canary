import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { createRef } from "lit/directives/ref.js";

import { wrapper } from "./styles";
import "./canary-dialog";

const NAME = "canary-modal";

@customElement(NAME)
export class CanaryModal extends LitElement {
  ref = createRef<HTMLDialogElement>();
  @property({ type: Boolean }) open = false;

  render() {
    return html`
      <slot name="trigger" @click=${this._handleOpen}></slot>
      <canary-dialog .ref=${this.ref}>
        <slot name="content" @close=${this._handleClose}></slot>
      </canary-dialog>
    `;
  }

  private _handleOpen() {
    this.ref.value?.showModal();
  }

  private _handleClose() {
    this.ref.value?.close();
  }

  static styles = [
    wrapper,
    css`
      ::slotted(*) {
        cursor: pointer;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryModal;
  }
}
