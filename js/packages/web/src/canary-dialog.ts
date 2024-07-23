import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ref, createRef, Ref } from "lit/directives/ref.js";

const NAME = "canary-dialog";

@customElement(NAME)
export class CanaryDialog extends LitElement {
  @property({ attribute: false })
  ref: Ref<HTMLDialogElement> = createRef();

  render() {
    return html`
      <dialog ${ref(this.ref)} @click=${this.handleClick}>
        <slot></slot>
      </dialog>
    `;
  }

  private handleClick(e: MouseEvent) {
    const dialog = this.ref.value;
    if (dialog?.open && (e.target as any)["nodeName"] === "DIALOG") {
      dialog.close();
    }
  }

  static styles = [
    css`
      dialog::backdrop {
        background-color: var(--canary-color-backdrop-overlay);
        -webkit-backdrop-filter: blur(0.25rem);
        backdrop-filter: blur(0.25rem);
      }

      dialog {
        width: 100%;
        max-width: 500px;
        margin: 0 auto;
        top: 40px;
        padding: 0;
        border: none;
        outline: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryDialog;
  }
}
