export type PagefindResult = {
  url: string;
  content: string;
  excerpt: string;
  filters: any;
  locations: number[];
  meta: Record<string, any> & { title: string };
  raw_content: string;
  raw_url: string;
  sub_results: PagefindSubResult[];
  weighted_locations: WeightedLocation[];
  word_count: number;
};

export type PagefindSubResult = {
  url: string;
  title: string;
  locations: number[];
  excerpt: string;
  weighted_locations: WeightedLocation[];
};

type WeightedLocation = {
  balanced_score: number;
  location: number;
  weight: number;
};
