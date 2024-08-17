// @ts-ignore
import { parse as _parseTabs } from "./tabs";

type ParseInput = string;
type ParseResult = Array<{ name: string; pattern: RegExp | null }>;

export const parseTabs = _parseTabs as (_: ParseInput) => ParseResult;
