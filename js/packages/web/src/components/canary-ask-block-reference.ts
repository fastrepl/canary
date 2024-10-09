import { LitElement, html, css, nothing } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { global } from "../styles";
import type { AskResponseReferenceBlock } from "../types";

import "./canary-url-paths";
import "./canary-markdown";

const NAME = "canary-ask-block-reference";

@registerCustomElement(NAME)
export class CanaryAskBlockReference extends LitElement {
  @property({ type: Object })
  block!: AskResponseReferenceBlock;

  render() {
    if (!this.block || !this.block?.sections || !this.block.sections.length) {
      return nothing;
    }

    return html`
      <div class="container" @click=${() => this._handleClick(this.block.url)}>
        <canary-url-paths .url=${this.block.url}></canary-url-paths>
        <div class="block-title">${this.block.title}</div>
        ${this.block.sections.map(
          (section) => html`
            <div
              class="section"
              @click=${() => this._handleClick(section.url || this.block.url)}
            >
              <div class="section-title">${section.title}</div>
              <div class="section-excerpt">
                <canary-markdown .content=${section.excerpt}></canary-markdown>
              </div>
              <div class="section-explanation">
                <span class="i-heroicons-arrow-right-20-solid"></span>
                <span>${section.explanation}</span>
              </div>
            </div>
          `,
        )}
      </div>
    `;
  }

  private _handleClick(url: string) {
    window.location.href = url;
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 1rem;
        cursor: pointer;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 0.5rem;
        background-color: var(--canary-color-gray-100);
        color: var(--canary-color-gray-10);
      }

      .container:hover {
        background-color: var(--canary-color-gray-95);
      }

      .block-title {
        font-size: 1rem;
      }

      .section {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }

      .section-title {
        font-size: 0.875rem;
      }

      .section-excerpt {
        padding-left: 0.5rem;
        border-left: 2px solid var(--canary-color-primary-50);
        font-size: 0.825rem;
      }

      .section-explanation {
        display: flex;
        gap: 8px;
        align-items: center;
        padding-left: 0.5rem;
        font-size: 0.825rem;
        font-style: italic;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskBlockReference;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
