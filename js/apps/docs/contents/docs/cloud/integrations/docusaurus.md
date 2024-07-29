# Docusaurus

::: warning
`Canary Cloud` is in active development. Not ready for production use yet.
:::

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
