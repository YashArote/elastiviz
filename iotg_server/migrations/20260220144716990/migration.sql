BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "capability_registry" (
    "id" bigserial PRIMARY KEY,
    "registryJson" text NOT NULL,
    "refreshedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "dataset_registry" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "indexPattern" text NOT NULL,
    "dataType" text NOT NULL,
    "lastSeen" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "dataset_registry_name_idx" ON "dataset_registry" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "field_registry" (
    "id" bigserial PRIMARY KEY,
    "dataset" text NOT NULL,
    "fieldPath" text NOT NULL,
    "fieldType" text NOT NULL,
    "isNumeric" boolean NOT NULL,
    "isTimeseries" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "field_registry_path_idx" ON "field_registry" USING btree ("dataset", "fieldPath");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "metric_dictionary" (
    "id" bigserial PRIMARY KEY,
    "category" text NOT NULL,
    "entityType" text NOT NULL,
    "dataset" text NOT NULL,
    "fieldPath" text NOT NULL,
    "unit" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "metric_dict_category_entity_idx" ON "metric_dictionary" USING btree ("category", "entityType");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "observability_query" (
    "id" bigserial PRIMARY KEY,
    "userQuery" text NOT NULL,
    "intentJson" text NOT NULL,
    "planJson" text NOT NULL,
    "esqlQuery" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "observability_result" (
    "id" bigserial PRIMARY KEY,
    "queryId" bigint NOT NULL,
    "chartJson" text NOT NULL,
    "explanation" text NOT NULL,
    "hasAnomalies" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR iotg
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('iotg', '20260220144716990', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260220144716990', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
