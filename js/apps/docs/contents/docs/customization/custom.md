# Custom Components

All [built-in components](https://github.com/fastrepl/canary/tree/main/js/packages/web/src) in Canary are [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) written with [Lit](https://lit.dev/). Since it is very closed to the standard, it should be easy to build your own components.

## Controllers and Contexts

We have [controllers](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/controllers.ts) that are reused across components, and [contexts](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/contexts.ts) that are used to share data from parent to child components.

### Using Controllers

Information can be found in Lit's [docs](https://lit.dev/docs/composition/controllers/).

### Using Contexts

Information can be found in Lit's [docs](https://lit.dev/docs/composition/context/).
