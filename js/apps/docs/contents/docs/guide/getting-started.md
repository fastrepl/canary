<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Getting Started

## Copy Public Key (Optional)

> If you are not using `canary-provider-cloud`, you can skip this step.

You can get your public key from our hosted service at [cloud.getcanary.dev](https://cloud.getcanary.dev).

## Installation

> Please check out `integrations` section of the docs for details.

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

## Usage

> Please check out [Built-in Components](/docs/customization/builtin) section of the docs for details.

```html
<canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev">
  <!-- Rest of the code -->
</canary-provider-cloud>
```
