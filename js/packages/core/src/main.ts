export type Request = {
  id: string;
  content: string;
};
export type Response = {
  id: string;
  content?: string;
  done?: boolean;
};

export default class CanaryClient {
  url: string;
  private handleResponse: (response: Response) => void;
  private abortController: AbortController | null = null;

  constructor(baseUrl: string, handleResponse: (response: Response) => void) {
    this.url = `${baseUrl}/api/website/submit`;
    this.handleResponse = handleResponse;
  }

  async submit(id: string, content: string) {
    this.stop();
    this.abortController = new AbortController();

    const data = JSON.stringify({ type: "submit", id, content } as Request);

    try {
      const { body } = await fetch(this.url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: data,
        signal: this.abortController.signal,
      });
      if (!body) {
        return;
      }

      const reader = body.pipeThrough(new TextDecoderStream()).getReader();
      while (true) {
        const { value, done } = await reader.read();
        if (done) {
          break;
        }

        const items = value
          .split("\n\n")
          .flatMap((s) => s.split("data: "))
          .filter(Boolean);

        items.forEach((item) => {
          this.cb(item);
        });
      }
    } catch (e: any) {
      if (e.name !== "AbortError") {
        console.error(e);
      }
    }
  }

  stop() {
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
  }

  private cb(payload: string) {
    try {
      const response = JSON.parse(payload);
      this.handleResponse(response);
    } catch (e) {
      console.error(e);
    }
  }
}
