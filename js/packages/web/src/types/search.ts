export interface SearchReference {
  url: string;
  title: string;
  titles?: string[];
  tags?: string[];
  excerpt?: string;
}

export type SearchFunctionResult = {
  search: SearchReference[];
  suggestion?: {
    questions: string[];
  };
};

export type SearchFunctionOptions = {
  includeSuggestion?: boolean;
};

export type SearchFunction = (
  query: string,
  signal: AbortSignal,
  options?: SearchFunctionOptions,
) => Promise<SearchFunctionResult>;

export type BeforeSearchFunction = (query: string) => Promise<any>;
