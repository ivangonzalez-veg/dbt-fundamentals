{% macro new_db_schema_role(pilot_database_name, schema_name, new_role_name) -%}

{#

dbt run-operation new_db_schema_role --args '{"pilot_database_name": "db_test", "schema_name": "schema_test", "new_role_name": "role_test"}'

{% set cfg = {
  'pilot_database_name': 'pilot',
  'schema_name': 'raw_stage',
  'new_role_name': 'dv_role',
}%}
#}

// Create a new database for the Pilot. 
use role ACCOUNTADMIN;
create or replace database {{ cfg.pilot_database_name }};

// Create a schema for the Raw Stage (where you can create views on the source tables)
create or replace schema {{ cfg.schema_name }}; 

// Bringing in the source tables as views in the created schema
--create view <view_name> as select * from <source_database>.<source_schema>.<source_table>;
-- to be repeated for all source tables

// Creating a new role and granting privileges on the new database to the new role
use role ACCOUNTADMIN;
create role {{ cfg.new_role_name }};
grant role {{ cfg.new_role_name }} to role PUBLIC; // before you can use the role it needs to granted to one of the default roles

// Allowing the new role to see the database
grant usage on database {{ cfg.pilot_database_name }} to role {{ cfg.new_role_name }};

// Allowing the new role to see the schema containing the source tables as views 
grant usage on schema {{ cfg.pilot_database_name }}.{{ cfg.schema_name }} to role {{ cfg.new_role_name }}; 

// Allowing the new role to see the views inside the database and run select queries against them
grant select on all views in schema {{ cfg.pilot_database_name }}.{{ cfg.schema_name }} to role {{ cfg.new_role_name }}; 

// Allowing the new role to see future schemas created in the database by the role (e.g. ACCOUNTADMIN) owning the database object 
grant all privileges on future schemas in database {{ cfg.pilot_database_name }} to role {{ cfg.new_role_name }}; 

// Allowing the new role to see future views created inside future schemas by the owner of the database 
grant select on future views in database {{ cfg.pilot_database_name }} to role {{ cfg.new_role_name }}; 

// Allowing the new role to create new schemas inside the database 
grant create schema on database {{ cfg.pilot_database_name }} to role {{ cfg.new_role_name }}; 


// Checking the new role can see the schemas and objects inside the schema in the PILOT database
// Checking the new role can create schemas inside database and views (using SELECT queries) inside schemas newly created by the new role
use role {{ cfg.new_role_name }};

// Checking current role, current database, current schema;
{#
select current_role(), current_database(), current_schema();
}#

{%- endmacro %}
