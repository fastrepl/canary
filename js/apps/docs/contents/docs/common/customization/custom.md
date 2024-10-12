# Custom Components

## Writing a Custom Component

All [built-in components](https://github.com/fastrepl/canary/tree/main/js/packages/web/src/components) in Canary are [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) written with [Lit](https://lit.dev/).

We have [controllers](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/controllers.ts) that are reused across components, and [contexts](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/contexts.ts) that are used to share data from parent to child components.

### Using Controllers

Information can be found in Lit's [docs](https://lit.dev/docs/composition/controllers/).

### Using Contexts

Information can be found in Lit's [docs](https://lit.dev/docs/composition/context/).

## Using a Custom Component

You can use `slot` to insert your custom component.

```html
<canary-modal>
  <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar> // [!code
  --]
  <div slot="trigger">// [!code ++] <MyCustomComponent /> // [!code ++]</div>
  // [!code ++]
  <canary-content slot="content">
    <!-- Rest of the code -->
  </canary-content>
</canary-modal>
```

For real-world example of above case, take a look at [CloudSearch.vue](https://github.com/fastrepl/canary/blob/main/js/apps/docs/components/CloudSearch.vue).
