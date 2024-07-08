import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ref, createRef, Ref } from "lit/directives/ref.js";

@customElement("canary-dialog")
export class CanaryDialog extends LitElement {
  @property({ attribute: false })
  ref: Ref<HTMLDialogElement> = createRef();

  firstUpdated() {
    document.addEventListener("click", this.handleClick.bind(this));
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    document.removeEventListener("click", this.handleClick.bind(this));
  }

  private handleClick(e: MouseEvent) {
    const dialog = this.ref.value;
    if (dialog?.open && e.target instanceof CanaryDialog) {
      dialog.close();
    }
  }

  render() {
    return html`
      <dialog ${ref(this.ref)}>
        <slot></slot>
      </dialog>
    `;
  }

  static styles = [
    css`
      dialog {
        margin: 0;
        padding: 0;
        top: 40px;
        left: 50%;
        transform: translateX(-50%);
        border: none;
        outline: none;
        border-radius: 10px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }

      dialog::backdrop {
        background-color: rgba(0, 0, 0, 0.2);
      }
    `,
  ];
}
