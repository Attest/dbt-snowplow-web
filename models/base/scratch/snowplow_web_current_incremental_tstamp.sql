{{ config(materialized='ephemeral') }}

select * from {{ snowplow_utils.get_current_incremental_tstamp_table_relation('snowplow_web') }}
