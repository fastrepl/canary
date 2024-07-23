import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { MutationController } from "@lit-labs/observers/mutation-controller.js";

import { provide } from "@lit/context";
import { themeContext } from "./contexts";
import type { ThemeContext } from "./types";

const NAME = "canary-styles-default";

@customElement(NAME)
export class CanaryStylesDefault extends LitElement {
  @property({ type: String }) themeTag = "html";
  @property({ type: String }) themeAttr = "data-theme";

  @provide({ context: themeContext })
  @property({ type: String, reflect: true })
  theme: ThemeContext = "light";

  constructor() {
    super();

    const [target] = document.getElementsByTagName(this.themeTag);

    new MutationController(this, {
      target,
      config: { attributeFilter: [this.themeAttr] },
      callback: (mutations) => {
        const target = mutations[0]?.target as Element | undefined;
        if (!target) {
          return this.theme;
        }

        const theme = target.getAttribute(this.themeAttr);
        this.theme = (theme || this.theme) as ThemeContext;
        return this.theme;
      },
    });
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = [
    css`
      :host {
        --canary-font-family: Arial, Helvetica, sans-serif;
      }
    `,
    css`
      :host {
        --canary-theme: "light";

        --l-0: 0%;
        --l-10: 10%;
        --l-20: 20%;
        --l-30: 30%;
        --l-40: 40%;
        --l-50: 50%;
        --l-60: 60%;
        --l-70: 70%;
        --l-80: 80%;
        --l-90: 90%;
        --l-100: 100%;
      }

      :host([theme="dark"]) {
        --canary-theme: "dark";

        --l-0: 100%;
        --l-10: 90%;
        --l-20: 80%;
        --l-30: 70%;
        --l-40: 60%;
        --l-50: 50%;
        --l-60: 40%;
        --l-70: 30%;
        --l-80: 20%;
        --l-90: 10%;
        --l-100: 0%;
      }
    `,
    // prettier-ignore
    css`
      :host {
        --_canary-color-primary-ch: var(--canary-color-primary-ch, 30 296);
        --_canary-color-gray-ch: var(--canary-color-gray-ch, 0 0);

        --canary-color-primary-0: lch(var(--l-0) var(--_canary-color-primary-ch));
        --canary-color-primary-10: lch(var(--l-10) var(--_canary-color-primary-ch));
        --canary-color-primary-20: lch(var(--l-20) var(--_canary-color-primary-ch));
        --canary-color-primary-30: lch(var(--l-30) var(--_canary-color-primary-ch));
        --canary-color-primary-40: lch(var(--l-40) var(--_canary-color-primary-ch));
        --canary-color-primary-50: lch(var(--l-50) var(--_canary-color-primary-ch));
        --canary-color-primary-60: lch(var(--l-60) var(--_canary-color-primary-ch));
        --canary-color-primary-70: lch(var(--l-70) var(--_canary-color-primary-ch));
        --canary-color-primary-80: lch(var(--l-80) var(--_canary-color-primary-ch));
        --canary-color-primary-90: lch(var(--l-90) var(--_canary-color-primary-ch));
        --canary-color-primary-100: lch(var(--l-100) var(--_canary-color-primary-ch));
        
        --canary-color-gray-0: lch(var(--l-0) var(--_canary-color-gray-ch));
        --canary-color-gray-10: lch(var(--l-10) var(--_canary-color-gray-ch));
        --canary-color-gray-20: lch(var(--l-20) var(--_canary-color-gray-ch));
        --canary-color-gray-30: lch(var(--l-30) var(--_canary-color-gray-ch));
        --canary-color-gray-40: lch(var(--l-40) var(--_canary-color-gray-ch));
        --canary-color-gray-50: lch(var(--l-50) var(--_canary-color-gray-ch));
        --canary-color-gray-60: lch(var(--l-60) var(--_canary-color-gray-ch));
        --canary-color-gray-70: lch(var(--l-70) var(--_canary-color-gray-ch));
        --canary-color-gray-80: lch(var(--l-80) var(--_canary-color-gray-ch));
        --canary-color-gray-90: lch(var(--l-90) var(--_canary-color-gray-ch));
        --canary-color-gray-100: lch(var(--l-100) var(--_canary-color-gray-ch));
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryStylesDefault;
  }
}
