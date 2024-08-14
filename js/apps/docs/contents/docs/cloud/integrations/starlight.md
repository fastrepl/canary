# Starlight

::: warning
`Canary Cloud` is in active development. Not ready for production use yet.
:::

```html-vue
<canary-root framework="starlight">
  <canary-provider-pagefind> // [!code --]
    <canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev"> // [!code ++]
      <!-- Rest of the code -->
    </canary-provider-cloud> // [!code ++]
  </canary-provider-pagefind> // [!code --]
</canary-root>
```

Disable `pagefind` in `astro.config.mjs`
https://starlight.astro.build/reference/configuration/#pagefind
