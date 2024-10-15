import { LitElement, css, html } from "lit";
import { property } from "lit/decorators.js";
import { registerCustomElement } from "../decorators";
import { ref, createRef, Ref } from "lit/directives/ref.js";
import { classMap } from "lit/directives/class-map.js";

const NAME = "canary-dialog";

/**
 * @cssprop --canary-color-backdrop-overlay - Backdrop overlay color
 * @cssprop --canary-transition-duration - Duration of modal transition
 * @cssprop --canary-transition-timing - Timing function of modal transition
 * @slot - Default slot
 */
@registerCustomElement(NAME)
export class CanaryDialog extends LitElement {
  @property({ attribute: false })
  @property({ type: Boolean })
  transition = false;
  ref: Ref<HTMLDialogElement> = createRef();

  render() {
    const canaryDialogClasses = {
      "with-transition": this.transition,
    };

    return html`
      <dialog
        ${ref(this.ref)}
        class=${classMap(canaryDialogClasses)}
        @click=${this.handleClick}
      >
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
        margin: 0 auto;
        top: 60px;
        padding: 0;
        border: none;
        outline: none;
        border-radius: 8px;
        box-shadow:
          0 20px 25px -5px rgb(0 0 0 / 0.1),
          0 8px 10px -6px rgb(0 0 0 / 0.1);
      }

      dialog.with-transition {
        transition:
          opacity var(--canary-transition-duration, 0.5s)
            var(--canary-transition-timing, allow-discrete),
          transform var(--canary-transition-duration, 0.5s)
            var(--canary-transition-timing, allow-discrete);
      }

      dialog.with-transition[open] {
        opacity: 1;
      }

      dialog.with-transition:not([open]) {
        opacity: 0;
      }

      @starting-style {
        dialog.with-transition[open] {
          opacity: 0;
        }
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryDialog;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
