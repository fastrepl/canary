import { html } from "lit";
import "./canary-loading-dots";

const render = (_: any) => {
  return html` <canary-loading-dots></canary-loading-dots> `;
};

export default {
  render,
  title: "Private/canary-loading-dots",
  tags: ["!autodocs"],
};

export const Default = { args: {} };
