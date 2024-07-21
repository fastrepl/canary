# Starlight

You can [override](https://starlight.astro.build/reference/overrides/#search) Starlight's default search component to use Canary's.

```js
# astro.config.mjs
export default defineConfig({
  integrations: [
    starlight({
      components: { Search: "./src/components/search.astro" }, // [!code ++]
      head: [ // [!code ++]
        ...[ // [!code ++]
          "canary-provider-pagefind", // [!code ++]
          "canary-styles-starlight", // [!code ++]
          "canary-modal", // [!code ++]
          "canary-trigger-searchbar", // [!code ++]
          "canary-content", // [!code ++]
          "canary-search",  // [!code ++]
          "canary-search-input", // [!code ++]
          "canary-search-results", // [!code ++]
        ].map((c) => ({ // [!code ++]
          tag: "script", // [!code ++]
          attrs: { // [!code ++]
            type: "module", // [!code ++]
            src: `https://unpkg.com/@getcanary/web@latest/components/${c}.js`, // [!code ++]
          }, // [!code ++]
        })), // [!code ++]
      ], // [!code ++]
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
