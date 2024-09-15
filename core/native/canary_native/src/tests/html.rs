use crate::html;

use include_uri::include_str_from_url;
use insta::assert_snapshot;

#[test]
fn to_md() {
    let html = include_str_from_url!("https://docs.litellm.ai");
    let md = html::to_md(&html).unwrap();
    assert_snapshot!(md, @r###"
    LiteLLM - Getting Started | liteLLM

    # LiteLLM - Getting Started

    [https://github.com/BerriAI/litellm](https://github.com/BerriAI/litellm)

    ## **Call 100+ LLMs using the OpenAI Input/Output Format**

    *   Translate inputs to provider's `completion`, `embedding`, and `image_generation` endpoints
    *   [Consistent output](https://docs.litellm.ai/docs/completion/output), text responses will always be available at `['choices'][0]['message']['content']`
    *   Retry/fallback logic across multiple deployments (e.g. Azure/OpenAI) - [Router](https://docs.litellm.ai/docs/routing)
    *   Track spend & set budgets per project [LiteLLM Proxy Server](https://docs.litellm.ai/docs/simple_proxy)

    ## Basic usage

    [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/BerriAI/litellm/blob/main/cookbook/liteLLM_Getting_Started.ipynb)

    ```shell
    pip install litellm  
    ```

    *   OpenAI
    *   Anthropic
    *   VertexAI
    *   HuggingFace
    *   Azure OpenAI
    *   Ollama
    *   Openrouter

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["OPENAI_API_KEY"] = "your-api-key"  
      
    response = completion(  
      model="gpt-3.5-turbo",  
      messages=[{ "content": "Hello, how are you?","role": "user"}]  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["ANTHROPIC_API_KEY"] = "your-api-key"  
      
    response = completion(  
      model="claude-2",  
      messages=[{ "content": "Hello, how are you?","role": "user"}]  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    # auth: run 'gcloud auth application-default'  
    os.environ["VERTEX_PROJECT"] = "hardy-device-386718"  
    os.environ["VERTEX_LOCATION"] = "us-central1"  
      
    response = completion(  
      model="chat-bison",  
      messages=[{ "content": "Hello, how are you?","role": "user"}]  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    os.environ["HUGGINGFACE_API_KEY"] = "huggingface_api_key"  
      
    # e.g. Call 'WizardLM/WizardCoder-Python-34B-V1.0' hosted on HF Inference endpoints  
    response = completion(  
      model="huggingface/WizardLM/WizardCoder-Python-34B-V1.0",  
      messages=[{ "content": "Hello, how are you?","role": "user"}],  
      api_base="https://my-endpoint.huggingface.cloud"  
    )  
      
    print(response)  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["AZURE_API_KEY"] = ""  
    os.environ["AZURE_API_BASE"] = ""  
    os.environ["AZURE_API_VERSION"] = ""  
      
    # azure call  
    response = completion(  
      "azure/<your_deployment_name>",  
      messages = [{ "content": "Hello, how are you?","role": "user"}]  
    )  
    ```

    ```python
    from litellm import completion  
      
    response = completion(  
                model="ollama/llama2",  
                messages = [{ "content": "Hello, how are you?","role": "user"}],  
                api_base="http://localhost:11434"  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["OPENROUTER_API_KEY"] = "openrouter_api_key"  
      
    response = completion(  
      model="openrouter/google/palm-2-chat-bison",  
      messages = [{ "content": "Hello, how are you?","role": "user"}],  
    )  
    ```

    ## Streaming

    Set `stream=True` in the `completion` args.

    *   OpenAI
    *   Anthropic
    *   VertexAI
    *   HuggingFace
    *   Azure OpenAI
    *   Ollama
    *   Openrouter

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["OPENAI_API_KEY"] = "your-api-key"  
      
    response = completion(  
      model="gpt-3.5-turbo",  
      messages=[{ "content": "Hello, how are you?","role": "user"}],  
      stream=True,  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["ANTHROPIC_API_KEY"] = "your-api-key"  
      
    response = completion(  
      model="claude-2",  
      messages=[{ "content": "Hello, how are you?","role": "user"}],  
      stream=True,  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    # auth: run 'gcloud auth application-default'  
    os.environ["VERTEX_PROJECT"] = "hardy-device-386718"  
    os.environ["VERTEX_LOCATION"] = "us-central1"  
      
    response = completion(  
      model="chat-bison",  
      messages=[{ "content": "Hello, how are you?","role": "user"}],  
      stream=True,  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    os.environ["HUGGINGFACE_API_KEY"] = "huggingface_api_key"  
      
    # e.g. Call 'WizardLM/WizardCoder-Python-34B-V1.0' hosted on HF Inference endpoints  
    response = completion(  
      model="huggingface/WizardLM/WizardCoder-Python-34B-V1.0",  
      messages=[{ "content": "Hello, how are you?","role": "user"}],  
      api_base="https://my-endpoint.huggingface.cloud",  
      stream=True,  
    )  
      
    print(response)  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["AZURE_API_KEY"] = ""  
    os.environ["AZURE_API_BASE"] = ""  
    os.environ["AZURE_API_VERSION"] = ""  
      
    # azure call  
    response = completion(  
      "azure/<your_deployment_name>",  
      messages = [{ "content": "Hello, how are you?","role": "user"}],  
      stream=True,  
    )  
    ```

    ```python
    from litellm import completion  
      
    response = completion(  
                model="ollama/llama2",  
                messages = [{ "content": "Hello, how are you?","role": "user"}],  
                api_base="http://localhost:11434",  
                stream=True,  
    )  
    ```

    ```python
    from litellm import completion  
    import os  
      
    ## set ENV variables  
    os.environ["OPENROUTER_API_KEY"] = "openrouter_api_key"  
      
    response = completion(  
      model="openrouter/google/palm-2-chat-bison",  
      messages = [{ "content": "Hello, how are you?","role": "user"}],  
      stream=True,  
    )  
    ```

    ## Exception handling

    LiteLLM maps exceptions across all supported providers to the OpenAI exceptions. All our exceptions inherit from OpenAI's exception types, so any error-handling you have for that, should work out of the box with LiteLLM.

    ```python
    from openai.error import OpenAIError  
    from litellm import completion  
      
    os.environ["ANTHROPIC_API_KEY"] = "bad-key"  
    try:  
        # some code  
        completion(model="claude-instant-1", messages=[{"role": "user", "content": "Hey, how's it going?"}])  
    except OpenAIError as e:  
        print(e)  
    ```

    ## Logging Observability - Log LLM Input/Output ([Docs](https://docs.litellm.ai/docs/observability/callbacks))

    LiteLLM exposes pre defined callbacks to send data to Lunary, Langfuse, Helicone, Promptlayer, Traceloop, Slack

    ```python
    from litellm import completion  
      
    ## set env variables for logging tools  
    os.environ["HELICONE_API_KEY"] = "your-helicone-key"  
    os.environ["LANGFUSE_PUBLIC_KEY"] = ""  
    os.environ["LANGFUSE_SECRET_KEY"] = ""  
    os.environ["LUNARY_PUBLIC_KEY"] = "your-lunary-public-key"  
      
    os.environ["OPENAI_API_KEY"]  
      
    # set callbacks  
    litellm.success_callback = ["langfuse", "lunary"] # log input/output to lunary, langfuse, supabase  
      
    #openai call  
    response = completion(model="gpt-3.5-turbo", messages=[{"role": "user", "content": "Hi 👋 - i'm openai"}])  
    ```

    ## Track Costs, Usage, Latency for streaming

    Use a callback function for this - more info on custom callbacks: [https://docs.litellm.ai/docs/observability/custom\_callback](https://docs.litellm.ai/docs/observability/custom_callback)

    ```python
    import litellm  
      
    # track_cost_callback  
    def track_cost_callback(  
        kwargs,                 # kwargs to completion  
        completion_response,    # response from completion  
        start_time, end_time    # start/end time  
    ):  
        try:  
          response_cost = kwargs.get("response_cost", 0)  
          print("streaming response_cost", response_cost)  
        except:  
            pass  
    # set callback  
    litellm.success_callback = [track_cost_callback] # set custom callback function  
      
    # litellm.completion() call  
    response = completion(  
        model="gpt-3.5-turbo",  
        messages=[  
            {  
                "role": "user",  
                "content": "Hi 👋 - i'm openai"  
            }  
        ],  
        stream=True  
    )  
    ```

    ## OpenAI Proxy

    Track spend across multiple projects/people

    ![ui_3](https://github.com/BerriAI/litellm/assets/29436595/47c97d5e-b9be-4839-b28c-43d7f4f10033)

    The proxy provides:

    1.  [Hooks for auth](https://docs.litellm.ai/docs/proxy/virtual_keys#custom-auth)
    2.  [Hooks for logging](https://docs.litellm.ai/docs/proxy/logging#step-1---create-your-custom-litellm-callback-class)
    3.  [Cost tracking](https://docs.litellm.ai/docs/proxy/virtual_keys#tracking-spend)
    4.  [Rate Limiting](https://docs.litellm.ai/docs/proxy/users#set-rate-limits)

    ### 📖 Proxy Endpoints - [Swagger Docs](https://litellm-api.up.railway.app/)

    ### Quick Start Proxy - CLI

    ```shell
    pip install 'litellm[proxy]'  
    ```

    #### Step 1: Start litellm proxy

    ```shell
    $ litellm --model huggingface/bigcode/starcoder  
      
    #INFO: Proxy running on http://0.0.0.0:8000  
    ```

    #### Step 2: Make ChatCompletions Request to Proxy

    ```python
    import openai # openai v1.0.0+  
    client = openai.OpenAI(api_key="anything",base_url="http://0.0.0.0:8000") # set proxy to base_url  
    # request sent to model set on litellm proxy, `litellm --model`  
    response = client.chat.completions.create(model="gpt-3.5-turbo", messages = [  
        {  
            "role": "user",  
            "content": "this is a test request, write a short poem"  
        }  
    ])  
      
    print(response)  
    ```

    ## More details

    *   [exception mapping](/exception_mapping.md)
    *   [retries + model fallbacks for completion()](/completion/reliable_completions.md)
    *   [proxy virtual keys & spend management](/tutorials/fallbacks.md)

    *   
    *   
    *   
    *   
    *   
    *   
    *   *
        *
    *
    "###);
}

#[test]
fn to_md_vitepress_code() {
    let html = r#"
<div class="language-html vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">html</span><pre class="shiki shiki-themes github-light github-dark has-diff vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-root</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> framework</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">"vitepress"</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span>
<span class="line diff remove"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-provider-vitepress-minisearch</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span>
<span class="line diff add"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    &lt;</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-provider-cloud</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> api-key</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">"KEY"</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> api-base</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">"https://cloud.getcanary.dev"</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">      &lt;!-- Rest of the code --&gt;</span></span>
<span class="line diff add"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    &lt;/</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-provider-cloud</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span>
<span class="line diff remove"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;/</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-provider-vitepress-minisearch</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;/</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D;">canary-root</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;</span></span></code></pre></div>
    "#;

    let md = html::to_md(&html).unwrap();
    assert_snapshot!(md, @r###"
    html

    ```
    <canary-root framework="vitepress">
      <canary-provider-vitepress-minisearch>
        <canary-provider-cloud api-key="KEY" api-base="https://cloud.getcanary.dev">
          <!-- Rest of the code -->
        </canary-provider-cloud>
      </canary-provider-vitepress-minisearch>
    </canary-root>
    ```
    "###);
}
