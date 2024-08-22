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

export type SearchFunction = (
  payload: { query: string },
  signal: AbortSignal,
) => Promise<SearchFunctionResult>;

export type BeforeSearchFunction = (query: string) => Promise<any>;
