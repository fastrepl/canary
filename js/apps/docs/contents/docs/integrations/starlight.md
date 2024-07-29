<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Starlight

::: tip
If you're using `Canary Cloud`, please refer to [this page](/docs/cloud/integrations/starlight) instead.
:::

[Starlight](https://starlight.astro.build/) is a template built on top of Astro for building documentation.

Since `Starlight` already have built-in integration with `Pagefind`, so you can just leverage the existing index with `canary-provider-pagefind`.

## Three steps to integrate

### Step 1: Install `@getcanary/web`

```bash
npm install @getcanary/web
```

### Step 2: Create search component

::: code-group

```astro{28} [YOUR_COMPONENT.astro]
---
const options = {
  path: `${import.meta.env.BASE_URL}pagefind/pagefind.js`,
  // https://pagefind.app/docs/ranking
  // Optional, default values are:
  pagefind: {
    ranking: {
      pageLength: 0.75,
      termFrequency: 1.0,
      termSimilarity: 1.0,
      termSaturation: 1.4,
    },
  },
};
---

<script>
  import "@getcanary/web/components/canary-root";
  import "@getcanary/web/components/canary-provider-pagefind";
  import "@getcanary/web/components/canary-trigger-searchbar";
  import "@getcanary/web/components/canary-modal";
  import "@getcanary/web/components/canary-content";
  import "@getcanary/web/components/canary-search";
  import "@getcanary/web/components/canary-search-input";
  import "@getcanary/web/components/canary-search-results";
</script>

<canary-root framework="starlight">
  <canary-provider-pagefind options={JSON.stringify(options)}>
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
</canary-root>

<!-- https://getcanary.dev/docs/customization/styling.html#css-variables -->
<style>
  canary-root {
    --canary-color-primary-c: 0.1;
    --canary-color-primary-h: 170;
  }
</style>
```

:::

> Specifying `framework="starlight"` is required to detect light/dark mode changes.

For more information on how to compose components to build your own search-bar UI, please refer to the [Built-in Components](/docs/customization/builtin) and [Custom Components](/docs/customization/custom) guides.

### Step 3: Override default search component

::: code-group

```js [astro.config.mjs]
// https://starlight.astro.build/guides/overriding-components/#how-to-override
export default defineConfig({
  integrations: [
    starlight({
      components: { Search: "<PATH_TO_YOUR_COMPONENT>.astro" }, // [!code ++]
    }),
  ],
});
```

:::

::: warning
You should run `astro build && astro preview` to try the search locally.

It won't work with `astro dev`.
:::
