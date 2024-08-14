import { LitElement, html, css } from "lit";
import { ref, createRef } from "lit/directives/ref.js";
import { customElement, property } from "lit/decorators.js";

import { marked, type MarkedExtension, type Tokens } from "marked";
import footNote from "marked-footnote";

const footNoteExtension = footNote() as MarkedExtension;
marked.use(footNoteExtension).use({
  gfm: true,
  breaks: true,
  extensions: [
    {
      name: "link",
      renderer(token) {
        const tok = token as Tokens.Link;
        return `<a href="${tok.href}" target="_self">${tok.text}</a>`;
      },
    },
  ],
});

import hljs from "highlight.js/lib/core";
import javascript from "highlight.js/lib/languages/javascript";
hljs.registerLanguage("javascript", javascript);

import { global } from "../styles";

const NAME = "canary-markdown";

@customElement(NAME)
export class CanaryMarkdown extends LitElement {
  @property({ type: String }) hljs = "github-dark";
  @property({ attribute: false }) content = "";

  private _domparser = new DOMParser();
  private _containerRef = createRef<HTMLDivElement>();

  render() {
    return html`
      <link
        rel="stylesheet"
        href="https://unpkg.com/highlight.js@11.9.0/styles/${this.hljs}.css"
      />
      <div class="container" ${ref(this._containerRef)}></div>
    `;
  }

  updated(changedProperties: Map<string, any>) {
    if (changedProperties.has("content")) {
      marked(this.content, { async: true }).then((html) => {
        const container = this._containerRef.value;
        if (!container) {
          return;
        }

        const { body: virtual } = this._domparser.parseFromString(
          html,
          "text/html",
        );

        const footnotes = virtual.querySelector("section.footnotes");
        if (footnotes) {
          const sups = virtual.getElementsByTagName("sup");
          for (const sup of sups) {
            sup.innerHTML = sup.textContent ?? "";
          }
          virtual.removeChild(footnotes);
        }

        container.innerHTML = virtual.innerHTML;
        container.querySelectorAll("pre code").forEach((code) => {
          code.className = "language-javascript";
          hljs.highlightElement(code as HTMLElement);
        });
      });
    }
  }

  // https://github.com/unocss/unocss/blob/main/packages/preset-typography/src/preflights/default.ts
  static styles = [
    global,
    css`
      .container {
        font-size: 14px;
        color: var(--canary-color-gray-20);
        background-color: var(--canary-is-light, var(--canary-color-gray-100))
          var(--canary-is-dark, var(--canary-color-gray-90));
      }
    `,
    css`
      h1,
      h2,
      h3,
      h4,
      h5,
      h6 {
        font-weight: 600;
        line-height: 1.25;
        margin: 1em 0 0.2em 0;
      }

      h1 {
        margin-top: 0;
      }

      h1 {
        font-size: 1.3em;
      }
      h2 {
        font-size: 1.2em;
      }
      h3 {
        font-size: 1.1em;
      }
    `,
    css`
      :not(pre) > code::before,
      :not(pre) > code::after {
        content: "";
      }

      :not(pre) > code {
        padding: 0.1em 0.2em;
        border-radius: 0.2em;

        color: var(--canary-is-light, var(--canary-color-gray-0))
          var(--canary-is-dark, var(--canary-color-gray-90));

        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-20));
      }

      pre > code {
        font-size: 0.875em;
        font-family: var(--canary-font-family-mono);
        border-radius: 0.5em;
      }
    `,
    css`
      hr {
        margin: 1em 0;
        border: 1px solid var(--canary-is-light, var(--canary-color-gray-80))
          var(--canary-is-dark, var(--canary-color-gray-50));
      }

      :not(sup) > a {
        color: var(--canary-is-light, var(--canary-color-primary-50))
          var(--canary-is-dark, var(--canary-color-primary-20));
        text-decoration: underline;
      }

      sup {
        font-size: 0.875em;
        padding: 0.1em 0.2em;
        border-radius: 0.2em;

        color: var(--canary-is-light, var(--canary-color-gray-0))
          var(--canary-is-dark, var(--canary-color-gray-90));

        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-20));
      }
    `,
    css`
      ol,
      ul {
        padding-left: 1.25em;
      }

      ol {
        list-style-type: decimal;
      }

      ul {
        list-style-type: disc;
      }

      ol > li::marker,
      ul > li::marker {
        color: var(--canary-color-gray-10);
      }

      ol,
      ul {
        margin-top: 0.2em;
      }
      li {
        margin-top: 0.1em;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryMarkdown;
  }
}
