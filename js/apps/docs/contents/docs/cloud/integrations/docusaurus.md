# Docusaurus

::: warning
`Canary Cloud` is in active development. Not ready for production use yet.
:::

## Installation

::: tip
If you were using `@getcanary/docusaurus-theme-search-pagefind` before, please remove it.
:::

```bash
npm install @getcanary/web
```

## Configuration

```bash
npm run swizzle @docusaurus/theme-classic SearchBar -- --eject --javascript
```

```html-vue
<canary-root framework="docusaurus">
  <canary-provider-pagefind> // [!code --]
    <canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev"> // [!code ++]
      <!-- Rest of the code -->
    </canary-provider-cloud> // [!code ++]
  </canary-provider-pagefind> // [!code --]
</canary-root>
```
