import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { unsafeHTML } from "lit/directives/unsafe-html.js";
import { marked } from "marked";

import hljs from "highlight.js/lib/core";
import javascript from "highlight.js/lib/languages/javascript";
hljs.registerLanguage("javascript", javascript);

@customElement("canary-markdown")
export class CanaryMarkdown extends LitElement {
  @property({ type: String }) hljs = "github-dark";
  @property({ attribute: false }) content = "";
  @state() html = "";

  render() {
    return html`
      <link
        rel="stylesheet"
        href="https://unpkg.com/highlight.js@11.9.0/styles/${this.hljs}.css"
      />
      <div class="container">${unsafeHTML(this.html)}</div>
    `;
  }

  updated(changedProperties: Map<string, any>) {
    if (changedProperties.has("content")) {
      marked(this.content, { async: true }).then((html) => {
        const span = document.createElement("span");
        span.innerHTML = html;

        span.querySelectorAll("pre code").forEach((code) => {
          code.className = "language-javascript";
          hljs.highlightElement(code as HTMLElement);
        });

        this.html = span.innerHTML;
        span.remove();
      });
    }
  }

  static styles = css`
    .container {
      font-family: var(--canary-font-family);
      color: var(--canary-color-gray-1);
      background-color: var(--canary-color-black);
      font-size: 14px;
    }

    h1,
    h2,
    h3,
    h4,
    h5,
    h6 {
      font-size: 1.25em;
    }

    pre,
    code {
      border-radius: 8px;
    }
  `;
}
