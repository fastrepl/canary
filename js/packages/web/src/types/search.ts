export type SearchResult = SearchResultBase & {
  sub_results: SearchSubResult[];
};

export type SearchSubResult = SearchResultBase & {};

export interface SearchResultBase {
  url: string;
  title: string;
  excerpt?: string;
}

type SearchSourceType = "webpage" | "github_issue" | "github_discussion";

export type SearchFunctionResult = {
  search: Array<{
    name: string;
    type: SearchSourceType;
    hits: SearchResult[];
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
