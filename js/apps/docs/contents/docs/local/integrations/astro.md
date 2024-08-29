# Astro

<!--@include: ./callout.md-->

[Astro](https://astro.build) is web framework for content-driven websites.

## Two steps to integrate

### Step 1: Configure Pagefind indes

```bash
npm install astro-pagefind
```

::: code-group

```js [astro.config.mjs]
import { defineConfig } from "astro/config";
import pagefind from "astro-pagefind";

export default defineConfig({
  ...
  integrations: [pagefind()],
  ...
});
```

:::

### Step 2: Create search component

You can customize and place it anywhere you want.

```html{1}
<canary-root framework="astro">
    <canary-provider-pagefind>
    <canary-modal>
        <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
        <canary-content slot="content">
            <canary-search slot="mode">
                <canary-search-input slot="input"></canary-search-input>
                <canary-search-results slot="body"></canary-search-results>
            </canary-search>
        </canary-content>
    </canary-modal>
    </canary-provider-pagefind>
</canary-root>
```
