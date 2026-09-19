-- PostgreSQL Blog Backend
-- JSONB, Full-Text Search, GIN Indexing and Partitioning


-- ============================================
-- STEP 1: CREATE A PARTITIONED POSTS TABLE
-- ============================================

CREATE TABLE posts (
  id BIGINT GENERATED ALWAYS AS IDENTITY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  search_vec TSVECTOR,
  published_at TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (published_at);

CREATE TABLE posts_2025 PARTITION OF posts
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE posts_2026 PARTITION OF posts
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');


-- ============================================
-- STEP 2: AUTO-MAINTAIN THE SEARCH VECTOR
-- ============================================

CREATE FUNCTION posts_search_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vec := to_tsvector(
    'english',
    coalesce(NEW.title, '') || ' ' || coalesce(NEW.body, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_search
BEFORE INSERT OR UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION posts_search_update();

CREATE INDEX idx_posts_search
ON posts USING GIN (search_vec);


-- ============================================
-- STEP 3: INSERT POSTS AND QUERY JSONB
-- ============================================

INSERT INTO posts (title, body, metadata, published_at) VALUES
  (
    'PostgreSQL Indexing',
    'A guide to B-tree and GIN indexes.',
    '{"tags":["postgres","performance"]}',
    '2025-03-01'
  ),
  (
    'Intro to JSONB',
    'Storing flexible data in Postgres.',
    '{"tags":["postgres","jsonb"]}',
    '2025-04-10'
  ),
  (
    'PostgreSQL Performance 2025',
    'Learning PostgreSQL performance and indexing.',
    '{"tags":["postgres","performance"]}',
    '2025-06-15'
  ),
  (
    'PostgreSQL Performance 2026',
    'New PostgreSQL optimization techniques.',
    '{"tags":["postgres","optimization"]}',
    '2026-03-20'
  );

CREATE INDEX idx_posts_meta
ON posts USING GIN (metadata);

SELECT title
FROM posts
WHERE metadata @> '{"tags":["performance"]}';


-- ============================================
-- STEP 4: RUN A FULL-TEXT SEARCH
-- ============================================

SELECT title, ts_rank(search_vec, q) AS rank
FROM posts,
     to_tsquery('english', 'postgres & indexing') q
WHERE search_vec @@ q
ORDER BY rank DESC;


-- ============================================
-- STEP 5: PROVE THE OPTIMIZATIONS WORK
-- ============================================

-- Check where the records are stored
SELECT tableoid::regclass AS partition,
       title,
       published_at
FROM posts
ORDER BY published_at;


-- EXPLAIN ANALYZE for 2025
EXPLAIN ANALYZE
SELECT title, published_at
FROM posts
WHERE published_at >= '2025-01-01'
  AND published_at < '2026-01-01';


-- EXPLAIN ANALYZE for 2026
EXPLAIN ANALYZE
SELECT title, published_at
FROM posts
WHERE published_at >= '2026-01-01'
  AND published_at < '2027-01-01';


-- EXPLAIN ANALYZE for full-text search with date filtering
EXPLAIN ANALYZE
SELECT title
FROM posts
WHERE published_at >= '2025-01-01'
  AND published_at < '2026-01-01'
  AND search_vec @@ to_tsquery('english', 'postgres');