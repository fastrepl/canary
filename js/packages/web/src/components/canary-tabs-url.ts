import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

const NAME = "canary-tabs-url";

@customElement(NAME)
export class CanaryTabsUrl extends LitElement {
  @property() tabs = [];
  @property() selected = "";

  render() {
    return html`
      <div class="container">
        ${this.tabs.map((name) => {
          const selected = name === this.selected;

          return html`<div @click=${() => this._handleChangeTab(name)}>
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${selected}
            />
            <label class=${classMap({ tab: true, selected })}> ${name} </label>
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
      align-items: center;

      padding-left: 2px;
      padding-bottom: 4px;
      gap: 8px;

      color: var(--canary-color-gray-50);
      text-decoration-color: var(--canary-color-gray-50);
    }

    .selected.tab {
      color: var(--canary-color-gray-10);
      text-decoration: underline;
      text-decoration-color: var(--canary-color-gray-10);
    }

    label {
      font-size: 0.75rem;
      text-decoration-skip-ink: none;
    }

    input {
      display: none;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTabsUrl;
  }
}
