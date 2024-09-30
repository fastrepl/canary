# Using Canary with local search index

If you're working on a small side project or documentation, a local search index like `Pagefind` may suffice. You can run keyword-based searches locally and **still benefit from our composable components.**

| Feature  |            Local            |           Cloud            |
| -------- | :-------------------------: | :------------------------: |
| `Search` | `Only Keyword-based Search` | `AI Powered Hybrid Search` |
| `Ask AI` |             `X`             |            `O`             |

::: tip
Wanna try it out? We made a [demo](/docs/local/demo) for you!
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
