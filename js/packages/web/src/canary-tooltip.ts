import { LitElement, html, css } from "lit";
import {
  customElement,
  property,
  query,
  queryAssignedElements,
} from "lit/decorators.js";

import {
  computePosition,
  autoPlacement,
  shift,
  offset,
  arrow,
  type Placement,
} from "@floating-ui/dom";

const NAME = "canary-tooltip";

@customElement(NAME)
export class CanaryTooltip extends LitElement {
  @property({ type: String }) text = "";
  @property({ type: String }) placement: Placement = "bottom";

  @queryAssignedElements({ flatten: true })
  references!: Array<HTMLElement>;

  @query("#tooltip")
  tooltip!: HTMLDivElement;

  @query("#arrow")
  arrow!: HTMLDivElement;

  render() {
    return html`
      <slot
        @mouseenter=${this._showTooltip}
        @mouseleave=${this._hideTooltip}
        @focus=${this._showTooltip}
        @blur=${this._hideTooltip}
      ></slot>
      <div id="tooltip" role="tooltip">
        ${this.text}
        <div id="arrow"></div>
      </div>
    `;
  }

  private _showTooltip() {
    this.tooltip.style.display = "block";

    computePosition(this.references[0], this.tooltip, {
      placement: this.placement,
      middleware: [
        offset(8),
        autoPlacement(),
        shift({ padding: 6 }),
        arrow({ element: this.arrow }),
      ],
    }).then(({ x, y, placement, middlewareData }) => {
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
      });

      const { x: arrowX, y: arrowY } = middlewareData.arrow!;

      const staticSide = {
        top: "bottom",
        right: "left",
        bottom: "top",
        left: "right",
      }[placement.split("-")[0]] as string;

      Object.assign(this.arrow.style, {
        left: arrowX != null ? `${arrowX}px` : "",
        top: arrowY != null ? `${arrowY}px` : "",
        right: "",
        bottom: "",
        [staticSide]: "-4px",
      });
    });
  }
  private _hideTooltip() {
    this.tooltip.style.display = "none";
  }

  static styles = css`
    #tooltip {
      display: none;
      width: max-content;
      position: absolute;
      top: 0;
      left: 0;

      background: var(--canary-color-gray-95);
      color: var(--canary-color-gray-5);
      font-weight: bold;
      padding: 5px;
      border-radius: 4px;
      font-size: 90%;
    }

    #arrow {
      position: absolute;
      background: var(--canary-color-gray-95);
      width: 8px;
      height: 8px;
      transform: rotate(45deg);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTooltip;
  }
}
