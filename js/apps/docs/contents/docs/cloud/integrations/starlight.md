# Starlight

Everything is the same as [local search with Starlight](/docs/local/integrations/starlight), execpt for two things:

1. Disable `pagefind` in `astro.config.mjs`

::: code-group

```js [astro.config.mjs]
// https://starlight.astro.build/reference/configuration/#pagefind
export default defineConfig({
  integrations: [
    starlight({
      ...
      pagefind: false // [!code ++]
      ...
    }),
  ],
});
```

:::

2. Swap `canary-provider-pagefind` with `canary-provider-cloud`

::: code-group

```html-vue [YOUR_COMPONENT.astro]
...
<canary-root framework="starlight">
  <canary-provider-pagefind> // [!code --]
    <canary-provider-cloud api-key="KEY" api-base="https://cloud.getcanary.dev"> // [!code ++]
      <!-- Rest of the code -->
    </canary-provider-cloud> // [!code ++]
  </canary-provider-pagefind> // [!code --]
</canary-root>
...
```

:::
