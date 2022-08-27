#!/usr/bin/env bash

# Define workspace/organisation name
workspace_name='nx-mikro-orm'

# Define monorepo path (without workspace name)
path="$(realpath .)"

# Define repo path
repo_root="$path/$workspace_name"

# Create Nx workspace (monorepo)
cd "$path"
npx create-nx-workspace --preset=nest "$workspace_name" --appName testApp --pm npm --nxCloud false

# Save exact version of NPM dependencies
echo 'save-exact=true' > "$repo_root/.npmrc"

# Install additional dependencies and update all installed
# Note: We need to remove `@nestjs/schematics` `@nestjs/testing` first, otherwise NPM could not resolve the version of `@nestjs/*` dependencies.
# --- Note: Force (`-f`) is needed because I want to use Nest.js v9, however Nx ... ???
# Note: `ts-jest` currently supports `jest@28` as the latest `jest` version, thus `@types/jest@28` and `jest@28`. needs to be also installed.
cd "$repo_root"
npm r @nestjs/schematics @nestjs/testing
npm i @mikro-orm/core@latest @mikro-orm/migrations@latest @mikro-orm/nestjs@latest @mikro-orm/postgresql@latest @mikro-orm/reflection@latest @mikro-orm/seeder@latest @mikro-orm/sql-highlighter@latest @nestjs/common@latest @nestjs/core@latest @nestjs/platform-express@latest reflect-metadata@latest rxjs@latest tslib@latest
npm -D i @mikro-orm/cli@latest @nestjs/schematics@latest @nestjs/testing@latest @nrwl/cli@latest @nrwl/eslint-plugin-nx@latest @nrwl/jest@latest @nrwl/linter@latest @nrwl/nest@latest @nrwl/node@latest @nrwl/workspace@latest @types/jest@28 @types/node@latest @typescript-eslint/eslint-plugin@latest @typescript-eslint/parser@latest eslint@latest eslint-config-prettier@latest jest@28 nx@latest prettier@latest ts-jest@28 ts-node@latest typescript@latest

# Create a `shared` library
nx g @nrwl/nest:library shared

# Remove everything from `shared` library
rm -rf "$repo_root/libs/shared/src"/*

# Create some folders
mkdir "$repo_root/libs/shared/src"/{config,entity}

# Create MikroORM config file
# Note: Update database connection configuration.
cat << 'EOF' > "$repo_root/libs/shared/src/config/mikro-orm.config.ts"
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
EOF

# TODO: Create a test entity
cat << 'EOF' > "$repo_root/libs/shared/src/entity/some-test.entity.ts"
import { Entity, PrimaryKey } from '@mikro-orm/core';

@Entity({tableName: 'some_test'})
export class SomeTest {
  @PrimaryKey()
  id!: number
}
EOF

# Create `index.ts`
cat << EOF > "$repo_root/libs/shared/src/index.ts"
export {ORM_CONFIG} from './config/mikro-orm.config'
export {SomeTest} from './entity/some-test.entity'
EOF

# TODO: Update `package.json` to include MikroORM config
# shellcheck disable=SC2094
cat <<< "$(jq -S '.+ {"mikro-orm":{"configPaths":["./libs/shared/src/config/mikro-orm.config.ts","./dist/libs/shared/src/config/mikro-orm.config.ts"],"useTsNode":true}}' "$repo_root/package.json")" > "$repo_root/package.json"

# Create a dummy root `tsconfig.json`
cat << EOF > "$repo_root/tsconfig.json"
{
  "extends": "./tsconfig.base.json"
}
EOF

# Build files
npm run build

# FIXME: Generate database schema
# npx mikro-orm schema:create -r
npx mikro-orm schema:create -d
