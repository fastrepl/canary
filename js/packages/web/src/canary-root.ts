import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { MutationController } from "@lit-labs/observers/mutation-controller.js";

import { provide } from "@lit/context";
import {
  themeContext,
  operationContext,
  defaultOperationContext,
} from "./contexts";

import type { Framework, ThemeContext, OperationContext } from "./types";
import { wrapper } from "./styles";

const NAME = "canary-root";

@customElement(NAME)
export class CanaryRoot extends LitElement {
  @property({ type: String }) framework: Framework = "starlight";

  @provide({ context: themeContext })
  @property({ type: String, reflect: true })
  theme: ThemeContext = "light";

  @provide({ context: operationContext })
  @state()
  operation: OperationContext = defaultOperationContext;

  connectedCallback() {
    super.connectedCallback();
    this._handleThemeChange();

    this.addEventListener("register", this._handleRegister);
  }

  disconnectedCallback() {
    this.removeEventListener("register", this._handleRegister);
  }

  render() {
    return html`<slot></slot>`;
  }

  private _handleThemeChange() {
    const [target] = document.getElementsByTagName("html");
    const useClassList = this.framework === "vitepress";

    const extractTheme = (el: Element) => {
      if (useClassList) {
        return el.classList.contains("dark") ? "dark" : "light";
      } else {
        return (el.getAttribute("data-theme") || this.theme) as ThemeContext;
      }
    };

    this.theme = extractTheme(target);

    new MutationController(this, {
      target,
      config: { attributeFilter: [useClassList ? "class" : "data-theme"] },
      callback: (mutations) => {
        const target = mutations[0]?.target as Element | undefined;
        if (!target) {
          return this.theme;
        }

        return (this.theme = extractTheme(target));
      },
    });
  }

  private _handleRegister(e: Event) {
    const ctx: OperationContext = (e as CustomEvent).detail;
    this.operation = { ...this.operation, ...ctx };
  }

  static styles = [
    wrapper,
    css`
      :host {
        font-family: var(
          --canary-font-family-base,
          Arial,
          Helvetica,
          sans-serif
        );
        --canary-font-family-mono: Consolas, Monaco, Lucida Console;

        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }
    `,
    css`
      :host {
        --canary-is-light: initial;
        --canary-is-dark: ;

        --l-0: 0%;
        --l-5: 0%;
        --l-10: 10%;
        --l-20: 20%;
        --l-30: 30%;
        --l-40: 40%;
        --l-50: 50%;
        --l-60: 60%;
        --l-70: 70%;
        --l-80: 80%;
        --l-90: 90%;
        --l-95: 95%;
        --l-100: 100%;
      }

      :host([theme="dark"]) {
        --canary-is-light: ;
        --canary-is-dark: initial;

        --l-0: 100%;
        --l-5: 95%;
        --l-10: 90%;
        --l-20: 80%;
        --l-30: 70%;
        --l-40: 60%;
        --l-50: 50%;
        --l-60: 40%;
        --l-70: 30%;
        --l-80: 20%;
        --l-90: 10%;
        --l-95: 5%;
        --l-100: 0%;
      }
    `,
    // prettier-ignore
    css`
      :host {
        --_canary-color-primary-c: var(--canary-color-primary-c, 0.1);
        --_canary-color-primary-h: var(--canary-color-primary-h, 270);
        --canary-color-primary-ch: var(--_canary-color-primary-c) var(--_canary-color-primary-h);

        --_canary-color-gray-c: var(--canary-color-gray-c, 0);
        --_canary-color-gray-h: var(--canary-color-gray-h, 0);
        --canary-color-gray-ch: var(--_canary-color-gray-c) var(--_canary-color-gray-h);

        --canary-color-backdrop-overlay: oklch(var(--l-80) var(--_canary-color-gray-ch) / 0.66);

        --canary-color-primary-0: oklch(var(--l-0) var(--canary-color-primary-ch));
        --canary-color-primary-5: oklch(var(--l-5) var(--canary-color-primary-ch));
        --canary-color-primary-10: oklch(var(--l-10) var(--canary-color-primary-ch));
        --canary-color-primary-20: oklch(var(--l-20) var(--canary-color-primary-ch));
        --canary-color-primary-30: oklch(var(--l-30) var(--canary-color-primary-ch));
        --canary-color-primary-40: oklch(var(--l-40) var(--canary-color-primary-ch));
        --canary-color-primary-50: oklch(var(--l-50) var(--canary-color-primary-ch));
        --canary-color-primary-60: oklch(var(--l-60) var(--canary-color-primary-ch));
        --canary-color-primary-70: oklch(var(--l-70) var(--canary-color-primary-ch));
        --canary-color-primary-80: oklch(var(--l-80) var(--canary-color-primary-ch));
        --canary-color-primary-90: oklch(var(--l-90) var(--canary-color-primary-ch));
        --canary-color-primary-95: oklch(var(--l-95) var(--canary-color-primary-ch));
        --canary-color-primary-100: oklch(var(--l-100) var(--canary-color-primary-ch));
        
        --canary-color-gray-0: oklch(var(--l-0) var(--canary-color-gray-ch));
        --canary-color-gray-5: oklch(var(--l-5) var(--canary-color-gray-ch));
        --canary-color-gray-10: oklch(var(--l-10) var(--canary-color-gray-ch));
        --canary-color-gray-20: oklch(var(--l-20) var(--canary-color-gray-ch));
        --canary-color-gray-30: oklch(var(--l-30) var(--canary-color-gray-ch));
        --canary-color-gray-40: oklch(var(--l-40) var(--canary-color-gray-ch));
        --canary-color-gray-50: oklch(var(--l-50) var(--canary-color-gray-ch));
        --canary-color-gray-60: oklch(var(--l-60) var(--canary-color-gray-ch));
        --canary-color-gray-70: oklch(var(--l-70) var(--canary-color-gray-ch));
        --canary-color-gray-80: oklch(var(--l-80) var(--canary-color-gray-ch));
        --canary-color-gray-90: oklch(var(--l-90) var(--canary-color-gray-ch));
        --canary-color-gray-95: oklch(var(--l-95) var(--canary-color-gray-ch));
        --canary-color-gray-100: oklch(var(--l-100) var(--canary-color-gray-ch));
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryRoot;
  }
}
