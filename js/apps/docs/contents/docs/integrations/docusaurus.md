<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Docusaurus

::: tip
If you're using `Canary Cloud`, please refer to [this page](/docs/cloud/integrations/docusaurus) instead.
:::

[Docusaurus](https://docusaurus.io/) is static site generator using React.

Since `Docusaurus` do not have default search index, we provide `@getcanary/docusaurus-pagefind` to generate [Pagefind](https://pagefind.app/) index at build time.

::: details Why use Pagefind?
Main problem of local search index is that the **size of the index grows** as you add more content, and users must **load the whole index upfront** to do the search.

`Pagefind` solved this problem by splitting the index into multiple fragments and load fragments on demand. Also note that `docusaurus-lunr-search`, which is quite popular, uses [`lunr.js`](https://github.com/olivernn/lunr.js) that hasn't been updated for the last 4 years.
:::

## One step to integrate

```bash
npm install @getcanary/web
npm install @getcanary/docusaurus-pagefind
```

::: code-group

```js [docusaurus.config.js]
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  plugins: [
    // Remove any existing search plugin // [!code --]
    require.resolve('docusaurus-lunr-search'), // [!code --]
    require.resolve("@getcanary/docusaurus-pagefind"), // [!code ++]
  ],
};
```

:::

::: warning
You should run `docusaurus build && docusaurus serve` to try the search locally.

It won't work with `docusaurus start`.
:::

## Configuration

### Basic

You can change colors and pagefind ranking by adding the following configuration.

::: code-group

```js [docusaurus.config.js]
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  plugins: [
    [
      require.resolve("@getcanary/docusaurus-pagefind"),
      { // [!code ++]
        // https://getcanary.dev/docs/customization/styling.html#css-variables // [!code ++]
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
        includeRoutes: ["**/*"], // [!code ++]
        excludeRoutes: ['/api*', '/api/*'], // [!code ++]
      },
    ],
  ],
};
```

:::

### Advanced

When you add `@getcanary/docusaurus-pagefind` to the `plugins` list, it will override the default search component to use Canary's. To customize this search-bar further, you can [eject](https://docusaurus.io/docs/swizzling#ejecting) it and modify the code.

```bash
npm run swizzle @getcanary/docusaurus-pagefind SearchBar -- --eject --javascript
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

For information on how to compose components to build your own search-bar UI, please refer to the [Built-in Components](/docs/customization/builtin) and [Custom Components](/docs/customization/custom) guides.
