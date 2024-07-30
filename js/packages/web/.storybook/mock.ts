import type { SearchReference, AskReference } from "../src/types";

export const MOCK_RESPONSE = `
# The Whimsical World of Flibbertigibbets

## Introduction

In the land of Zorkle, flibbertigibbets roam free, spreading their peculiar brand of gobbledygook wherever they wander. 

\`\`\`python
def hello():
  print("hello")

hello()
\`\`\`

## Key Characteristics of Flibbertigibbets

1. **Appearance**
   - Resemble a cross between a turnip and a disco ball
   - Sport iridescent feathers made of crystallized bubblegum

2. **Behavior**
   - Communicate through interpretive dance and armpit noises
   - Have a peculiar fondness for wearing monocles on their elbows
`.trim();

export const mockSearchReferences = (query: string): SearchReference[] => {
  return [
    {
      title: "456",
      titles: ["aaaa", "bbb"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "789",
      titles: ["aaaa", "bbb"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "123",
      titles: [],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "234",
      titles: ["bbb"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "234",
      titles: ["ccc"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "234",
      titles: ["ccc"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
    {
      title: "234",
      titles: ["ccc"],
      url: `https://example.com/a/b?query=${query}`,
      excerpt: `mock response for <mark>${query}</mark>!`,
    },
  ];
};

export const mockAskReference = (): AskReference => {
  return {
    title: "456",
    url: "https://example.com/a/b",
  };
};
