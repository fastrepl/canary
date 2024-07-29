export type FeedbackFunction = (
  url: string,
  data: { content: string },
) => Promise<null>;
