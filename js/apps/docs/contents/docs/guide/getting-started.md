<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Getting Started

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

This is typical usage of our components. For more details, please check out [Built-in Components](/docs/customization/builtin) page of the docs.

```html
<canary-styles-default framework="vitepress">
  <canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev">
    <canary-modal>
      <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
      <canary-content slot="content">
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
        <canary-ask slot="ask">
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-ask-results slot="results"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </canary-modal>
  </canary-provider-cloud>
</canary-styles-default>
```

You can setup hosted search index and get `KEY` from [cloud.getcanary.dev](https://cloud.getcanary.dev) for free.
