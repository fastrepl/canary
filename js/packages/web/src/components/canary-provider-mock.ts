import { LitElement, html } from "lit";
import { customElement } from "lit/decorators.js";

import type { Delta } from "../types";
import { wrapper } from "../styles";

const NAME = "canary-provider-mock";

@customElement(NAME)
export class CanaryProviderMock extends LitElement {
  connectedCallback() {
    super.connectedCallback();

    this.dispatchEvent(
      new CustomEvent("register-operations", {
        detail: { search: this.search, ask: this.ask },
        bubbles: true,
        composed: true,
      }),
    );
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (_query: string, _signal?: AbortSignal) => {
    await new Promise((resolve) =>
      setTimeout(resolve, Math.random() * 300 + 200),
    );
    return [
      {
        title: "title 1",
        url: "https://example.com/docs/a/b",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 2",
        url: "https://example.com/docs/a/c",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 3",
        url: "https://example.com/docs/a/d",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 4",
        url: "https://example.com/docs/a/e",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 5",
        url: "https://example.com/docs/b/c/e",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 6",
        url: "https://example.com/api/a/b",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 7",
        url: "https://example.com/api/a/c",
        excerpt: "this is <mark>a match</mark>.",
      },
      {
        title: "title 8",
        url: "https://example.com/api/a/d",
        excerpt: "this is <mark>a match</mark>.",
      },
    ];
  };

  ask = async (
    _id: number,
    _query: string,
    handleDelta: (delta: Delta) => void = () => {},
    _signal?: AbortSignal,
  ) => {
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
}
