export function cache<T extends (...args: any[]) => any>(fn: T): T {
  const _cache = new Map<string, any>();

  return ((...args: Parameters<T>): ReturnType<T> => {
    const key = JSON.stringify(args);

    if (_cache.has(key)) {
      return _cache.get(key);
    }

    const result = fn(...args);
    if (result) {
      _cache.set(key, result);
    }

    return result;
  }) as T;
}
