import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ref, createRef, Ref } from "lit/directives/ref.js";

@customElement("canary-dialog")
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
      :root {
        --canary-color-backdrop-overlay: hsla(225, 9%, 36%, 0.66);
      }
      :root[data-theme="dark"] {
        --canary-color-backdrop-overlay: hsla(223, 13%, 10%, 0.66);
      }

      dialog::backdrop {
        background-color: var(--canary-color-backdrop-overlay);
        -webkit-backdrop-filter: blur(0.25rem);
        backdrop-filter: blur(0.25rem);
      }

      dialog {
        margin: 0 auto;
        width: 100%;
        top: 40px;
        padding: 0;
        border: none;
        outline: none;
        border-radius: 10px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }

      @media (min-width: 768px) {
        dialog {
          left: 50%;
          transform: translateX(-50%);
          max-width: 500px;
        }
      }
    `,
  ];
}
