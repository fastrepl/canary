import type { QueryContext } from "./context";

export type SearchResult = SearchResultBase & {
  sub_results: SearchSubResult[];
} & (
    | {
        type: "webpage";
        meta: {};
      }
    | {
        type: "github_issue";
        meta: {
          closed: boolean;
        };
      }
    | {
        type: "github_discussion";
        meta: {
          closed: boolean;
          answered: boolean;
        };
      }
  );

export type SearchSubResult = SearchResultBase & {};

export interface SearchResultBase {
  url: string;
  title: string;
  excerpt?: string;
}

export type SearchFunctionResult = {
  matches: SearchResult[];
  suggestion?: {
    questions: string[];
  };
};

export type SearchFunction = (
  payload: QueryContext,
  signal: AbortSignal,
) => Promise<SearchFunctionResult>;

export type BeforeSearchFunction = (query: QueryContext) => Promise<any>;
