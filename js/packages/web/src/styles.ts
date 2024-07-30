import { css } from "lit";

export const callout = css`
  button {
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    border: none;
    border-radius: 8px;
    padding: 8px 16px;
    margin-bottom: 8px;
    background-color: var(--canary-is-light, var(--canary-color-primary-90))
      var(--canary-is-dark, var(--canary-color-primary-80));
  }
  button:hover {
    background-color: var(--canary-is-light, var(--canary-color-primary-95))
      var(--canary-is-dark, var(--canary-color-primary-70));
  }

  div {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  span {
    font-weight: bold;
    color: var(--canary-color-gray-0);
  }
`;

export const input = css`
  :host {
    flex-grow: 1;
  }

  .container {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 4px;
    border-radius: 8px;
    background-color: var(--canary-color-gray-100);
  }

  input {
    width: 100%;
    height: 30px;
    outline: none;
    border: none;
    font-size: 16px;
    color: var(--canary-color-gray-10);
    background-color: var(--canary-color-gray-100);
  }

  input::placeholder {
    color: var(--canary-color-gray-40);
    font-size: 14px;
  }

  canary-hero-icon {
    width: 24px;
  }
`;

export const logo = css`
  :host {
    display: contents;
  }

  svg {
    height: 20px;
    max-width: 50px;
  }
`;

export const wrapper = css`
  :host {
    display: contents;
  }
`;

export const scrollContainer = css`
  .container {
    overflow-y: scroll;
    padding-right: 4px;
    scrollbar-width: thin;
    scrollbar-color: var(--canary-is-light, var(--canary-color-gray-90))
      var(--canary-is-dark, var(--canary-color-gray-60))
      var(--canary-color-gray-100);
  }
`;
