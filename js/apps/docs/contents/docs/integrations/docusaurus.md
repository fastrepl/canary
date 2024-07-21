# Docusaurus

```bash
npm run swizzle @docusaurus/theme-classic SearchBar -- --eject --javascript
```

```js
// docusaurus.config.js
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  scripts: [ // [!code ++]
    "canary-provider-cloud", // [!code ++]
    "canary-styles-docusaurus", // [!code ++]
    "canary-modal", // [!code ++]
    "canary-trigger-searchbar", // [!code ++]
    "canary-content", // [!code ++]
    "canary-search", // [!code ++]
    "canary-search-input", // [!code ++]
    "canary-search-results", // [!code ++]
  ].map((c) => ({ // [!code ++]
    type: "module", // [!code ++]
    src: `https://unpkg.com/@getcanary/web@latest/components/${c}.js`, // [!code ++]
  })), // [!code ++]
  ...
};
```
