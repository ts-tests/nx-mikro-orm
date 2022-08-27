import { MikroOrmModuleOptions } from '@mikro-orm/nestjs';
import { TsMorphMetadataProvider } from '@mikro-orm/reflection';
import { Logger } from '@nestjs/common';

const logger = new Logger('MikroORM');

const ORM_CONFIG: MikroOrmModuleOptions = {
  allowGlobalContext: true,
  dbName: 'database',
  debug: false,
  discovery: {
    disableDynamicFileAccess: true,
    // warnWhenNoEntities: false,
  },
  entities: ['./dist/libs/shared/src/entity/*.entity.js'],
  entitiesTs: ['./libs/shared/src/entity/*.entity.ts'],
  host: 'postgres',
  logger: logger.log.bind(logger),
  metadataProvider: TsMorphMetadataProvider,
  password: 'password',
  pool: { min: 0, max: 200 },
  port: 5432,
  timezone: 'Europe/Bratislava',
  type: 'postgresql',
  user: 'postgres',
};

export { ORM_CONFIG };
export default ORM_CONFIG;
