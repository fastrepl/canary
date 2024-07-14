import { html } from "lit";
import "./canary-trigger";

const render = (_: any) => {
  return html` <canary-trigger></canary-trigger> `;
};

export default {
  render,
  title: "Public/canary-trigger",
  tags: ["!autodocs"],
};

export const Light = { args: {} };
export const Dark = { args: {} };
