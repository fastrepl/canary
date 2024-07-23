# Built-in Components

`Canary`'s main focus is to provide composable primitives, so you can build your own UI for any use-case.
If there's something missing, please [open an issue](https://github.com/fastrepl/canary/issues/new).

## Providers

## Modal

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

## Mode tabs

Note that if you use only one of `search` or `ask`, mode switching will be disabled.

If nothing is provided in `mode-tabs` slot for `canary-search` or `canary-ask`, [`canary-mode-tabs`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/canary-ask.ts) will be used as a fallback.

## Styles

Refer to [Styling](/docs/customization/styling) page of the docs.
