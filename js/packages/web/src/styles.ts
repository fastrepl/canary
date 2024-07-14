import { css } from "lit";

export const content = css`
  h1,
  h2,
  h3,
  h4,
  h5,
  h6 {
    font-size: 1.25em;
  }
`;

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
