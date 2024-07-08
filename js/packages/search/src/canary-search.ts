import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { createRef } from "lit/directives/ref.js";
import { portal } from "lit-modal-portal";

import "./canary-dialog";
import "./canary-panel";

@customElement("canary-search")
export class CanarySearch extends LitElement {
  @property() endpoint = "";

  ref = createRef<HTMLDialogElement>();

  render() {
    return html`
      <slot @click=${this._handleOpen}></slot>
      ${portal(
        html`
          <canary-dialog .ref=${this.ref}>
            <canary-panel endpoint=${this.endpoint}></canary-panel>
          </canary-dialog>
        `,
        document.body,
      )}
    `;
  }

  private _handleOpen() {
    this.ref.value?.showModal();
  }

  static styles = [
    css`
      :host {
        --canary-brand-color: #e0ecf7;
      }
    `,
    css`
      ::slotted(*) {
        cursor: pointer;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
  }
}
