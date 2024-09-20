import { LitElement, html } from "lit";
import { customElement } from "lit/decorators.js";

import type { AskFunction, SearchFunction, SearchResult } from "../types";
import { wrapper } from "../styles";
import { createEvent } from "../store";

const NAME = "canary-provider-mock";

@customElement(NAME)
export class CanaryProviderMock extends LitElement {
  connectedCallback() {
    super.connectedCallback();

    this.dispatchEvent(
      createEvent({
        type: "register_operations",
        data: { search: this.search, ask: this.ask },
      }),
    );
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search: SearchFunction = async (_payload, _signal) => {
    await new Promise((resolve) =>
      setTimeout(resolve, Math.random() * 300 + 200),
    );

    const matches: SearchResult[] = [
      {
        type: "webpage",
        title: "Page title 1",
        url: "https://example.com/a",
        excerpt: "this is <mark>a match</mark>.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/a#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
        meta: {},
      },
      {
        type: "webpage",
        title: "Page title 2",
        url: "https://example.com/b",
        excerpt: "this is <mark>a match</mark>.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/b#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
          {
            title: "Page sub title 2",
            url: "https://example.com/b#sub-2",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
        meta: {},
      },
      {
        type: "webpage",
        title: "Page title 3",
        url: "https://example.com/c",
        excerpt: "this is <mark>a match</mark>.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/c#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
          {
            title: "Page sub title 2",
            url: "https://example.com/c#sub-2",
            excerpt: "this is <mark>a match</mark>.",
          },
          {
            title: "Page sub title 3",
            url: "https://example.com/c#sub-3",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
        meta: {},
      },
    ];

    return { matches };
  };

  ask: AskFunction = async (_payload, handleDelta, _signal) => {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    handleDelta({ type: "progress", content: "hello" });
    await new Promise((resolve) => setTimeout(resolve, 100));
    handleDelta({ type: "progress", content: " world" });
    await new Promise((resolve) => setTimeout(resolve, 200));
    handleDelta({ type: "progress", content: " !" });
    return null;
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderMock;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
