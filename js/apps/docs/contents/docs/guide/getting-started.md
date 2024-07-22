<script setup>
import { data } from '../../../shared.data.js'

const v = data["@getcanary/web"];
const url = `https://unpkg.com/@getcanary/web@${v}/components/<NAME>.js`;
</script>

# Getting Started

## Copy Public Key

> If you are not using `canary-provider-cloud`, you can skip this step.

You can get your public key from our hosted service at [cloud.getcanary.dev](https://cloud.getcanary.dev).

## Installation

### NPM

```bash
npm install @getcanary/web
```

```js
import "@getcanary/web/components/<NAME>.js";
```

### CDN

```html-vue
<script type="module" src={{ url }}>
```

## Usage
