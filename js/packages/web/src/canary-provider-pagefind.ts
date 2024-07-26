import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type { Reference } from "./types";
import type { PagefindResult } from "./types/pagefind";
import { wrapper } from "./styles";

const NAME = "canary-provider-pagefind";

type Options = {
  path?: string;
  styles?: Record<string, string>;
  pagefind?: { ranking: Record<string, number> };
};

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @property({ type: Object }) options: Options = {};
  @state() pagefind: { search: (query: string) => Promise<any> } | null = null;

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    this._initPagefind(pagefind);
    this._applyStyles();

    this.dispatchEvent(
      new CustomEvent("register", {
        detail: { search: this.search },
        bubbles: true,
        composed: true,
      }),
    );
  }

  private async _importPagefind() {
    try {
      return import(
        /* @vite-ignore */
        /* webpackIgnore: true */
        this.options?.path ?? "/pagefind/pagefind.js"
      );
    } catch (e) {
      throw new Error(`Failed to import pagefind': ${e}`);
    }
  }

  private async _initPagefind(pagefind: any) {
    try {
      if (this.options.pagefind) {
        await pagefind.options(this.options.pagefind);
      }

      pagefind.init();
      this.pagefind = pagefind;
    } catch (e) {
      throw new Error(`Failed to initialize pagefind': ${e}`);
    }
  }

  private _applyStyles() {
    if (this.options.styles) {
      Object.entries(this.options.styles).forEach(([key, value]) => {
        document.body.style.setProperty(key, value);
      });
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (query: string, _?: AbortSignal): Promise<Reference[]> => {
    const { results } = await this.pagefind!.search(query);

    return Promise.all(
      results.map((result: any) =>
        result.data().then((data: PagefindResult) => {
          const { subResult } = data.sub_results.reduce(
            (acc, cur) => {
              const current = cur.weighted_locations.reduce(
                (acc, cur) => Math.max(acc, cur.balanced_score),
                -1,
              );

              return current > acc.score
                ? { subResult: cur, score: current }
                : acc;
            },
            { subResult: data.sub_results[0], score: -1 },
          );

          return {
            url: subResult.url,
            title: `${subResult.title} | ${data.meta.title}`,
            excerpt: subResult.excerpt,
          };
        }),
      ),
    );
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
