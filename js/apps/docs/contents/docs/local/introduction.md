# Canary Local

Not everyone needs a hosted service. You can just use keyword-based search locally, and **still benefit from our composable components.**

## Migrate from local to cloud

If you need more features, you can easily migrate.

```html-vue
<canary-root framework="docusaurus">
  <canary-provider-pagefind> // [!code --]
  <canary-provider-cloud key="KEY" endpoint="https://cloud.getcanary.dev"> // [!code ++]
    <!-- Rest of the code -->
  </canary-provider-cloud> // [!code ++]
  </canary-provider-pagefind> // [!code --]
</canary-root>
```
