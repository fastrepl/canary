# Feedback

## Per Page

### Vitepress

#### Create Component

```vue{19-22}
<script setup lang="ts">
import { onMounted, ref } from "vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-styles.js"),
    import("@getcanary/web/components/canary-feedback-page.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

<template>
  <div class="flex justify-center items-center" v-if="loaded">
    <canary-styles framework="vitepress">
      <canary-feedback-page
        api-base="https://cloud.getcanary.dev"
        api-key="pk_xxxxxxxxxxxxx"
      ></canary-feedback-page>
    </canary-styles>
  </div>
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
