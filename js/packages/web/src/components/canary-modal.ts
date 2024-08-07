import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { createRef } from "lit/directives/ref.js";

import { wrapper } from "../styles";
import "./canary-dialog";

const NAME = "canary-modal";

export const MODAL_CLOSE_EVENT = "modal-close";

@customElement(NAME)
export class CanaryModal extends LitElement {
  @property({ type: Boolean }) open = false;

  private _ref = createRef<HTMLDialogElement>();

  render() {
    return html`
      <slot name="trigger" @click=${this._handleOpen}></slot>
      <canary-dialog .ref=${this._ref}>
        <slot name="content" @modal-close=${this._handleModalClose}></slot>
      </canary-dialog>
    `;
  }

  private _handleOpen() {
    this._ref.value?.showModal();
  }

  private _handleModalClose() {
    this._ref.value?.close();
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
