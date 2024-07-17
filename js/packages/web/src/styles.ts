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
    background-color: var(--canary-color-gray-6);
    margin-bottom: 8px;
  }
  button:hover {
    background-color: var(--canary-color-accent-low);
  }

  div {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  span {
    font-weight: bold;
    color: var(--canary-color-gray-2);
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
    color: var(--canary-color-gray-1);
    background-color: var(--canary-color-black);
  }

  input {
    width: 100%;
    height: 30px;
    outline: none;
    border: none;
    font-size: 16px;
    color: var(--canary-color-gray-1);
    background-color: var(--canary-color-black);
  }

  input::placeholder {
    color: var(--canary-color-gray-3);
    font-size: 14px;
  }

  canary-hero-icon {
    width: 24px;
  }
`;
