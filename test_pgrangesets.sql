\set QUIET on
\t on

BEGIN;

CREATE FUNCTION test(name varchar, value boolean)
    RETURNS varchar AS
$$
DECLARE
    text_status varchar;
BEGIN
    CASE value 
        WHEN true THEN
            text_status := 'ok';
        ELSE 
            text_status := 'error';
    END CASE;
    RETURN rpad(name || ' ', 60, '.') || ' ' || text_status;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-- Include pgrangesets.sql
\ir pgrangesets.sql

-- Restore
\set QUIET off
\echo

-- Run tests
SELECT test(
    'Test range_merge',
    (
        WITH tests(status) AS (VALUES
            (range_merge('{}'::daterange[]) = 'empty'::daterange),
            (range_merge(ARRAY['[2000-01-01,2000-01-30)']::daterange[]) = '[2000-01-01,2000-01-30)'::daterange),
            (range_merge(ARRAY['[2000-01-01,2000-01-30)', '[2001-01-01,2001-01-30)']::daterange[]) = '[2000-01-01,2001-01-30)'::daterange)
        )
        SELECT bool_and(status) FROM tests
    )
);
