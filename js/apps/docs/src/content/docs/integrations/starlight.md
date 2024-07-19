---
title: Integrations - Starlight
---

You can [override](https://starlight.astro.build/reference/overrides/#search) Starlight's default search component to use Canary's.

```diff
# astro.config.mjs
# load more components as needed
export default defineConfig({
  integrations: [
    starlight({
+      components: { Search: "./src/components/search.astro" },
+      head: [
+        ...[
+          "canary-provider-pagefind",
+          "canary-styles-starlight",
+          "canary-modal",
+          "canary-trigger-searchbar",
+          "canary-content",
+          "canary-search",
+          "canary-search-input",
+          "canary-search-results",
+        ].map((c) => ({
+          tag: "script",
+          attrs: {
+            type: "module",
+            src: `https://unpkg.com/@getcanary/web@latest/components/${c}.js`,
+          },
+        })),
+      ],
    }),
  ],
});
```

Now you can define your own search component.

It will look like below, but you can customize it to your liking.

```html
# src/components/search.astro
<canary-styles-starlight>
  <canary-provider-pagefind baseUrl="https://docs.getcanary.dev">
    <canary-modal>
      <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
      <canary-content slot="content">
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
      </canary-content>
    </canary-modal>
  </canary-provider-pagefind>
</canary-styles-starlight>
```

Two things to note:

1. `canary-provider-pagefind` lets you use existing search index from Pagefind.
2. `canary-styles-starlight` reads the theme from Starlight and applies it to Canary.
