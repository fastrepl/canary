# Not everyone needs a hosted service.

You can just use keyword-based search locally, and **still benefit from our composable components.**

| Feature  |            Local            |           Cloud            |
| -------- | :-------------------------: | :------------------------: |
| `Search` | `Only Keyword-based Search` | `AI Powered Hybrid Search` |
| `Ask AI` |             `X`             |            `O`             |

::: tip
Wanna try it out? We made a [playground](/docs/local/playground) for you!
:::

## Any documentation & Any search index

Our UI components are decoupled from the actual operation layer.

We currently support:

- Any `Pagefind` based search using `canary-provider-pagefind`
- `VitePress` with `Minisearch` using `canary-provider-vitepress-minisearch`

## Migrate to cloud provider

If you need more features, you can easily migrate.

```html-vue
<canary-root framework="docusaurus">
  <canary-provider-pagefind> // [!code --]
  <canary-provider-cloud api-key="KEY" api-base="https://cloud.getcanary.dev"> // [!code ++]
    <!-- Rest of the code -->
  </canary-provider-cloud> // [!code ++]
  </canary-provider-pagefind> // [!code --]
</canary-root>
```
