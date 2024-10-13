<script setup>
import { data as docusaurus } from "@data/version_docusaurus.data.js";

import jsdoc from "@getcanary/docusaurus-theme-search-pagefind/jsdoc.json";
const defs = jsdoc
    .filter(({ name }) => /^\p{Lu}/u.test(name))
    .sort((a, b) => {
        if (a.name === "Options") {return -1};
        if (b.name === "Options") {return 1};
        return a.name.localeCompare(b.name);
    });
</script>

# @getcanary/docusaurus-theme-search-pagefind

[npm (@{{ docusaurus.version }})](https://www.npmjs.com/package/@getcanary/docusaurus-theme-search-pagefind)

::: details Anything missing here?

This page is generated from `jsdoc` in [`packages/docusaurus-theme-search-pagefind`](https://github.com/fastrepl/canary/blob/main/js/packages/docusaurus-theme-search-pagefind/package.json#L20).

:::

::: code-group

```js [docusaurus.config.js]
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  themes: [
    [
      require.resolve("@getcanary/docusaurus-theme-search-pagefind"),
      options // [!code ++] // the "Options" type is defined in this page.
    ],
  ],
};
```

:::

<template v-for="def in defs">
    <h2 :id="def.name">{{ def.name }}</h2>
    <template v-for="property in def.properties">
        <h3 :id="property.name">{{ property.name }}</h3>
        <pre>{{ property.type.names[0] }}</pre>
        <p>{{ property.description }}</p>
    </template>
</template>
