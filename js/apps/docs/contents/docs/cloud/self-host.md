# Self-host

<br/>

<a href="https://railway.app/template/UAbYX1?referralCode=IQ76H8" target="_blank">
<img src="https://railway.app/button.svg" alt="railway.app">
</a>

We have `Railway` template for self-hosting. which consists of `Canary Core`, `PostgreSQL`, and `Typesense`.

The only code change needed is to set `api-base` to your self-hosted server.

<!-- prettier-ignore -->
```html
<canary-provider-cloud project-key=""> // [!code --]
<canary-provider-cloud project-key="" api-base=<SELF_HOSTED_SERVER_URL>> // [!code ++]
  <!-- Rest of the code -->
</canary-provider-cloud>
```

## Troubleshooting

::: tip

Join our [Discord](https://discord.gg/Y8bJkzuQZU) if you have any questions.

:::
