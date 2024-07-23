# Styling

## Default Styles

For most cases, [`canary-styles-default`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/canary-styles-default.ts) will be enough.

### Light/Dark Mode

```html{1}
<canary-styles-default framework="vitepress">
    <!-- Rest of the code -->
</canary-styles-default>
```

Each documentation framework has its own way to add theme information to the dom. By providing `framework` attribute, `canary-styles-default` will handle the theme for you.

### CSS Variables

All components in Canary renders inside a [shadow DOM](https://developer.mozilla.org/en/docs/Web/API/Web_components/Using_shadow_DOM). So CSS in your documentation website will not affect the styling of Canary components by default.

[CSS variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) is one exception. And Canary exposes them for you to use.

```html{3,4}
--canary-font-family-base
--canary-font-family-mono
--canary-color-primary-c
--canary-color-primary-h
--canary-color-gray-c
--canary-color-gray-h
```
