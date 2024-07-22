<script setup>
import { data } from '../../../shared.data.js'

const v = data["@getcanary/web"];

const cloud = `https://unpkg.com/@getcanary/web@${v}/components/canary-provider-cloud.js`;
const pagefind = `https://unpkg.com/@getcanary/web@${v}/components/canary-provider-pagefind.js`;
const mock = `https://unpkg.com/@getcanary/web@${v}/components/canary-provider-mock.js`;
</script>

# Provider

## `canary-provider-cloud`

```html-vue
<script type="module" src={{ cloud }}></script>
```

## `canary-provider-pagefind`

```html-vue
<script type="module" src={{ pagefind }}></script>
```

## `canary-provider-mock`

```html-vue
<script type="module" src={{ mock }}></script>
```
