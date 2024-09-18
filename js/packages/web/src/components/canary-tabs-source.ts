import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

const NAME = "canary-tabs-source";

@customElement(NAME)
export class CanaryTabsSource extends LitElement {
  @property() tabs = [];
  @property() selected = "";

  render() {
    return html`
      <div class="container">
        ${this.tabs.map((name, index) => {
          const selected = name === this.selected;

          return html`<div
            class=${classMap({
              tab: true,
              selected,
              first: index === 0,
              last: index === this.tabs.length - 1,
            })}
            @click=${() => this._handleChangeTab(name)}
          >
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${selected}
            />
            <label for=${name}>${name}</label>
          </div>`;
        })}
      </div>
    `;
  }

  private _handleChangeTab(name: string): void {
    this.selected = name;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;

      --border-color: var(--canary-is-light, var(--canary-color-gray-90))
        var(--canary-is-dark, var(--canary-color-gray-70));
    }

    .tab {
      cursor: pointer;
      padding: 1px 12px;
      border-bottom: 1px solid var(--border-color);
      background-color: var(--canary-color-gray-100);
    }

    .tab.selected {
      border-radius: 4px 4px 0 0;

      border: 1px solid var(--border-color);
      border-bottom: none;
    }

    .tab:not(.selected):hover {
      background-color: var(--canary-color-gray-95);
    }

    label {
      font-size: 0.75rem;
      color: var(--canary-color-gray-30);
    }

    .selected label {
      color: var(--canary-color-primary-70);
    }

    input {
      display: none;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTabsSource;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
