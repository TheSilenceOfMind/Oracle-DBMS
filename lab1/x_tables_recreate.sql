drop table "x";
drop table x;

CREATE TABLE "x"(x number);
INSERT INTO "x" VALUES (1);

CREATE TABLE x(x number);
INSERT INTO x VALUES (10);

SELECT table_name from user_tables;