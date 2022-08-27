import { Entity, PrimaryKey } from '@mikro-orm/core';

@Entity({tableName: 'some_test'})
export class SomeTest {
  @PrimaryKey()
  id!: number
}
