import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-markdown";

export default {
  title: "Public/canary-markdown",
  parameters: { sourceLink: "components/canary-markdown.stories.ts" },
  render: ({ content }: any) => {
    return html`
      <div
        style="width: 500px; padding: 12px; border: 1px solid black; border-radius: 8px;"
      >
        <canary-markdown .content=${content}></canary-markdown>
      </div>
    `;
  },
} satisfies Meta;

export const Example: StoryObj = {
  args: {
    content: `
# Heading 1

Lorem ipsum odor amet, consectetuer adipiscing elit. Sapien himenaeos habitasse iaculis massa facilisi sit; neque in. Sem sollicitudin dolor aliquam at lectus.

## Heading 2

Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.

### Heading 3

- Unordered list item 1
- Unordered list item 2
  - Nested list item 1
  - Nested list item 2
    - Nested nested item

1. Ordered list item 1
2. Ordered list item 2
   1. Nested ordered item 1
   2. Nested ordered item 2

### Blockquote

> This is a blockquote.
> 
> Multiline blockquote with **bold text** and *italic text*.

### Inline Code

This is an example of \`inline code\` inside a sentence.

\`${Array(20).fill("Hello").join(" ")}\`

### Code Block

\`\`\`python
def hello_world():
    print(${Array(20).fill("Hello").join(" ")})

hello_world()
\`\`\`

### Horizontal Rule

---

### Bold and Italic Text

This text is **bold**, this is *italic*, and this is ***both bold and italic***.

### Superscript

Here is a footnote[^1].

Here is another footnote[^2].

[^1]: This is a footnote content.
[^2]: This is another footnote content.

### Links

Here is a [link to Google](https://www.google.com).

### Images

![Alt text for the image](https://via.placeholder.com/150)`,
  },
};
