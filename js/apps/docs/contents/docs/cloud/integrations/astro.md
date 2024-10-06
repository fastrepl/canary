# Astro

[Astro](https://astro.build) is web framework for content-driven websites.

## Two steps to integrate

### Step 1: Install `@getcanary/web`

```bash
npm install @getcanary/web
```

### Step 2: Create search component

You can customize and place it anywhere you want.

```html{12}
<script>
import '@getcanary/web/components/canary-root.js'
import '@getcanary/web/components/canary-provider-pagefind.js'
import '@getcanary/web/components/canary-modal.js'
import '@getcanary/web/components/canary-trigger-searchbar.js'
import '@getcanary/web/components/canary-content.js'
import '@getcanary/web/components/canary-input.js'
import '@getcanary/web/components/canary-search.js'
import '@getcanary/web/components/canary-search-results.js'
</script>

<canary-root framework="astro">
    <canary-provider-pagefind>
    <canary-modal>
        <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
        <canary-content slot="content">
            <canary-input slot="input"></canary-input>
            <canary-search slot="mode">
                <canary-search-results slot="body"></canary-search-results>
            </canary-search>
        </canary-content>
    </canary-modal>
    </canary-provider-pagefind>
</canary-root>
```
