defmodule Canary.Test.Scraper do
  use ExUnit.Case, async: true

  alias Canary.Scraper
  alias Canary.Scraper.Item

  describe "it works without crashing" do
    for {name, params} <- %{
          "getcanary.dev" => %{url: "https://getcanary.dev"},
          "nextjs.org" => %{url: "https://nextjs.org/docs"},
          "sentry.io" => %{url: "https://docs.sentry.io/product/sentry-basics"},
          "hono.dev" => %{url: "https://hono.dev"}
        } do
      @tag params: params
      test name, %{params: params} do
        html = Req.get!(params[:url]).body
        assert Scraper.run!(html) |> length() > 0
      end
    end
  end

  test "canary-1" do
    html = File.read!("test/fixtures/canary-1.html")

    assert Scraper.run!(html) == [
             %Item{
               content:
                 """
                 # Not everyone needs a hosted service.
                 You can just use keyword-based search locally, and still benefit from our composable components.
                 Feature,Local,Cloud
                 Search,Only Keyword-based Search,AI Powered Hybrid Search
                 Ask AI,X,OTIPWanna try it out? We made a [playground](/docs/local/playground.html) for you!
                 """
                 |> String.trim(),
               id: "not-everyone-needs-a-hosted-service",
               level: 1,
               title: "Not everyone needs a hosted service."
             },
             %Item{
               content:
                 """
                 ## Any documentation & Any search index
                 Our UI components are decoupled from the actual operation layer.We currently support:
                 - Any `Pagefind` based search using `canary-provider-pagefind`
                 - `VitePress` with `Minisearch` using `canary-provider-vitepress-minisearch`
                 """
                 |> String.trim(),
               id: "any-documentation-any-search-index",
               level: 2,
               title: "Any documentation & Any search index"
             },
             %Item{
               content:
                 """
                 ## Migrate to cloud provider
                 If you need more features, you can easily migrate.html<canary-root framework=\"docusaurus\">
                 -<canary-provider-pagefind>
                 +<canary-provider-cloud api-key=\"KEY\" api-base=\"https://cloud.getcanary.dev\">
                 <!-- Rest of the code -->
                 +</canary-provider-cloud>
                 -</canary-provider-pagefind>
                 </canary-root>
                 """
                 |> String.trim(),
               id: "migrate-to-cloud-provider",
               level: 2,
               title: "Migrate to cloud provider"
             }
           ]
  end

  test "hono-1" do
    html = File.read!("test/fixtures/hono-1.html")

    assert Scraper.run!(html) == [
             %Item{
               id: "bearer-auth-middleware",
               level: 1,
               title: "Bearer Auth Middleware",
               content:
                 "# Bearer Auth Middleware\nThe Bearer Auth Middleware provides authentication by verifying an API token in the Request header. The HTTP clients accessing the endpoint will add the `Authorization` header with `Bearer {token}` as the header value.Using `curl` from the terminal, it would look like this:shcurl -H 'Authorization: Bearer honoiscool' http://localhost:8787/auth/page"
             },
             %Item{
               id: "import",
               level: 2,
               title: "Import",
               content:
                 "## Import\ntsimport { Hono } from 'hono'\nimport { bearerAuth } from 'hono/bearer-auth'"
             },
             %Item{
               id: "usage",
               level: 2,
               title: "Usage",
               content:
                 "## Usage\ntsconst app = new Hono()\n\nconst token = 'honoiscool'\n\napp.use('/api/*', bearerAuth({ token }))\n\napp.get('/api/page', (c) => {\nreturn c.json({ message: 'You are authorized' })\n})To restrict to a specific route + method:tsconst app = new Hono()\n\nconst token = 'honoiscool'\n\napp.get('/api/page', (c) => {\nreturn c.json({ message: 'Read posts' })\n})\n\napp.post('/api/page', bearerAuth({ token }), (c) => {\nreturn c.json({ message: 'Created post!' }, 201)\n})To implement multiple tokens (E.g., any valid token can read but create/update/delete are restricted to a privileged token):tsconst app = new Hono()\n\nconst readToken = 'read'\nconst privilegedToken = 'read+write'\nconst privilegedMethods = ['POST', 'PUT', 'PATCH', 'DELETE']\n\napp.on('GET', '/api/page/*', async (c, next) => {\n// List of valid tokens\nconst bearer = bearerAuth({ token: [readToken, privilegedToken] })\nreturn bearer(c, next)\n})\napp.on(privilegedMethods, '/api/page/*', async (c, next) => {\n// Single valid privileged token\nconst bearer = bearerAuth({ token: privilegedToken })\nreturn bearer(c, next)\n})\n\n// Define handlers for GET, POST, etc.If you want to verify the value of the token yourself, specify the `verifyToken` option; returning `true` means it is accepted.tsconst app = new Hono()\n\napp.use(\n'/auth-verify-token/*',\nbearerAuth({\nverifyToken: async (token, c) => {\nreturn token === 'dynamic-token'\n},\n})\n)"
             },
             %Item{
               id: "options",
               level: 2,
               title: "Options",
               content: "## Options"
             },
             %Item{
               id: "token-string-string",
               level: 3,
               title: "required token: string | string[]",
               content:
                 "### required token: string | string[]\nThe string to validate the incoming bearer token against."
             },
             %Item{
               id: "realm-string",
               level: 3,
               title: "optional realm: string",
               content:
                 "### optional realm: string\nThe domain name of the realm, as part of the returned WWW-Authenticate challenge header. The default is `\"\"`. See more: [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate#directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate#directives)"
             },
             %Item{
               id: "prefix-string",
               level: 3,
               title: "optional prefix: string",
               content:
                 "### optional prefix: string\nThe prefix (or known as `schema`) for the Authorization header value. The default is `\"Bearer\"`."
             },
             %Item{
               id: "headername-string",
               level: 3,
               title: "optional headerName: string",
               content:
                 "### optional headerName: string\nThe header name. The default value is `Authorization`."
             },
             %Item{
               id: "hashfunction-function",
               level: 3,
               title: "optional hashFunction: Function",
               content:
                 "### optional hashFunction: Function\nA function to handle hashing for safe comparison of authentication tokens."
             },
             %Item{
               id: "verifytoken-token-string-c-context-boolean-promise-boolean",
               level: 3,
               title:
                 "optional verifyToken: (token: string, c: Context) => boolean | Promise<boolean>",
               content:
                 "### optional verifyToken: (token: string, c: Context) => boolean | Promise<boolean>\nThe function to verify the token."
             },
             %Item{
               id: "noauthenticationheadermessage-string-object-messagefunction",
               level: 3,
               title: "optional noAuthenticationHeaderMessage: string | object | MessageFunction",
               content:
                 "### optional noAuthenticationHeaderMessage: string | object | MessageFunction\n`MessageFunction` is `(c: Context) => string | object | Promise<string | object>`. The custom message if it does not have an authentication header."
             },
             %Item{
               id: "invalidauthenticationheadermessage-string-object-messagefunction",
               level: 3,
               title:
                 "optional invalidAuthenticationHeaderMessage: string | object | MessageFunction",
               content:
                 "### optional invalidAuthenticationHeaderMessage: string | object | MessageFunction\nThe custom message if the authentication header is invalid."
             },
             %Item{
               id: "invalidtokenmessage-string-object-messagefunction",
               level: 3,
               title: "optional invalidTokenMessage: string | object | MessageFunction",
               content:
                 "### optional invalidTokenMessage: string | object | MessageFunction\nThe custom message if the token is invalid."
             }
           ]
  end

  test "litellm-1" do
    html = File.read!("test/fixtures/litellm-1.html")

    assert Scraper.run!(html) == [
             %Item{
               id: nil,
               level: 1,
               title: "LiteLLM - Getting Started",
               content:
                 "# LiteLLM - Getting Started\n[https://github.com/BerriAI/litellm](https://github.com/BerriAI/litellm)"
             },
             %Item{
               id: "call-100-llms-using-the-openai-inputoutput-format",
               level: 2,
               title: "Call 100+ LLMs using the OpenAI Input/Output Format",
               content:
                 "## Call 100+ LLMs using the OpenAI Input/Output Format\n\n- Translate inputs to provider's `completion`, `embedding`, and `image_generation` endpoints\n- [Consistent output](https://docs.litellm.ai/docs/completion/output), text responses will always be available at `['choices'][0]['message']['content']`\n- Retry/fallback logic across multiple deployments (e.g. Azure/OpenAI) - [Router](https://docs.litellm.ai/docs/routing)\n- Track spend & set budgets per project [LiteLLM Proxy Server](https://docs.litellm.ai/docs/simple_proxy)"
             },
             %Item{
               id: "how-to-use-litellm",
               level: 2,
               title: "How to use LiteLLM",
               content:
                 "## How to use LiteLLM\nYou can use litellm through either:\n- [LiteLLM Proxy Server](#litellm-proxy-server-llm-gateway) - Server (LLM Gateway) to call 100+ LLMs, load balance, cost tracking across projects\n- [LiteLLM python SDK](#basic-usage) - Python Client to call 100+ LLMs, load balance, cost tracking"
             },
             %Item{
               id: "when-to-use-litellm-proxy-server-llm-gateway",
               level: 3,
               title: "When to use LiteLLM Proxy Server (LLM Gateway)",
               content:
                 "### When to use LiteLLM Proxy Server (LLM Gateway)\ntipUse LiteLLM Proxy Server if you want a central service (LLM Gateway) to access multiple LLMsTypically used by Gen AI Enablement /  ML PLatform Teams\n- LiteLLM Proxy gives you a unified interface to access multiple LLMs (100+ LLMs)\n- Track LLM Usage and setup guardrails\n- Customize Logging, Guardrails, Caching per project"
             },
             %Item{
               id: "when-to-use-litellm-python-sdk",
               level: 3,
               title: "When to use LiteLLM Python SDK",
               content:
                 "### When to use LiteLLM Python SDK\ntip  Use LiteLLM Python SDK if you want to use LiteLLM in your python codeTypically used by developers building llm projects\n- LiteLLM SDK gives you a unified interface to access multiple LLMs (100+ LLMs) \n- Retry/fallback logic across multiple deployments (e.g. Azure/OpenAI) - [Router](https://docs.litellm.ai/docs/routing)"
             },
             %Item{
               id: "litellm-python-sdk",
               level: 2,
               title: "LiteLLM Python SDK",
               content: "## LiteLLM Python SDK"
             },
             %Item{
               id: "basic-usage",
               level: 3,
               title: "Basic usage",
               content:
                 "### Basic usage\npip install litellm\n- OpenAI\n- Anthropic\n- VertexAI\n- HuggingFace\n- Azure OpenAI\n- Ollama\n- Openrouterfrom litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"OPENAI_API_KEY\"]=\"your-api-key\"\n\nresponse = completion(\nmodel=\"gpt-3.5-turbo\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}]\n)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"ANTHROPIC_API_KEY\"]=\"your-api-key\"\n\nresponse = completion(\nmodel=\"claude-2\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}]\n)from litellm import completion\nimport os\n\n# auth: run 'gcloud auth application-default'\nos.environ[\"VERTEX_PROJECT\"]=\"hardy-device-386718\"\nos.environ[\"VERTEX_LOCATION\"]=\"us-central1\"\n\nresponse = completion(\nmodel=\"chat-bison\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}]\n)from litellm import completion\nimport os\n\nos.environ[\"HUGGINGFACE_API_KEY\"]=\"huggingface_api_key\"\n\n# e.g. Call 'WizardLM/WizardCoder-Python-34B-V1.0' hosted on HF Inference endpoints\nresponse = completion(\nmodel=\"huggingface/WizardLM/WizardCoder-Python-34B-V1.0\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\napi_base=\"https://my-endpoint.huggingface.cloud\"\n)\n\nprint(response)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"AZURE_API_KEY\"]=\"\"\nos.environ[\"AZURE_API_BASE\"]=\"\"\nos.environ[\"AZURE_API_VERSION\"]=\"\"\n\n# azure call\nresponse = completion(\n\"azure/<your_deployment_name>\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}]\n)from litellm import completion\n\nresponse = completion(\nmodel=\"ollama/llama2\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\napi_base=\"http://localhost:11434\"\n)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"OPENROUTER_API_KEY\"]=\"openrouter_api_key\"\n\nresponse = completion(\nmodel=\"openrouter/google/palm-2-chat-bison\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\n)"
             },
             %Item{
               id: "streaming",
               level: 3,
               title: "Streaming",
               content:
                 "### Streaming\nSet `stream=True` in the `completion` args. \n- OpenAI\n- Anthropic\n- VertexAI\n- HuggingFace\n- Azure OpenAI\n- Ollama\n- Openrouterfrom litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"OPENAI_API_KEY\"]=\"your-api-key\"\n\nresponse = completion(\nmodel=\"gpt-3.5-turbo\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\nstream=True,\n)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"ANTHROPIC_API_KEY\"]=\"your-api-key\"\n\nresponse = completion(\nmodel=\"claude-2\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\nstream=True,\n)from litellm import completion\nimport os\n\n# auth: run 'gcloud auth application-default'\nos.environ[\"VERTEX_PROJECT\"]=\"hardy-device-386718\"\nos.environ[\"VERTEX_LOCATION\"]=\"us-central1\"\n\nresponse = completion(\nmodel=\"chat-bison\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\nstream=True,\n)from litellm import completion\nimport os\n\nos.environ[\"HUGGINGFACE_API_KEY\"]=\"huggingface_api_key\"\n\n# e.g. Call 'WizardLM/WizardCoder-Python-34B-V1.0' hosted on HF Inference endpoints\nresponse = completion(\nmodel=\"huggingface/WizardLM/WizardCoder-Python-34B-V1.0\",\nmessages=[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\napi_base=\"https://my-endpoint.huggingface.cloud\",\nstream=True,\n)\n\nprint(response)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"AZURE_API_KEY\"]=\"\"\nos.environ[\"AZURE_API_BASE\"]=\"\"\nos.environ[\"AZURE_API_VERSION\"]=\"\"\n\n# azure call\nresponse = completion(\n\"azure/<your_deployment_name>\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\nstream=True,\n)from litellm import completion\n\nresponse = completion(\nmodel=\"ollama/llama2\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\napi_base=\"http://localhost:11434\",\nstream=True,\n)from litellm import completion\nimport os\n\n## set ENV variables\nos.environ[\"OPENROUTER_API_KEY\"]=\"openrouter_api_key\"\n\nresponse = completion(\nmodel=\"openrouter/google/palm-2-chat-bison\",\nmessages =[{\"content\":\"Hello, how are you?\",\"role\":\"user\"}],\nstream=True,\n)"
             },
             %Item{
               id: "exception-handling",
               level: 3,
               title: "Exception handling",
               content:
                 "### Exception handling\nLiteLLM maps exceptions across all supported providers to the OpenAI exceptions. All our exceptions inherit from OpenAI's exception types, so any error-handling you have for that, should work out of the box with LiteLLM.from openai.error import OpenAIError\nfrom litellm import completion\n\nos.environ[\"ANTHROPIC_API_KEY\"]=\"bad-key\"\ntry:\n# some code\ncompletion(model=\"claude-instant-1\", messages=[{\"role\":\"user\",\"content\":\"Hey, how's it going?\"}])\nexcept OpenAIError as e:\nprint(e)"
             },
             %Item{
               id: "logging-observability---log-llm-inputoutput-docs",
               level: 3,
               title: "Logging Observability - Log LLM Input/Output ( Docs )",
               content:
                 "### Logging Observability - Log LLM Input/Output ( Docs )\nLiteLLM exposes pre defined callbacks to send data to Lunary, Langfuse, Helicone, Promptlayer, Traceloop, Slackfrom litellm import completion\n\n## set env variables for logging tools\nos.environ[\"HELICONE_API_KEY\"]=\"your-helicone-key\"\nos.environ[\"LANGFUSE_PUBLIC_KEY\"]=\"\"\nos.environ[\"LANGFUSE_SECRET_KEY\"]=\"\"\nos.environ[\"LUNARY_PUBLIC_KEY\"]=\"your-lunary-public-key\"\n\nos.environ[\"OPENAI_API_KEY\"]\n\n# set callbacks\nlitellm.success_callback =[\"lunary\",\"langfuse\",\"helicone\"]# log input/output to lunary, langfuse, supabase, helicone\n\n#openai call\nresponse = completion(model=\"gpt-3.5-turbo\", messages=[{\"role\":\"user\",\"content\":\"Hi  - i'm openai\"}])"
             },
             %Item{
               id: "track-costs-usage-latency-for-streaming",
               level: 3,
               title: "Track Costs, Usage, Latency for streaming",
               content:
                 "### Track Costs, Usage, Latency for streaming\nUse a callback function for this - more info on custom callbacks: [https://docs.litellm.ai/docs/observability/custom_callback](https://docs.litellm.ai/docs/observability/custom_callback)import litellm\n\n# track_cost_callback\ndeftrack_cost_callback(\nkwargs,# kwargs to completion\ncompletion_response,# response from completion\nstart_time, end_time    # start/end time\n):\ntry:\nresponse_cost = kwargs.get(\"response_cost\",0)\nprint(\"streaming response_cost\", response_cost)\nexcept:\npass\n# set callback\nlitellm.success_callback =[track_cost_callback]# set custom callback function\n\n# litellm.completion() call\nresponse = completion(\nmodel=\"gpt-3.5-turbo\",\nmessages=[\n{\n\"role\":\"user\",\n\"content\":\"Hi  - i'm openai\"\n}\n],\nstream=True\n)"
             },
             %Item{
               id: "litellm-proxy-server-llm-gateway",
               level: 2,
               title: "LiteLLM Proxy Server (LLM Gateway)",
               content:
                 "## LiteLLM Proxy Server (LLM Gateway)\nTrack spend across multiple projects/peopleThe proxy provides:\n- [Hooks for auth](https://docs.litellm.ai/docs/proxy/virtual_keys#custom-auth)\n- [Hooks for logging](https://docs.litellm.ai/docs/proxy/logging#step-1---create-your-custom-litellm-callback-class)\n- [Cost tracking](https://docs.litellm.ai/docs/proxy/virtual_keys#tracking-spend)\n- [Rate Limiting](https://docs.litellm.ai/docs/proxy/users#set-rate-limits)"
             },
             %Item{
               id: "-proxy-endpoints---swagger-docs",
               level: 3,
               title: "Proxy Endpoints - Swagger Docs",
               content:
                 "### Proxy Endpoints - Swagger Docs\nGo here for a complete tutorial with keys + rate limits - here"
             },
             %Item{
               id: "quick-start-proxy---cli",
               level: 3,
               title: "Quick Start Proxy - CLI",
               content: "### Quick Start Proxy - CLI\npip install'litellm[proxy]'"
             },
             %Item{
               id: "step-1-start-litellm-proxy",
               level: 4,
               title: "Step 1: Start litellm proxy",
               content:
                 "#### Step 1: Start litellm proxy\n$ litellm --model huggingface/bigcode/starcoder\n\n#INFO: Proxy running on http://0.0.0.0:4000"
             },
             %Item{
               id: "step-2-make-chatcompletions-request-to-proxy",
               level: 4,
               title: "Step 2: Make ChatCompletions Request to Proxy",
               content:
                 "#### Step 2: Make ChatCompletions Request to Proxy\nimport openai # openai v1.0.0+\nclient = openai.OpenAI(api_key=\"anything\",base_url=\"http://0.0.0.0:4000\")# set proxy to base_url\n# request sent to model set on litellm proxy, `litellm --model`\nresponse = client.chat.completions.create(model=\"gpt-3.5-turbo\", messages =[\n{\n\"role\":\"user\",\n\"content\":\"this is a test request, write a short poem\"\n}\n])\n\nprint(response)"
             },
             %Item{
               id: "more-details",
               level: 2,
               title: "More details",
               content:
                 "## More details\n\n- [exception mapping](/docs/exception_mapping)\n- [retries + model fallbacks for completion()](/docs/completion/reliable_completions)\n- [proxy virtual keys & spend management](/docs/proxy/virtual_keys)\n- [E2E Tutorial for LiteLLM Proxy Server](/docs/proxy/docker_quick_start)\n- Call 100+ LLMs using the OpenAI Input/Output Format\n- [How to use LiteLLM](#how-to-use-litellm)\n- When to use LiteLLM Proxy Server (LLM Gateway)\n- When to use LiteLLM Python SDK\n- LiteLLM Python SDK\n- [Basic usage](#basic-usage)\n- [Streaming](#streaming)\n- [Exception handling](#exception-handling)\n- [Logging Observability - Log LLM Input/Output (Docs)](#logging-observability---log-llm-inputoutput-docs)\n- [Track Costs, Usage, Latency for streaming](#track-costs-usage-latency-for-streaming)\n- LiteLLM Proxy Server (LLM Gateway)\n- [Proxy Endpoints - Swagger Docs](#-proxy-endpoints---swagger-docs)\n- [Quick Start Proxy - CLI](#quick-start-proxy---cli)\n- [More details](#more-details)"
             }
           ]
  end
end
