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

| Provider                 | Keyword Search | Hybrid Search | Suggestion | Ask AI |
| ------------------------ | :------------: | :-----------: | :--------: | :----: |
| `-mock`                  |      `O`       |      `O`      |    `O`     |  `O`   |
| `-pagefind`              |      `O`       |      `X`      |    `X`     |  `X`   |
| `--vitepress-minisearch` |      `O`       |      `X`      |    `X`     |  `X`   |
| `-cloud`                 |      `O`       |      `O`      |    `O`     |  `O`   |

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

But if you don't want modal, you can just use the `canary-content` directly. `canary-dropdown` is planned, but not implemented yet.

## `canary-search` and `canary-ask`

Must be placed in `mode` slot of `canary-content`.

### `canary-search-input`, `canary-search-results-*`

Inside `canary-search`, these slots are available:

| Slot           | Possible Components                                                       |
| -------------- | :------------------------------------------------------------------------ |
| `input`        | `canary-search-input`                                                     |
| `input-before` | `canary-mode-breadcrumb`                                                  |
| `input-after`  | `canary-mode-tabs`                                                        |
| `body`         | `canary-callout-*` ,`canary-search-results`, `canary-search-results-tabs` |
| `empty`        | `canary-search-empty`                                                     |

### `canary-ask-input`, `canary-ask-results`

Inside `canary-ask`, these slots are available:

| Slot           | Possible Components      |
| -------------- | :----------------------- |
| `input`        | `canary-ask-input`       |
| `input-before` | `canary-mode-breadcrumb` |
| `input-after`  | `canary-mode-tabs`       |
| `body`         | `canary-ask-results`     |

#### Syntax Highlighting

```html{5}
<canary-ask slot="mode">
  <canary-ask-input slot="input"></canary-ask-input>
  <canary-ask-results
    slot="body"
    language="javascript,python,ruby"
  ></canary-ask-results>
</canary-ask>
```
