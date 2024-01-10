import NodeCache from "node-cache";
import { singleton } from "../singleton";

@singleton(CacheService)
export class CacheService {
  private nodeCache: NodeCache;
  constructor() {
    this.nodeCache = new NodeCache({
      stdTTL: 60,
    });
  }

  public get<T>(key: string) {
    return this.nodeCache.get<T>(key);
  }

  public set<T>(key: string, value: T, ttl?: string | number) {
    return ttl
      ? this.nodeCache.set<T>(key, value, ttl)
      : this.nodeCache.set<T>(key, value);
  }
}
