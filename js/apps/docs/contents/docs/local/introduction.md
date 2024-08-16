# Not everyone needs a hosted service.

You can just use keyword-based search locally, and **still benefit from our composable components.**

| Feature  |            Local            |           Cloud            |
| -------- | :-------------------------: | :------------------------: |
| `Search` | `Only Keyword-based Search` | `AI Powered Hybrid Search` |
| `Ask AI` |             `X`             |            `O`             |

## Any documentation & Any search index

Our UI components are decoupled from the actual operation layer.

We currently support:

- Any `Pagefind` based search using `canary-provider-pagefind`
- `VitePress` with `Minisearch` using `canary-provider-vitepress-minisearch`

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
