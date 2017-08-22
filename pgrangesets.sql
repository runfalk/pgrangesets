-- pgrangesets
--
-- This is a collection of types and functions to simplify working with arrays
-- of ranges, as if they were ranges. The goal is to implement all range related
-- functions and operators that makes sense. Apart from functions the extension
-- also introduces more strict domains of the range arrays that behaves like
-- sets.


-- This is a utility function to help with merging a set of ranges into the
-- smallest possible range that can fit all ranges within the set.
CREATE AGGREGATE range_merge_agg(span anyrange) (
    SFUNC = range_merge,
    STYPE = anyrange,
    INITCOND = 'empty'
);


-- This function reimplements the `range_merge(anyrange)` function for range
-- arrays.
CREATE OR REPLACE FUNCTION range_merge(spans daterange[])
    RETURNS daterange AS
$$
    SELECT range_merge_agg(span)
    FROM unnest(spans) AS spans(span);
$$ LANGUAGE 'sql' IMMUTABLE STRICT;
COMMENT ON FUNCTION range_merge(daterange[]) IS
    'Return the smallest range that includes all the ranges in the given array';


CREATE OR REPLACE FUNCTION contains(a daterange[], b daterange)
    RETURNS boolean AS
$$
    SELECT coalesce(
        (SELECT true FROM unnest(a) AS spans(span) WHERE span @> b LIMIT 1),
        false
    );
$$ LANGUAGE 'sql' IMMUTABLE STRICT;
COMMENT ON FUNCTION range_merge(daterange[]) IS 'true if a contains all of b';


CREATE OR REPLACE FUNCTION contains(a daterange[], b date)
    RETURNS boolean AS
$$
    SELECT coalesce(
        (SELECT true FROM unnest(a) AS spans(span) WHERE span @> b LIMIT 1),
        false
    );
$$ LANGUAGE 'sql' IMMUTABLE STRICT;
COMMENT ON FUNCTION range_merge(daterange[]) IS 'true if a contains all of b';


CREATE OR REPLACE FUNCTION within(a date, b daterange[])
    RETURNS boolean AS
$$
    SELECT contains(b, a);
$$ LANGUAGE 'sql' IMMUTABLE STRICT;
