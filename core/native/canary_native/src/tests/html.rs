use crate::html;

use include_uri::include_str_from_url;
use insta::assert_snapshot;

#[test]
fn simple() {
    let html = include_str_from_url!("https://docs.litellm.ai");
    let md = html::to_md(&html).unwrap();
    assert_snapshot!(md, @r###"
    LiteLLM - Getting Started | liteLLM

    # LiteLLM - Getting Started

    ## **Call 100+ LLMs using the same Input/Output Format**

    *   Translate inputs to provider's `completion`, `embedding`, and `image_generation` endpoints
    *   , text responses will always be available at `['choices'][0]['message']['content']`
    *   Retry/fallback logic across multiple deployments (e.g. Azure/OpenAI) -
    *   Track spend & set budgets per project

    ## Basic usage

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

    ## Logging Observability - Log LLM Input/Output ()

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

    Use a callback function for this - more info on custom callbacks: 

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

    1.  
    2.  
    3.  
    4.  

    ### 📖 Proxy Endpoints -

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

    *   
    *   
    *   

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
fn fragment_link() {
    let html = include_str_from_url!("https://docs.getcanary.dev/integrations/vitepress");
    let md = html::to_md(&html).unwrap();
    assert_snapshot!(md, @r###"
    Integrations - VitePress | 🐤 Canary

    # Integrations - VitePress
    "###);
}
