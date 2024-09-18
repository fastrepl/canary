import { LitElement, html, css } from "lit";
import { ref, createRef } from "lit/directives/ref.js";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import { themeContext } from "../contexts";
import { ThemeContext } from "../types";
import { global, codeBlockScrollbar } from "../styles";

import { highlightElement } from "prismjs";
import { marked, type MarkedExtension, type Tokens } from "marked";
import footNote from "marked-footnote";

import "./canary-reference";

const footNoteExtension = footNote() as MarkedExtension;
marked.use(footNoteExtension).use({
  gfm: false,
  breaks: false,
  extensions: [
    {
      name: "link",
      renderer(token) {
        const tok = token as Tokens.Link;
        return `<a href="${tok.href}" target="_self">${tok.text}</a>`;
      },
    },
  ],
  hooks: {
    preprocess(md: string) {
      const TAG = "canary".substring(0, 3);

      const lastOpen = md.lastIndexOf(`<${TAG}`);
      const lastClose = md.lastIndexOf(`</${TAG}`);

      if (lastOpen > lastClose) {
        return md.substring(0, lastOpen);
      }

      return md;
    },
  },
});

const NAME = "canary-markdown";

@customElement(NAME)
export class CanaryMarkdown extends LitElement {
  @consume({ context: themeContext, subscribe: true })
  theme?: ThemeContext;

  @property({ attribute: false })
  content = "";

  @property({ attribute: false })
  languages = [];

  private _domparser = new DOMParser();
  private _containerRef = createRef<HTMLDivElement>();

  render() {
    const stylePath = `https://unpkg.com/prism-themes@1.9.0/themes/prism-one-${this.theme ?? "light"}.min.css`;

    return html`
      <link rel="stylesheet" href=${stylePath} />
      ${this.languages.map((lang) =>
        this._script(
          `https://unpkg.com/prismjs@1.29.0/components/prism-${lang}.min.js`,
        ),
      )}
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

        container.innerHTML = virtual.innerHTML;
        this._highlight(container);
      });
    }
  }

  private _script(src: string) {
    const script = document.createElement("script");
    script.onload = () => {
      if (!this._containerRef.value) {
        return;
      }

      this._highlight(this._containerRef.value);
    };
    script.src = src;
    return script;
  }

  private _highlight(el: HTMLElement) {
    el.querySelectorAll("pre code").forEach((el) => {
      highlightElement(el, false);
    });
  }

  // https://github.com/unocss/unocss/blob/main/packages/preset-typography/src/preflights/default.ts
  static styles = [
    global,
    codeBlockScrollbar,
    css`
      .container {
        font-size: 0.875rem;
        text-wrap: wrap;

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
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
