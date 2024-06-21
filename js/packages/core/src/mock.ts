import { http, HttpResponse } from "msw";

const encoder = new TextEncoder();

export const sseHandler = (url: string, items: any[]) => {
  return http.post(url, () => {
    const stream = new ReadableStream({
      start(controller) {
        items.forEach((item) => {
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify(item)}\n\n`),
          );
        });

        controller.close();
      },
    });

    return new HttpResponse(stream, {
      headers: {
        "Content-Type": "text/event-stream",
      },
    });
  });
};
