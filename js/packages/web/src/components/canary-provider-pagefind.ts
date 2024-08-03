import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type {
  BeforeSearchFunction,
  SearchFunction,
  SearchReference,
} from "../types";
import type { PagefindResult } from "../types/pagefind";

import { cancellable } from "../utils";
import { customEvent } from "../events";
import { wrapper } from "../styles";

const NAME = "canary-provider-pagefind";

type Options = {
  path?: string;
  styles?: Record<string, string>;
  pagefind?: { ranking: Record<string, number> };
};

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @property({ type: Object }) options: Options = {};
  @state() pagefind: any = null;

  private _limit = 30;

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    this._initPagefind(pagefind);

    this.dispatchEvent(
      customEvent({
        name: "register-operations",
        data: { search: this.search, beforeSearch: this.beforeSearch },
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
      pagefind.init();
      if (this.options.pagefind) {
        await pagefind.options(this.options.pagefind);
      }
      this.pagefind = pagefind;
    } catch (e) {
      throw new Error(`Failed to initialize pagefind': ${e}`);
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  beforeSearch: BeforeSearchFunction = async (query) => {
    this.pagefind.preload(query);
  };

  search: SearchFunction = async (
    query: string,
    signal: AbortSignal,
  ): Promise<SearchReference[] | null> => {
    const op = this.pagefind
      .search(query)
      .then(({ results }: any) =>
        Promise.all(
          results.slice(0, this._limit).map((r: any) => r.data()),
        ).then((results: PagefindResult[]) => this._transform(results)),
      );

    try {
      signal.throwIfAborted();
      return cancellable(op, signal);
    } catch (e) {
      console.error(e);
      return null;
    }
  };

  private _transform(results: PagefindResult[]): SearchReference[] | null {
    const subResults = results.flatMap((result) => {
      return result.sub_results.map((subResult) => ({
        ...subResult,
        meta: result.meta,
      }));
    });

    const getBestScore = (subResult: (typeof subResults)[0]) =>
      subResult.weighted_locations.reduce(
        (acc, cur) => Math.max(acc, cur.balanced_score),
        -1,
      );

    const getTitles = (subResult: (typeof subResults)[0]) => {
      return subResult.meta.title === subResult.title
        ? []
        : [subResult.meta.title];
    };

    return subResults
      .sort((a, b) => getBestScore(b) - getBestScore(a))
      .map((result) => {
        const ref: SearchReference = {
          url: result.url,
          title: result.title,
          titles: getTitles(result),
        };

        return ref;
      })
      .slice(0, this._limit);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
