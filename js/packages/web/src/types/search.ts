import type { QueryContext } from "./context";
import type { Meta } from "./meta";

export type SearchResult = SearchResultBase & {
  sub_results: SearchSubResult[];
} & (
    | {
        type: "webpage";
        meta: {};
      }
    | {
        type: "openapi";
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
  query: QueryContext,
  meta: Meta,
  signal: AbortSignal,
) => Promise<SearchFunctionResult>;

export type BeforeSearchFunction = (query: QueryContext) => Promise<any>;
