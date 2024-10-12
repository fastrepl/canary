# @getcanary/web

## 1.0.8

### Patch Changes

- Fix pagefind index preloading.
- Send package version as metadata in cloud operations.
- Support opening search result URL in a new tab.
- Support "tags" metadata in `canary-provider-pagefind`.

## 1.0.7

### Patch Changes

- Add optional picomatch's options field in TabDefinition.

## 1.0.6

### Patch Changes

- Remove `sources` from `canary-provider-cloud`.

## 1.0.5

### Patch Changes

- Replace `api-key` with `project-key` in `canary-provider-cloud`.

## 1.0.4

### Patch Changes

- Replace Lit's customElement decorator with a custom one to avoid the 'Failed to execute "define" on "CustomElementRegistry"' error.

## 1.0.3

### Patch Changes

- Fix initial sources dispatch in `canary-provider-cloud`.

## 1.0.2

### Patch Changes

- Add a debounce for displaying the loading spinner in the canary-input.

## 1.0.1

### Patch Changes

- Fix bug in `canary-provider-cloud` that does not dispatch updated sources to the root store.
