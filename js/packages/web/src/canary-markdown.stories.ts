import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-markdown";

const render = ({ content }: any) => {
  return html` <canary-markdown .content=${content}></canary-markdown> `;
};

export default {
  render,
  title: "Public/canary-markdown",
  parameters: {
    sourceLink: "canary-markdown.stories.ts",
  },
} satisfies Meta;

export const Headers: StoryObj = {
  args: {
    content: `
# Hello World
123

## Hello World
234

### Hello World
345`,
  },
};

export const Code: StoryObj = {
  args: {
    content: `
\`\`\`python
def hello():
  print("hello")
\`\`\`

\`\`\`
const hello = () => {
  console.log("hello");
};
\`\`\``,
  },
};
