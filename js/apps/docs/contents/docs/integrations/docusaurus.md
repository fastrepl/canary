<script setup>
import { data } from '../../../shared.data.js'
const v = data["@getcanary/web"];
</script>

# Docusaurus

[Docusaurus](https://docusaurus.io/) is static site generator using React.

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
// docusaurus.config.js
/** @type {import('@docusaurus/types').Config} */
const config = {
  ...
  scripts: [ // [!code ++]
    "canary-provider-cloud", // [!code ++]
    // add more components here // [!code ++]
  ].map((c) => ({ // [!code ++]
    type: "module", // [!code ++]
    src: `https://unpkg.com/@getcanary/web@{{ v }}/components/${c}.js`, // [!code ++]
  })), // [!code ++]
  ...
};
```

## Configuration

### Step 1: Eject existing SearchBar

You should [eject](https://docusaurus.io/docs/swizzling#ejecting) existing SearchBar component first.

```bash
npm run swizzle @docusaurus/theme-classic SearchBar -- --eject --javascript
```

### Step 2: Modify ejected component

```js
// src/theme/SearchBar.js
import "@getcanary/web/components/canary-provider-cloud";
// You can skip imports if you are using CDN.

export default function SearchBar() {
  return (
    <canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev">
      {/* ... */}
    </canary-provider-cloud>
  );
}
```
