# Docusaurus

## Setup

### Installation

::: tip
If you were using `@getcanary/docusaurus-theme-search-pagefind` before, please remove it.
:::

```bash
npm install @getcanary/web
```

### Ejecting

```bash
# if you are using classic theme
npm run swizzle @docusaurus/theme-classic SearchBar -- --eject --javascript
```

::: code-group

```js [src/theme/SearchBar.js]
export { default } from "@docusaurus/Noop";
```

:::

## Configuration

After ejecting, you can edit generated files in `src/theme/SearchBar`.

```js
import React from "react";

export default function SearchBarWrapper(props) {
  const [loaded, setLoaded] = React.useState(false);

  React.useEffect(() => {
    Promise.all([
      import("@getcanary/web/components/canary-root"),
      import("@getcanary/web/components/canary-provider-cloud"),
      import("@getcanary/web/components/canary-modal"),
      import("@getcanary/web/components/canary-trigger-searchbar"),
      import("@getcanary/web/components/canary-input"),
      import("@getcanary/web/components/canary-content"),
      import("@getcanary/web/components/canary-search"),
      import("@getcanary/web/components/canary-search-results"),
      // If you want to give us a shout-out, please add this.
      import("@getcanary/web/components/canary-footer.js"),
      // Needed if you have GitHub source.
      import("@getcanary/web/components/canary-search-match-github-issue"),
      import("@getcanary/web/components/canary-search-match-github-discussion"),
    ])
      .then(() => setLoaded(true))
      .catch(console.error);
  }, []);

  if (!loaded) {
    return null;
  }

  return (
    <canary-root framework="docusaurus">
      <canary-provider-cloud project-key="YOUR_KEY">
        <canary-modal transition>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-input slot="input" autofocus></canary-input>
            <canary-search slot="mode">
              <canary-search-results slot="body"></canary-search-results>
            </canary-search>
            <canary-footer slot="footer"></canary-footer>
          </canary-content>
        </canary-modal>
      </canary-provider-cloud>
    </canary-root>
  );
}
```
