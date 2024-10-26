import { LitElement, css, html } from "lit";
import { property } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { registerCustomElement } from "../decorators";
import { createRef } from "lit/directives/ref.js";

import { createEvent } from "../store";
import { wrapper } from "../styles";
import "./canary-dialog";

const NAME = "canary-modal";

export const MODAL_CLOSE_EVENT = "modal-close";

@registerCustomElement(NAME)
export class CanaryModal extends LitElement {
  @property({ type: Boolean }) open = false;
  @property({ type: Boolean }) transition = false;

  private _ref = createRef<HTMLDialogElement>();

  render() {
    return html`
      <slot name="trigger" @click=${this._handleOpen}></slot>
      <canary-dialog .ref=${this._ref} transition=${ifDefined(this.transition)}>
        <slot name="content" @modal-close=${this._handleModalClose}></slot>
      </canary-dialog>
    `;
  }

  private _handleOpen() {
    this._ref.value?.showModal();
  }

  private _handleModalClose() {
    this._ref.value?.close();
    this.dispatchEvent(createEvent({ type: "set_query", data: { text: "" } }));
  }

  static styles = [
    wrapper,
    css`
      ::slotted([slot="trigger"]) {
        cursor: pointer;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryModal;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
