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

export const mockSearchReference = (query: string) => {
  return {
    title: "456",
    url: `https://example.com/a/b?query=${query}`,
    excerpt: `mock response for <mark>${query}</mark>!`,
  };
};

export const mockAskReference = () => {
  return {
    title: "456",
    url: "https://example.com/a/b",
  };
};
