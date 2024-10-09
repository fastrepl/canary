import { LitElement, css, html, PropertyValues } from "lit";
import { property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import pm from "picomatch";

import { registerCustomElement } from "../decorators";
import { StringArray } from "../converters";
import { createEvent } from "../store";
import { TagUrlSyncDefinition } from "../types";

const NAME = "canary-filter-tags";

@registerCustomElement(NAME)
export class CanaryFilterTags extends LitElement {
  /**
   * @attr {string} tags - comma separated list of tags
   */
  @property({ converter: StringArray })
  tags: string[] = [];

  /**
   * @attr {object} url-sync - sync tags with URL
   */
  @property({ type: Object, attribute: "url-sync" })
  syncURL?: TagUrlSyncDefinition;

  @property({ type: String, attribute: "local-storage-key" })
  localStorageKey?: string;

  @state()
  private _selected = "";

  connectedCallback() {
    super.connectedCallback();
    this._ensureTagsConverted();
    this._initializeSelected();

    window.addEventListener("popstate", this._handlePopState.bind(this));
    this._patchHistory();
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    window.removeEventListener("popstate", this._handlePopState.bind(this));
  }

  updated(changed: PropertyValues) {
    if (changed.has("_selected") && this.localStorageKey) {
      localStorage.setItem(this.localStorageKey, this._selected);
    }

    if (changed.has("_selected")) {
      this.dispatchEvent(
        createEvent({ type: "set_query", data: { tags: [this._selected] } }),
      );
    }
  }

  private _handlePopState() {
    this._initializeSelected();
  }

  private _patchHistory() {
    if (window["__history_patched__"]) {
      return;
    }

    window["__history_patched__"] = true;

    window.history.pushState = new Proxy(window.history.pushState, {
      apply: (
        target: History["pushState"],
        thisArg: History,
        argArray: Parameters<History["pushState"]>,
      ): ReturnType<History["pushState"]> => {
        const url =
          typeof argArray[2] === "string"
            ? new URL(argArray[2], window.location.href).href
            : window.location.href;

        this._initializeSelected(url);
        return target.apply(thisArg, argArray);
      },
    });
  }

  private _ensureTagsConverted() {
    if (typeof this.tags === "string") {
      this.tags = StringArray.fromAttribute(this.tags, null);
    }
  }

  private _initializeSelected(url?: string) {
    if (this._handleSyncURL(url)) {
      return;
    }

    if (this._applyLocalStorage()) {
      return;
    }

    this._selected = this.tags[0];
  }

  private _handleSyncURL(url?: string) {
    if (!this.syncURL) {
      return false;
    }

    const { hostname, pathname } = new URL(url ?? window.location.href);
    const found = this.syncURL.find(({ pattern }) =>
      pm(pattern)(`${hostname}${pathname}`),
    );

    if (found) {
      this._selected = found.tag;
      return true;
    }

    return false;
  }

  private _applyLocalStorage() {
    if (!this.localStorageKey) {
      return false;
    }

    const storedValue = localStorage.getItem(this.localStorageKey);
    if (storedValue && this.tags.includes(storedValue)) {
      this._selected = storedValue;
      return true;
    }

    return false;
  }

  render() {
    return html`
      <div class="container" part="container">
        ${this.tags.map((tag) => {
          const selected = tag === this._selected;

          return html`<button
            @click=${() => (this._selected = tag)}
            part=${["tag", selected ? "active" : "inactive"].join(" ")}
            class=${classMap({ tag: true, active: selected })}
            aria-label=${`${tag}-tag`}
          >
            ${tag}
          </button>`;
        })}
      </div>
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: flex-start;
      gap: 8px;
      padding-top: 4px;
      padding-bottom: 4px;
    }

    .tag {
      cursor: pointer;
      font-size: 0.9em;
      padding: 1px 8px;
      min-width: 40px;

      border: 1px solid;
      border-radius: 8px;
      border-color: var(--canary-is-light, var(--canary-color-gray-80))
        var(--canary-is-dark, var(--canary-color-gray-50));

      color: var(--canary-is-light, var(--canary-color-gray-60))
        var(--canary-is-dark, var(--canary-color-gray-40));
      background-color: var(--canary-is-light, var(--canary-color-gray-95))
        var(--canary-is-dark, var(--canary-color-gray-80));
    }

    .tag:hover,
    .tag.active {
      color: var(--canary-is-light, var(--canary-color-primary-40))
        var(--canary-is-dark, var(--canary-color-primary-20));
      border-color: var(--canary-is-light, var(--canary-color-primary-80))
        var(--canary-is-dark, var(--canary-color-primary-50));
      background-color: var(--canary-is-light, var(--canary-color-primary-95))
        var(--canary-is-dark, var(--canary-color-primary-70));
    }
  `;
}

declare global {
  interface Window {
    __history_patched__?: boolean;
  }
}
