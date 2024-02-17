-- CREATE DATABASE "rinha_24_q1_production" ENCODING = 'unicode';

-- CREATE SCHEMA "rinha_24_q1_production";

CREATE UNLOGGED TABLE "transactions" (
    "id" bigserial PRIMARY KEY,
    "customer_id" integer NOT NULL,
    "customer_limit_cents" bigint NOT NULL,
    "customer_balance_cents" bigint NOT NULL,
    "amount" bigint NOT NULL,
    "kind" integer NOT NULL,
    "description" character varying(10) NOT NULL,
    "created_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE INDEX "index_transactions_on_customer_id" ON "transactions" ("customer_id");

INSERT INTO "transactions" ("customer_id", "customer_limit_cents", "customer_balance_cents", "amount", "kind", "description", "created_at") 
VALUES (1, 100000, 0, 0, 0, 'Seed', '2024-02-16 23:29:55.449289') 
RETURNING "id", "created_at";

INSERT INTO "transactions" ("customer_id", "customer_limit_cents", "customer_balance_cents", "amount", "kind", "description", "created_at") 
VALUES (2, 80000, 0, 0, 0, 'Seed', '2024-02-16 23:29:55.455800') 
RETURNING "id", "created_at";

INSERT INTO "transactions" ("customer_id", "customer_limit_cents", "customer_balance_cents", "amount", "kind", "description", "created_at") 
VALUES (3, 1000000, 0, 0, 0, 'Seed', '2024-02-16 23:29:55.463948') 
RETURNING "id", "created_at";

INSERT INTO "transactions" ("customer_id", "customer_limit_cents", "customer_balance_cents", "amount", "kind", "description", "created_at") 
VALUES (4, 10000000, 0, 0, 0, 'Seed', '2024-02-16 23:29:55.472397') 
RETURNING "id", "created_at";

INSERT INTO "transactions" ("customer_id", "customer_limit_cents", "customer_balance_cents", "amount", "kind", "description", "created_at") 
VALUES (5, 500000, 0, 0, 0, 'Seed', '2024-02-16 23:29:55.480339') 
RETURNING "id", "created_at";