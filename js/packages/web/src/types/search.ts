export interface SearchReference {
  url: string;
  title: string;
  titles?: string[];
  tags?: string[];
  excerpt?: string;
}

type SearchSourceType = "webpage" | "github_issue" | "github_discussion";

export type SearchFunctionResult = {
  search: Array<{
    name: string;
    type: SearchSourceType;
    hits: SearchReference[];
  }>;
  suggestion?: {
    questions: string[];
  };
};

export type SearchFunction = (
  payload: { query: string },
  signal: AbortSignal,
) => Promise<SearchFunctionResult>;

export type BeforeSearchFunction = (query: string) => Promise<any>;
