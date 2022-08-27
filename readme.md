## Unexpected error

Both `npx mikro-orm schema:create -r` and `npx mikro-orm schema:create -d` returns the following error despite using `entitiesTs: ['./libs/shared/src/entity/*.entity.ts']` in MikroORM config.

```bash
Error: [requireEntitiesArray] Explicit list of entities is required, please use the 'entities' option.
    at MetadataDiscovery.findEntities ($repo_root/node_modules/@mikro-orm/core/metadata/MetadataDiscovery.js:88:19)
    at MetadataDiscovery.discover ($repo_root/node_modules/@mikro-orm/core/metadata/MetadataDiscovery.js:34:20)
    at MikroORM.discoverEntities ($repo_root/node_modules/@mikro-orm/core/MikroORM.js:90:46)
    at Function.init ($repo_root/node_modules/@mikro-orm/core/MikroORM.js:45:19)
    at async Function.handleSchemaCommand ($repo_root/node_modules/@mikro-orm/cli/commands/SchemaCommandFactory.js:72:21)
```

## Reproduction

### Clone and build

```bash
git clone https://github.com/tukusejssirs/nx-mikro-orm.git
cd nx-mikro-orm
npm ci
npm run build
```

### Create from scratch and build

Edit and run [`create_from_scratch.sh`](create_from_scratch.sh).
