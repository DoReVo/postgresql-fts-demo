-- Create the table
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    title TEXT NOT null default '',
    content TEXT NOT null default '',
    tags TEXT[] NOT null default '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT null default now()
);

-- 1. basic - stemming
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('english', 'advancement');

-- 2. Phrase matching
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ phraseto_tsquery('advance technology');

-- 3. Prefix matching
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('english', 'bridge:*');

-- 3.1 Prefix matching
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('english', 'crew:*');

-- 4. Ranking search results
SELECT title, content,
       ts_rank(to_tsvector('english', title || ' ' || content), to_tsquery('english', 'crew')) AS rank
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('english', 'crew')
ORDER BY rank DESC;

-- 5. Searching in specific columns
SELECT *
FROM reports
WHERE to_tsvector(title) @@ to_tsquery('english', 'crew')
   and to_tsvector(content) @@ to_tsquery('english', 'log');
  
-- 6. Using different language configurations
SELECT *
FROM reports
WHERE to_tsvector('spanish', title || ' ' || content) @@ to_tsquery('spanish', 'tecnología');

-- 7. Searching within arrays (tags)
SELECT *
FROM reports
WHERE EXISTS (
    SELECT 1
    FROM unnest(tags) tag
    WHERE to_tsvector('english', tag) @@ to_tsquery('crew')
);

-- 8. Highlighting search results
SELECT *,
       ts_headline('english', content, to_tsquery('english', 'technology'),
                   'StartSel = <mark>, StopSel = </mark>, MaxWords=35, MinWords=15, ShortWord=3, HighlightAll=FALSE')
FROM reports
WHERE to_tsvector(content) @@ to_tsquery('technology');

-- 9. Complex query with multiple terms and operators
SELECT *
FROM reports
WHERE to_tsvector(content) @@ 
      to_tsquery('virus & (malware | bacteria) & fakenews');
     
-- 9.1 Complex query with multiple terms and operators
SELECT *
FROM reports
WHERE to_tsvector(content) @@ 
      to_tsquery('virus & (malware | bacteria) & !fakenews');

-- 10. plainto_tsquery
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ plainto_tsquery('english', 'advance technology');

-- 11. websearch_to_tsquery - technology but not ancient
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ websearch_to_tsquery('technology -ancient');

-- 11.1 context of messhall crew, but cooks
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ websearch_to_tsquery('"messhall crew" cooks');

-- 11.2 context of messhall crew, but police
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ websearch_to_tsquery('"messhall crew" polices or soldier');

-- 11.3 context of messhall crew, but not police or solders
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ websearch_to_tsquery('"messhall crew" -"polices" -"soldier"');


-- 12. Synonym
SELECT *
FROM reports
WHERE to_tsvector('english', title || ' ' || content) @@ apply_all_synonyms(to_tsquery('english', 'technology'));



