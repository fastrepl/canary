<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Starlight

[Starlight](https://starlight.astro.build/) is a template built on top of Astro for building documentation.

## Installation

### NPM

```bash
npm install @getcanary/web
```

```js
import "@getcanary/web/components/<NAME>";
```

### CDN

```js-vue
// astro.config.mjs
export default defineConfig({
  integrations: [
    starlight({
      head: [ // [!code ++]
        ...[ // [!code ++]
          "canary-provider-cloud", // [!code ++]
          // add more components here // [!code ++]
        ].map((c) => ({ // [!code ++]
          tag: "script", // [!code ++]
          attrs: { // [!code ++]
            type: "module", // [!code ++]
            src: `https://unpkg.com/@getcanary/web@{{ v }}/components/${c}.js`, // [!code ++]
          }, // [!code ++]
        })), // [!code ++]
      ], // [!code ++]
    }),
  ],
});
```

## Configuration

You can [override](https://starlight.astro.build/reference/overrides/#search) Starlight's default search component to use Canary's.

### Step 1: Define your own search component

```html
<!-- <YOUR_COMPONENT>.astro -->
<script>
  import "@getcanary/web/components/canary-provider-cloud";
  // You can skip imports if you are using CDN.
</script>

<canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev">
  <!-- Rest of the code -->
</canary-provider-cloud>
```

### Step 2: Override default search component

```js
// astro.config.mjs
export default defineConfig({
  integrations: [
    starlight({
      components: { Search: "<YOUR_COMPONENT>.astro" }, // [!code ++]
    }),
  ],
});
```
