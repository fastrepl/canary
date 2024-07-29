<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# VitePress

::: tip
If you're using `Canary Cloud`, please refer to [this page](/docs/cloud/integrations/vitepress) instead.
:::

[VitePress](https://vitepress.dev/) is Vite & Vue powered static site generator.

`VitePress` uses [Minisearch](https://github.com/lucaong/minisearch/) as its default local search, and you can use `canary-provider-vitepress-minisearch` to leverage it.

## Three steps to integrate

### Step 1: Install `@getcanary/web`

```bash
npm install @getcanary/web
```

### Step 2: Create search component

Take a look at our [LocalSearch.vue](https://github.com/fastrepl/canary/blob/main/js/apps/docs/components/LocalSearch.vue) implementation as an example.

### Step 3: Replace default component with Canary's

::: code-group

```js [.vitepress/config.mts]
export default defineConfig({
  ...
  vite: {
    resolve: {
      alias: [
        { // [!code ++]
          find: /^.*\/VPNavBarSearch\.vue$/, // [!code ++]
          replacement: fileURLToPath( // [!code ++]
            new URL("<RELATIVE_PATH>.vue", import.meta.url), // [!code ++]
          ), // [!code ++]
        }, // [!code ++]
      ],
    },
  },
  themeConfig: {
    // Don't forget to enable local search // [!code ++]
    search: { provider: "local" } // [!code ++]
    ...
  },
  ...
});
```

:::
