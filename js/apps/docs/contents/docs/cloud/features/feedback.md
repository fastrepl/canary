# Feedback

## Per Page

### Vitepress

#### Create Component

```html-vue
<template>
</template>
```

#### Modify Layout

::: code-group

```js [.vitepress/theme/index.js]
import { h } from 'vue' // [!code ++]
import Footer from "<YOUR_COMPONENT_PATH>.vue" // [!code ++]

/** @type {import('vitepress').Theme} */
export default {
  ...
  Layout() { // [!code ++]
    return h(DefaultTheme.Layout, null, { // [!code ++]
        "doc-footer-before": () => h(Footer), // [!code ++]
    }) // [!code ++]
  } // [!code ++]
  ...
};
```

:::
