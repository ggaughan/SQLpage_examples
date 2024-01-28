/*
An example of a paginated table using a new `table-paged` component.

Important parts:

    * the order-by columns are referenced in several places so changing them needs to be done in all those places, for example:
        * we return a `_sqlpage_order_key` column with a json array comprising the order-by columns. This is used to pass parameters to the Prev/Next butttons via 'hx-include'
        * we build `qpl` and `qph` row value parameters from the order-by columns
        * `qpl` and `qph` are then used as row comparisons against the order-by columns
        * we order by the results (of course) both asc and desc
    * we assume the order-by columns are supported by a database index (or at least by the first columns of one), otherwise things could get slow with large data
    * `tnext` and `tprev` need to have the same columns (though not all of the order-by columns need to be in there, except as part of the `_sqlpage_order_key`)
    * 2 javascript files are needed (so need to be loaded via the `shell` component):
        `htmx.min.js` (from https://htmx.org/)
        `sqlpage-htmx.js`
*/

SET page_size = 10;

/* define our order-by low and high values i.e. for [name, sample_id] */
SET first_values = '["", -99999999]';
SET last_values = '["󴈿󴈿󴈿󴈿󴈿󴈿󴈿󴈿", 99999999]';  /* U+F423F = &#999999; */

SET page_next_low = json(coalesce(nullif($page_next, ''), $first_values));
SET page_next_high = json(coalesce(nullif($page_next, ''), $last_values));

SELECT
    'table-paged' as component,
    sqlpage.random_string(3) as table_id,
    sqlpage.url_encode($last_values) as page_last  -- we don't need a page_first: the default of null will do that
;

WITH
    qpl AS (SELECT
        json_extract($page_next_low,'$[0]') as name,
        json_extract($page_next_low,'$[1]') as sample_id
    ),
    qph AS (SELECT 
        json_extract($page_next_high,'$[0]') as name,
        json_extract($page_next_high,'$[1]') as sample_id
    ),
    tnext AS (SELECT
        name, sample_id, note, size,
        json_array(name,sample_id) as _sqlpage_order_key  /* used for Prev parameter */
    FROM sample
    WHERE
        $page_rev is null and
        (name,sample_id) > (select name,sample_id from qpl LIMIT 1)
    ORDER BY
        name asc,sample_id asc
    LIMIT $page_size
    ),
    tprev AS (select 
        name, sample_id, note, size,
        json_array(name,sample_id) as _sqlpage_order_key  /* used for Next parameter */
    FROM sample
    WHERE
        $page_rev=1 and
        (name,sample_id) < (select name,sample_id from qph LIMIT 1)
    ORDER BY
        name desc,sample_id desc
    LIMIT $page_size
    )

    SELECT * FROM tprev
    UNION
    SELECT * FROM tnext 
    ORDER BY
        name asc,sample_id asc
    LIMIT $page_size
;
