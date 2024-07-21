# Styles

<script setup>
import { data } from '../../../shared.data.js'

const v = data["@getcanary/web"];

const default_ = `https://unpkg.com/@getcanary/web@${v}/components/canary-styles-default.js`;
const starlight = `https://unpkg.com/@getcanary/web@${v}/components/canary-styles-starlight.js`;
const docusaurus = `https://unpkg.com/@getcanary/web@${v}/components/canary-styles-docusaurus.js`;
</script>

## `canary-styles-default`

```html-vue
<script type="module" src={{ default_ }}></script>
```

## `canary-styles-starlight`

```html-vue
<script type="module" src={{ starlight }}></script>
```

## `canary-styles-docusaurus`

```html-vue
<script type="module" src={{ docusaurus }}></script>
```
