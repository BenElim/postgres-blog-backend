# PostgreSQL Blog Backend

## Project Description

This project is a PostgreSQL-based blog backend that demonstrates:

* JSONB metadata
* Full-text search
* GIN indexes
* Database triggers
* Date-based table partitioning
* Query performance analysis using `EXPLAIN ANALYZE`

## Database Table

The main table is called `posts`.

It contains:

* `id` - Unique post ID
* `title` - Blog post title
* `body` - Blog post content
* `metadata` - JSONB data such as tags
* `search_vec` - Full-text search vector
* `published_at` - Date and time the post was published

## Features

### 1. Table Partitioning

The `posts` table is partitioned by `published_at`.

A `posts_2025` partition stores posts published during 2025.

### 2. JSONB Metadata

The `metadata` column stores flexible information such as:

```json
{
  "tags": ["postgres", "performance"]
}
```

A GIN index is used to improve JSONB searches.

### 3. Full-Text Search

A PostgreSQL trigger automatically creates the `search_vec` value whenever a post is inserted or updated.

A GIN index is used to make full-text searches faster.

### 4. Search Ranking

The project uses `ts_rank()` to rank search results according to relevance.

### 5. Performance Testing

`EXPLAIN ANALYZE` is used to examine the query execution plan and verify:

* GIN index usage
* Partition pruning
* The partition accessed by PostgreSQL

## Sample Search

The project can search for posts containing:

```text
postgres AND indexing
```

## Files

```text
.
├── blog_backend.sql
└── README.md
```

## How to Run

1. Create a PostgreSQL database.
2. Open `blog_backend.sql`.
3. Run the SQL commands in order.
4. Check the inserted posts.
5. Run the JSONB and full-text search queries.
6. Run `EXPLAIN ANALYZE` to inspect query performance.

## Technologies

* PostgreSQL
* SQL
* PL/pgSQL
* JSONB
* GIN Indexes
* Full-Text Search
* Table Partitioning

## Learning Objective

The purpose of this project is to understand how PostgreSQL can combine flexible JSONB data, full-text search, indexing, triggers, and partitioning to build a scalable blog backend.
