import { LitElement, html } from "lit";
import { parse as safeParse } from "best-effort-json-parser";

import { registerCustomElement } from "../decorators";
import { mockAskResponse } from "../msw";
import { wrapper } from "../styles";
import { createEvent } from "../store";
import { asyncSleep } from "../utils";
import type { AskFunction, SearchFunction, SearchResult } from "../types";

const NAME = "canary-provider-mock";

@registerCustomElement(NAME)
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

  search: SearchFunction = async (_payload, _meta, _signal) => {
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

  ask: AskFunction = async (_query, _meta, handleDelta, signal) => {
    let buffer = "";
    let index = 0;
    const totalLength = mockAskResponse.length;

    while (index < totalLength) {
      signal.throwIfAborted();

      const chunkSize = Math.floor(Math.random() * 3) + 10;
      const chunk = mockAskResponse.slice(index, index + chunkSize);
      buffer += chunk;

      const parsedData = safeParse(buffer);
      handleDelta(parsedData);
      await asyncSleep(Math.random() * 50 + 20);

      index += chunkSize;
    }

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
