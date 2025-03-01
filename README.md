[![early-release]][tracker-classificiation] [![License][license-image]][license] [![Discourse posts][discourse-image]][discourse]

# Attest Fork Changes

Attest have created a fork of this package to allow tracking of events which cannot drop the cookies to generate a `domain_sessionid` - Taker events.

Instead of `domain_sessionid`, we substitute `round_id` where `domain_sessionid` is NULL. We are happy to substitute one round as one session and consider them equivalent.

There are two main models which have beenaltered.

1. models/base/manifest/snowplow_web_base_sessions_lifecycle_manifest.sql

    This model generates the lifecycle (start and finish time) of each session so we can determine which sessions (and therefore events) should be processed for *this run*.
    The CTE `new_events_session_ids` has been updated to join to the `round` entity so that we can `COALESCE(domain_sessionid, round_id)` where applicable. So that taker data can be included in this calculation, and those session IDs can be identified as valid sessions. They are otherwise lost by a `WHERE` which requires `domain_sessionid IS NOT NULL`.

2. models/base/scratch/default/snowplow_web_base_events_this_run.sql

    This model contains all required events which are used in all downstream nodes. Data is taken from `snowplow_atomic.events` and joined to `round` entity again to enrich the dataset where `domain_sessionid` is NULL. This is required because the model also joins to `snowplow_web_base_sessions_lifecycle_manifest` using `domain_sessionid` which was previously enriched with `round_id`.

# snowplow-web

This dbt package:

- Transforms and aggregates raw web event data collected from the [Snowplow JavaScript tracker][tracker-docs] into a set of derived tables: page views, sessions and users.
- Derives a mapping between user identifiers, allowing for 'session stitching' and the development of a single customer view.
- Processes **all web events incrementally**. It is not just constrained to page view events - any custom events you are tracking will also be incrementally processed.
- Is designed in a modular manner, allowing you to easily integrate your own custom SQL into the incremental framework provided by the package.

Please refer to the [doc site][snowplow-web-docs] for a full breakdown of the package.

### Adapter Support

The snowplow-web v0.8.0 package currently supports BigQuery, Databricks, Redshift, Snowflake & Postgres.

|                      Warehouse                       |    dbt versions     | snowplow-web version |
| :--------------------------------------------------: | :-----------------: | :------------------: |
| BigQuery, Databricks, Redshift, Snowflake & Postgres |  >=1.0.0 to <2.0.0  |        0.8.0         |
|       BigQuery, Redshift, Snowflake & Postgres       | >=0.20.0 to <1.0.0  |        0.5.1         |
|            BigQuery, Redshift & Snowflake            | >=0.18.0 to <0.20.0 |        0.4.1         |
|                       Postgres                       | >=0.19.0 to <0.20.0 |        0.4.1         |

### Requirements

- A dataset of web events from the [Snowplow JavaScript tracker][tracker-docs] must be available in the database.
- Have the [`webPage` context][webpage-context] enabled.

### Installation

Check dbt Hub for the latest installation instructions, or read the [dbt docs][dbt-package-docs] for more information on installing packages.

### Configuration & Operation

Please refer to the [doc site][snowplow-web-docs] for details on how to configure and run the package.

### Models

The package contains multiple staging models however the mart models are as follows:

| Model                     | Description                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------------ |
| snowplow_web_page_views   | A table of page views, including engagement metrics such as scroll depth and engaged time. |
| snowplow_web_sessions     | An aggregated table of page views, grouped on `domain_sessionid`.                          |
| snowplow_web_users        | An aggregated table of sessions to a user level, grouped on `domain_userid`.               |
| snowplow_web_user_mapping | Provides a mapping between user identifiers, `domain_userid` and `user_id`.                |

# Join the Snowplow community

We welcome all ideas, questions and contributions!

For support requests, please use our community support [Discourse][discourse] forum.

If you find a bug, please report an issue on GitHub.

# Copyright and license

The snowplow-web package is Copyright 2021-2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[license]: http://www.apache.org/licenses/LICENSE-2.0
[license-image]: http://img.shields.io/badge/license-Apache--2-blue.svg?style=flat
[tracker-classificiation]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/tracker-maintenance-classification/
[early-release]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Early%20Release&color=014477&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC
[tracker-docs]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/
[webpage-context]: https://docs.snowplowanalytics.com/docs/collecting-data/collecting-from-own-applications/javascript-trackers/javascript-tracker/javascript-tracker-v3/tracker-setup/initialization-options/#Adding_predefined_contexts
[dbt-package-docs]: https://docs.getdbt.com/docs/building-a-dbt-project/package-management
[discourse-image]: https://img.shields.io/discourse/posts?server=https%3A%2F%2Fdiscourse.snowplowanalytics.com%2F
[discourse]: http://discourse.snowplowanalytics.com/
[snowplow-web-docs]: https://snowplow.github.io/dbt-snowplow-web/#!/overview/snowplow_web
