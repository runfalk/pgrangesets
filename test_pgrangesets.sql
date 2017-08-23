\set QUIET on
\t on

BEGIN;

CREATE FUNCTION test(name varchar, VARIADIC test_results boolean[])
    RETURNS varchar AS
$$
    SELECT
        rpad(name || ' ', 60, '.')
        || ' '
        || (CASE bool_and(status) WHEN true THEN 'ok' ELSE 'error' END)
    FROM unnest(test_results) AS results(status);
$$ LANGUAGE 'sql' IMMUTABLE STRICT;

-- Include pgrangesets.sql
\ir pgrangesets.sql

-- Restore
\set QUIET off
\echo

-- Run tests
SELECT test(
    'Test range_merge',
    (range_merge('{}'::daterange[]) = 'empty'::daterange),
    (range_merge(ARRAY['[2000-01-01,2000-01-30)']::daterange[]) = '[2000-01-01,2000-01-30)'::daterange),
    (range_merge(ARRAY['[2000-01-01,2000-01-30)', '[2001-01-01,2001-01-30)']::daterange[]) = '[2000-01-01,2001-01-30)'::daterange)
);
