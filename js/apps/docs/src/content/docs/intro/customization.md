---
title: Customization
---

`Canary`'s main focus is to provide composable primitives, so you can build your own UI for any use-case.
If there's something missing, please [open an issue](https://github.com/fastrepl/canary/issues/new).

This is typical usage of our components.

```html
<canary-styles-default theme="light">
  <canary-provider-mock>
    <canary-modal>
      <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>

      <canary-content slot="content">
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>

        <canary-ask slot="ask">
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-ask-results slot="results"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </canary-modal>
  </canary-provider-mock>
</canary-styles-default>
```

## Layout

### Modal

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

### Mode tabs

Note that if you use only one of `search` or `ask`, mode switching will be disabled.

If nothing is provided in `mode-tabs` slot for `canary-search` or `canary-ask`, [`canary-mode-tabs`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/canary-ask.ts) will be used as a fallback.

## Styles

All components in Canary renders inside a [shadow DOM](https://developer.mozilla.org/en/docs/Web/API/Web_components/Using_shadow_DOM). So CSS in your documentation website will not affect the styling of Canary components by default.

[CSS variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) is one exception. And Canary exposes them for you to use.

```css
--canary-font-family
--canary-color-white
--canary-color-gray-1
--canary-color-gray-2
--canary-color-gray-3
--canary-color-gray-4
--canary-color-gray-5
--canary-color-gray-6
--canary-color-black
--canary-color-accent
--canary-color-accent-low
--canary-color-accent-high
```

To get up and running quickly, you can use `canary-styles-default`.

```html
<canary-styles-default theme="light">
  <!-- or dark -->
  <!-- Rest of the code -->
</canary-styles-default>
```

If you already configured your theme with documentation framework, you can use our helper components that reads the theme and convert it to CSS variables. Currently we have `canary-styles-starlight` and `canary-styles-docusaurus`.
