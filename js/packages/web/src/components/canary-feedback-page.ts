import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { Task } from "@lit/task";

import { withTimeout } from "../utils";

import "./canary-loading-spinner";

const NAME = "canary-feedback-page";

@customElement(NAME)
export class CanaryFeedbackPage extends LitElement {
  @property({ type: String, attribute: "text-initial" })
  initialText = "Was this helpful?";

  @property({ type: String, attribute: "text-complete" })
  completeText = "Got it, Thank you!";

  @property({ type: String, attribute: "api-base" })
  apiBase = "https://cloud.getcanary.dev";

  @property({ type: String, attribute: "api-key" })
  apiKey = "";

  private _task = this._initTask();

  connectedCallback() {
    super.connectedCallback();

    if ("navigation" in window) {
      (window.navigation as any).addEventListener(
        "navigate",
        this._handleNavigate,
      );
    }
  }

  disconnectedCallback() {
    super.disconnectedCallback();

    if ("navigation" in window) {
      (window.navigation as any).removeEventListener(
        "navigate",
        this._handleNavigate,
      );
    }
  }

  private _initTask() {
    return new Task(this, {
      task: async (
        [endpoint, key, url, score]: [string, string, string, number],
        { signal },
      ) => {
        const response = await fetch(`${endpoint}/api/v1/feedback/page`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ key, url, score }),
          signal: withTimeout(signal, 2500),
        });

        if (!response.ok) {
          throw new Error(response.statusText);
        }

        return null;
      },
      autoRun: false,
    });
  }

  private _handleNavigate() {
    this._task = this._initTask();
  }

  render() {
    return html`
      <div class="container">
        ${this._task.render({
          initial: () => html`
            <span class="text">${this.initialText}</span>
            <span
              class="icon i-heroicons-hand-thumb-up"
              @click=${() => this._handleClick(1)}
            ></span>
            <span
              class="icon i-heroicons-hand-thumb-down"
              @click=${() => this._handleClick(-1)}
            ></span>
          `,
          pending: () =>
            html` <span class="text">${this.initialText}</span>
              <canary-loading-spinner></canary-loading-spinner>`,
          complete: () =>
            html`<span>${this.completeText}</span>
              <span class="i-heroicons-check-circle"></span> `,
          error: () => {
            console.error(this._task.error);
            return html`<div>Sorry, something went wrong.</div> `;
          },
        })}
      </div>
    `;
  }

  private _handleClick(score: number) {
    this._task.run([this.apiBase, this.apiKey, document.location.href, score]);
  }

  static styles = [
    css`
      @unocss-placeholder;
    `,
    css`
      .icon {
        cursor: pointer;
        color: var(--canary-is-light, var(--canary-color-gray-50))
          var(--canary-is-dark, var(--canary-color-gray-20));
      }
      .icon:hover {
        color: var(--canary-is-light, var(--canary-color-gray-10))
          var(--canary-is-dark, var(--canary-color-gray-0));
      }

      .text {
        margin-right: 4px;
      }

      .container {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 8px;

        width: fit-content;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 24px;
        padding: 8px 12px;

        color: var(--canary-color-gray-20);
        background-color: var(--canary-is-light, var(--canary-color-gray-100))
          var(--canary-is-dark, var(--canary-color-gray-80));
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFeedbackPage;
  }
}
