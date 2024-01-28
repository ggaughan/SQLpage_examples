SELECT 'shell' AS component,
    '/htmx.min.js' as javascript,
    '/sqlpage-htmx.js' as javascript  -- can run before htmx/sqlpage or after
;

SELECT 'text' AS component,
    'Efficient Pagination' as title,
    'by [Greg Gaughan](https://www.wordloosed.com) for [SQLPage](https://sql.ophir.dev/)' as contents_md
;

SELECT 'card' AS component, 1 as columns;
SELECT 
    'arrows-exchange' as icon,
    'A lazy-loaded table, sorted by Name, efficiently paginated with any number of rows' as title,
    '/table-sample.sql?_sqlpage_embed' as embed
;
