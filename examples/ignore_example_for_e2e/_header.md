# Premium example (ignored for e2e tests)

This example deploys Azure Managed Redis with Premium SKU and advanced features.

## Features

- Premium P1 Redis cache
- High availability with 1 replica per primary
- Sharding with 1 shard
- Availability zones (1, 2, 3)
- RDB backup enabled (60-minute frequency)
- TLS 1.2 minimum
- Authentication enabled
- allkeys-lru eviction policy

This example demonstrates production-ready configuration with enterprise features but is ignored in e2e tests due to higher cost and longer deployment time.

