# VitePress

## Three steps to integrate

### Step 1: Install `@getcanary/web`

```bash
npm install @getcanary/web
```

### Step 2: Create search component

Take a look at our [CloudSearch.vue](https://github.com/fastrepl/canary/blob/main/js/apps/docs/components/CloudSearch.vue) implementation as an example.

```html-vue
<canary-root framework="vitepress">
  <canary-provider-vitepress-minisearch> // [!code --]
    <canary-provider-cloud project-key="KEY" api-base="https://cloud.getcanary.dev"> // [!code ++]
      <!-- Rest of the code -->
    </canary-provider-cloud> // [!code ++]
  </canary-provider-vitepress-minisearch> // [!code --]
</canary-root>
```

### Step 3: Modify the Layout

::: code-group

```js [.vitepress/theme/index.js]
import { h } from 'vue' // [!code ++]
import Search from "<YOUR_COMPONENT_PATH>.vue" // [!code ++]

/** @type {import('vitepress').Theme} */
export default {
  ...
  Layout() { // [!code ++]
    return h(DefaultTheme.Layout, null, { // [!code ++]
      'nav-bar-content-before': () => h(Search) // [!code ++]
    }) // [!code ++]
  } // [!code ++]
  ...
};
```

:::
