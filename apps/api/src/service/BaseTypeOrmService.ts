import { DecorateAll } from "decorate-all";
import { inject } from "inversify";
import { provide } from "inversify-binding-decorators";
import {
  Brackets,
  FindManyOptions,
  FindOptionsWhere,
  In,
  LessThanOrEqual,
  MoreThanOrEqual,
  Repository,
} from "typeorm";
import { QueryDeepPartialEntity } from "typeorm/query-builder/QueryPartialEntity";
import { TypeOrmConnection } from "../db/typeorm";
import { RootObject } from "../entity/rootObject";
import { PrometheusClient } from "../prometheus";

export type GroupByReturnType<K extends string> = {
  [k in K]?: string | boolean;
} & {
  count: number;
};

export type RootFilter<T extends RootObject> = Partial<Omit<T, "created_at">> & {
  created_at?: {
    lte?: Date;
    gte?: Date;
  };
};

function durationMetrics(_: any, propertyKey: string | symbol, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = async function (...props: any) {
    const selfClass = this as any;
    const endFn = selfClass.prometheusClient.DBQueryHistogram.startTimer({
      collection: selfClass.model.metadata.tableName,
      operation: propertyKey.toString(),
      worker_id: selfClass.prometheusClient.HostId,
    });
    let status: "success" | "error" = "success";
    try {
      const result = await original.call(this, ...props);
      return result;
    } catch (e) {
      status = "error";
      throw e;
    } finally {
      endFn({ status });
    }
  };
}

@provide(BaseTypeOrmService)
@DecorateAll(durationMetrics, {
  exclude: ["groupByQueryBuilder", "paginateQuery"],
})
export abstract class BaseTypeOrmService<T extends RootObject> {
  abstract get model(): Repository<T>;

  constructor(
    @inject(TypeOrmConnection) protected conn: TypeOrmConnection,
    @inject(PrometheusClient) protected prometheusClient: PrometheusClient
  ) {}

  private paginateQuery(
    filter: FindOptionsWhere<T>,
    textSearch: { [k: string]: string | undefined } = {}
  ) {
    const query = this.model.createQueryBuilder().where(filter);
    if (Object.keys(textSearch).length > 0) {
      query.andWhere(
        new Brackets(qb => {
          for (const field in textSearch) {
            if (textSearch[field]) {
              const fieldQuery = `to_tsvector(${field}) @@ to_tsquery(:${field})`;
              qb.orWhere(fieldQuery, { [field]: textSearch[field] });
            }
          }
          return qb;
        })
      );
    }
    return query;
  }

  transformFilter(r: RootFilter<T>): FindOptionsWhere<T> {
    const filter: FindOptionsWhere<T> = {
      ...r,
      created_at: undefined,
      text: undefined,
    } as FindOptionsWhere<T>;
    delete filter["created_at"];
    delete (filter as any)["text"];
    if (r.created_at?.gte) {
      filter["created_at"] = MoreThanOrEqual(r.created_at.gte) as any;
    }
    if (r.created_at?.lte) {
      filter["created_at"] = LessThanOrEqual(r.created_at.lte) as any;
    }
    return filter;
  }

  async getAll(): Promise<T[]> {
    return await this.model.find();
  }

  async getById(id: string): Promise<T | null> {
    try {
      return this.model.findOneBy({ id: id as any });
    } catch (e) {
      return null;
    }
  }

  async getByIds(ids: string[]): Promise<T[]> {
    return await this.model.find({ where: { id: In(ids) as any } });
  }

  async getOne(value: any, queryBy: keyof T): Promise<T | null> {
    const query = {
      [queryBy]: value,
    } as FindOptionsWhere<T>;
    return await this.model.findOneBy(query);
  }

  async find(query: FindManyOptions<T>) {
    return await this.model.find(query);
  }

  async create(newResource: Omit<T, "id" | "created_at" | "updated_at">): Promise<T> {
    const saved = await this.model.save(newResource as T);
    this.prometheusClient.DBInsertCounter.labels({
      collection: this.model.metadata.tableName,
      worker_id: this.prometheusClient.HostId,
    }).inc(1);
    return saved;
  }

  async insert(newResources: Omit<T, "id" | "created_at" | "updated_at">[]): Promise<T[]> {
    const saved = await this.model.save(newResources as T[]);
    this.prometheusClient.DBInsertCounter.labels({
      collection: this.model.metadata.tableName,
      worker_id: this.prometheusClient.HostId,
    }).inc(saved.length);
    return saved;
  }

  async update(filter: FindOptionsWhere<T>, updatedResource: QueryDeepPartialEntity<T>) {
    const updated = await this.model.update(filter, updatedResource);
    return updated.affected;
  }

  async delete(id: string) {
    return await this.model.delete({ id: id as any });
  }

  async deleteMany(filter: FindOptionsWhere<T>) {
    const deleteResult = await this.model.delete(filter);
    return deleteResult;
  }

  getRawMany(groupBy: string[], filter: FindOptionsWhere<T> = {}, select: string[] = groupBy) {
    return this.groupByQueryBuilder(groupBy, filter, select).getRawMany();
  }

  private groupByQueryBuilder(
    groupBy: string[],
    filter: FindOptionsWhere<T> = {},
    select: string[] = groupBy
  ) {
    const query = this.model
      .createQueryBuilder()
      .select([...select, "count(*) as count"])
      .where(filter);
    groupBy.forEach(group => {
      query.addGroupBy(group);
    });
    return query;
  }

  async count(): Promise<number> {
    return this.model.count();
  }
}
