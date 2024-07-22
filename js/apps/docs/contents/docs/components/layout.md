<script setup>
import { data } from '../../../shared.data.js'

const v = data["@getcanary/web"];

const modal = `https://unpkg.com/@getcanary/web@${v}/components/canary-modal.js`;
const trigger = `https://unpkg.com/@getcanary/web@${v}/components/canary-trigger-searchbar.js`;
</script>

# Layout

## `canary-modal`

```html-vue
<script type="module" src={{ modal }}></script>
```

## `canary-trigger-searchbar`

```html-vue
<script type="module" src={{ trigger }}></script>
```
