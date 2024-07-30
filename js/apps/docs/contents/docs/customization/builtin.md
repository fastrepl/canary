# Built-in Components

::: tip
This page is a work in progress.
Please refer to our `Storybook` for the latest examples.

![storybook](https://raw.githubusercontent.com/storybooks/brand/master/badge/badge-storybook.svg)
:::

`Canary`'s main focus is to provide composable primitives, so you can build your own UI for any use-case.
If there's something missing, please [open an issue](https://github.com/fastrepl/canary/issues/new).

## `canary-root`

Outermost wrapper component. Required for all other components.

```html
<canary-root framework="vitepress">
  <!-- Rest of the code -->
</canary-root>
```

`docusaurus`, `vitepress`, and `starlight` are supported.

## `canary-provider-*`

Register `operation` to `canary-root`.

- `canary-provider-mock`
- `canary-provider-pagefind`
- `canary-provider-vitepress-minisearch`
- `canary-provider-cloud`

## `canary-modal`, `canary-trigger-*`, `canary-content`

For most cases, you'll want the panel to be shown when user clicks on the search bar or button.

```html
<canary-modal>
  <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
  <canary-content slot="content">
    <!-- search & ask components -->
  </canary-content>
</canary-modal>
```

But if you don't want modal, just can just use the `canary-content` component directly.

## `canary-search`, `canary-search-input`, `canary-search-results-*`

- `canary-search-results` is the default, but you can replace it with `canary-search-results-tabs`.
- For both `canary-search-results` and `canary-search-results-tabs`, you can use `group` attribute to group search results.

## `canary-ask`, `canary-ask-input`, `canary-ask-results`

## `canary-callout-*`

## `canary-footer`

## `canary-mode-tabs`

Note that if you use only one of `search` or `ask`, mode switching will be disabled.

If nothing is provided in `mode-tabs` slot for `canary-search` or `canary-ask`, [`canary-mode-tabs`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/canary-ask.ts) will be used as a fallback.
