<h1 align="center">
  🐤 Canary
</h1>

<div align="center">
  <h4>
    Search & Ask AI across your <code>docs(webpage)</code>, <code>GitHub issues</code>, and <code>discussions</code>.
  </h4>
  (<code>OpenAPI</code>, <code>changelog</code>, etc. are coming soon.)
</div>

<br />

> Currently, 🐤 provides two things:

<div align="center">
  <h3>1. Self-hostable core server.</h3>
  <p></p>
  <div><em>Auth, fetching / indexing documents, handling queries, etc</em></div>
  <p></p>
</div>

<div align="center">
  <a href="https://railway.app/template/UAbYX1?referralCode=IQ76H8" target="_blank">
    <img src="https://railway.app/button.svg" alt="railway.app">
  </a>
</div>

<br />

<div align="center">

| <img width="800px" src="https://github.com/user-attachments/assets/29f6b777-4a88-4f71-95ef-d4c43ca729a2"></img> | <img width="800px" src="https://github.com/user-attachments/assets/e1dde42f-2643-4982-9014-b003313acc7a"></img> |
| --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| <div align="center"><code>Fetcher Status</code></div>                                                           | <div align="center"><code>Crawler Status</code></div>                                                           |

</div>

<br />

<div align="center">
  <h3>2. Tiny web components for building a search bar.</h3>
  <p></p>
  <div><em>Glob / tag filters, light / dark mode, multiple panels for Search / Ask AI, and more!</em></div>
  <p></p>
</div>

<h4 align="center">
  <a href="https://storybook.getcanary.dev" target="_blank">
    <img src="https://raw.githubusercontent.com/storybooks/brand/master/badge/badge-storybook.svg" alt="Storybook">
  </a>
  <a href="https://app.argos-ci.com/yujonglee" target="_blank">
    <img src="https://argos-ci.com/badge.svg" alt="Argos">
  </a>
<a href="https://app.fossa.com/projects/git%2Bgithub.com%2Ffastrepl%2Fcanary?ref=badge_shield" alt="FOSSA Status"><img src="https://app.fossa.com/api/projects/git%2Bgithub.com%2Ffastrepl%2Fcanary.svg?type=shield"/></a>
  <a href="https://stackblitz.com/edit/canary?file=index.html" target="_blank">
    <img src="https://developer.stackblitz.com/img/open_in_stackblitz_small.svg" alt="Stackblitz">
  </a>
  <a href="https://getcanary.dev/docs/why.html#tiny-components-that-works-anywhere" target="_blank">
    <img src="https://img.shields.io/badge/size_comparison-black?labelColor=black" alt="Chart">
  </a>
  <a href="https://discord.gg/Y8bJkzuQZU" target="_blank">
    <img src="https://img.shields.io/static/v1?label=Join%20our&message=Discord&color=blue&logo=Discord&style=flat" alt="Discord">
  </a>
</h4>

<div align="center">

| <img width="800px" src="https://github.com/user-attachments/assets/3515b768-d451-4f93-a102-f64138b887d9"></img> | <img width="800px" src="https://github.com/user-attachments/assets/75b258c9-a1e5-4255-8e7e-d80f54c95c56"></img> |
| --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| <div align="center"><code>Search</code></div>                                                                   | <div align="center"><code>Ask AI</code></div>                                                                   |

</div>

<br/>

> code example:

```html
<canary-root framework="vitepress">
  <canary-provider-cloud project-key="">
    <canary-modal>
      <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
      <canary-content slot="content">
        <canary-input slot="input" autofocus></canary-input>
        <canary-search slot="mode">
          <canary-search-results slot="body"></canary-search-results>
        </canary-search>
        <canary-ask slot="mode">
          <canary-ask-results slot="body"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </canary-modal>
  </canary-provider-cloud>
</canary-root>
```

<br />

# Get started

We have documentation available at [getcanary.dev](https://getcanary.dev).


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Ffastrepl%2Fcanary.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Ffastrepl%2Fcanary?ref=badge_large)