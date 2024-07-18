---
title: Integrations - Docusaurus
---

```bash
npm run swizzle @docusaurus/theme-classic SearchBar -- --eject --javascript
```

```diff
// docusaurus.config.js
/** @type {import('@docusaurus/types').Config} */
const config = {
+  scripts: [
+    "canary-provider-cloud",
+    "canary-styles-docusaurus",
+    "canary-modal",
+    "canary-trigger-searchbar",
+    "canary-content",
+    "canary-search",
+    "canary-search-input",
+    "canary-search-results",
+  ].map((c) => ({
+    type: "module",
+    src: `https://unpkg.com/@getcanary/web@0.0.31/components/${c}.js`,
+  })),
};
```
