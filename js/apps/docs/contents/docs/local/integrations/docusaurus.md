# Docusaurus

<!--@include: ./callout.md-->

[Docusaurus](https://docusaurus.io/) is static site generator using React.

Since `Docusaurus` do not have default search index, we provide `@getcanary/docusaurus-theme-search-pagefind` to generate [Pagefind](https://pagefind.app/) index at build time.

::: details Why use Pagefind?
Main problem of local search index is that the **size of the index grows** as you add more content, and users must **load the whole index upfront** to do the search.

`Pagefind` solved this problem by splitting the index into multiple fragments and load fragments on demand. Also note that `docusaurus-lunr-search`, which is quite popular, uses [`lunr.js`](https://github.com/olivernn/lunr.js) that hasn't been updated for the last 4 years.
:::

## One step to integrate

```bash
npm install @getcanary/web
npm install @getcanary/docusaurus-theme-search-pagefind
```

::: code-group

```js [docusaurus.config.js]
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  themes: [
    // Remove any existing plugins or themes that are related to search // [!code ++]
    require.resolve("@getcanary/docusaurus-theme-search-pagefind"), // [!code ++]
  ],
};
```

:::

::: tip
According to [Docusaurus docs](https://docusaurus.io/docs/using-plugins#using-themes),

> ...the themes and plugins entries are interchangeable when installing and configuring a plugin.

:::

## Configuration

### Basic

You can change colors and pagefind ranking by adding the following configuration. All options are optional.

::: code-group

```js [docusaurus.config.js]
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  themes: [
    [
      require.resolve("@getcanary/docusaurus-theme-search-pagefind"),
      { // [!code ++]
        // https://getcanary.dev/docs/common/customization/styling#css-variables // [!code ++]
        styles: { // [!code ++]
          "--canary-color-primary-c": 0.1, // [!code ++]
          "--canary-color-primary-h": 270, // [!code ++]
        }, // [!code ++]
        // https://pagefind.app/docs/ranking // [!code ++]
        pagefind: { // [!code ++]
          ranking: { // [!code ++]
            pageLength: 0.9, // [!code ++]
            termFrequency: 1.0, // [!code ++]
            termSimilarity: 1.0, // [!code ++]
            termSaturation: 1.5, // [!code ++]
          } // [!code ++]
        } // [!code ++]
        indexOnly: false, // [!code ++]
        includeRoutes: ["**/*"], // [!code ++]
        excludeRoutes: ['/api/**'], // [!code ++]
        // https://getcanary.dev/docs/local/demo // [!code ++]
        // https://getcanary.dev/docs/common/guides/filtering // [!code ++]
        // e.g. [{"name":"All","pattern":"**/*"}] // [!code ++]
        tabs: [], // [!code ++]
      },
    ],
  ],
};
```

:::

### Advanced

[source](https://github.com/fastrepl/canary/blob/main/js/packages/docusaurus-theme-search-pagefind/src/index.js)

When you add `@getcanary/docusaurus-theme-search-pagefind` to the `themes` list, it will override the default search component to use Canary's. To customize this search-bar further, you can [eject](https://docusaurus.io/docs/swizzling#ejecting) it and modify the code.

```bash
npm run swizzle @getcanary/docusaurus-theme-search-pagefind SearchBar -- --eject
```

::: code-group

```js{4} [src/theme/SearchBar.js]
export default function SearchBar() {
  ...
  return (
    <canary-root framework="docusaurus">
      {/* ... */}
    </canary-root>
  );
}
```

:::

> Specifying `framework="docusaurus"` is required to detect light/dark mode changes.

Note that since `Canary`'s **main focus is to provide composable primitives**, ejected components will be very simple and easy to customize.
