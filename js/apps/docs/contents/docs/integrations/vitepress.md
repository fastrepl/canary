<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# VitePress

[VitePress](https://vitepress.dev/) is Vite & Vue Powered Static Site Generator.

## Installation

### NPM

```bash
npm install @getcanary/web
```

```js
import "@getcanary/web/components/<NAME>";
```

### CDN

```html-vue
<script type="module" src="https://unpkg.com/@getcanary/web@{{ v }}/components/<NAME>">
```

```js-vue
// vitepress/config.mts
export default defineConfig({
  ...
  head: [ // [!code ++]
    "canary-styles-default", // [!code ++]
    // add more components here // [!code ++]
  ].map((tag) => [ // [!code ++]
    "script", // [!code ++]
    { // [!code ++]
      type: "module", // [!code ++]
      src: `https://unpkg.com/@getcanary/web@{{ v }}/components/${tag}.js`, // [!code ++]
    }, // [!code ++]
  ]), // [!code ++]
  ...
});
```

## Configuration

### Extending the Default Theme

You should modify the default [Layout](https://vitepress.dev/guide/extending-default-theme#layout-slots).

#### Step 1: Add a Search Component

```html-vue{14}
<!-- <YOUR_COMPONENT_PATH>.vue -->
<script setup lang="ts">
  import { onMounted } from "vue";

  // You can skip imports if you are using CDN.
  onMounted(async () => {
    import("@getcanary/web/components/canary-styles-default");
    // add more components here
  });
</script>

<template>
  <canary-styles-default framework="vitepress">
    <!-- Rest of the code -->
  </canary-styles-default>
</template>
```

Specifying `framework="vitepress"` is required to detect light/dark mode changes.

> At this point, default styles are applied. For customization, please refer to [Styling](/docs/customization/styling) guide.

#### Step 2: Modify the Layout

```js
// .vitepress/theme/index.js
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

### Using a Custom Theme

If you are using [Custom Theme](https://vitepress.dev/guide/custom-theme), you'll already know what to do.
