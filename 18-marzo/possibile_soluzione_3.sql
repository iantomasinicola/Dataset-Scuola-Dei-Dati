-- =============================================================
-- SOLUZIONE: INNER JOIN con subquery UNION
-- Vincolo: SENZA creare nuovi indici
-- =============================================================
-- QUERY ORIGINALE:
--   SELECT *
--   FROM Fatture
--   WHERE DataFattura = '2020-08-12'
--      OR DataFattura = (SELECT MAX(DataArrivoEffettiva) FROM Fatture)
--
-- PIANO ORIGINALE (OR):
--   Merge Join Concatenation + Stream Aggregate (dedup)
--   Branch 1: Index Seek + Key Lookup                     -> 0.007
--   Branch 2: CI Scan 90.300 righe per MAX + Seek + KL    -> 0.578
--   + Merge Join + Stream Aggregate                       -> 0.006
--   Costo totale: 0.590
-- =============================================================

-- Riscrittura: INNER JOIN con UNION per produrre le date target
-- 1) La UNION genera le 2 date distinte (dedup implicita)
-- 2) Il Nested Loops esegue 2 Index Seek su IX_Fatture_DataFattura
-- 3) Key Lookup su PkFattura per le colonne rimanenti
SELECT f.*
FROM Fatture f
INNER JOIN (
    SELECT CAST('2020-08-12' AS date) AS dt
    UNION
    SELECT MAX(DataArrivoEffettiva) FROM Fatture
) dates ON f.DataFattura = dates.dt;

-- =============================================================
-- PIANO OTTIMIZZATO (INNER JOIN + UNION):
--   UNION (Merge Join):
--     Constant Scan '2020-08-12'                          -> ~0
--     Stream Aggregate MAX -> CI Scan 90.300 righe        -> 0.572
--   Nested Loops: per ogni data -> Index Seek su DataFattura
--     + Key Lookup su PkFattura                           -> 0.007
--   Costo totale: 0.584  (-1% vs originale)
--
-- VANTAGGI STRUTTURALI RISPETTO ALL'ORIGINALE:
--   - Eliminato il Merge Join Concatenation + Stream Aggregate
--     (la dedup e' gestita dalla UNION, non da un operatore extra)
--   - Piano piu' lineare: UNION -> Nested Loops -> Seek -> Lookup
--   - La UNION produce esattamente le date distinte necessarie,
--     poi il JOIN fa 2 seek puntuali sull'indice DataFattura
--   - Pattern piu' estensibile (facile aggiungere altre date)
--
-- LIMITE:
--   Il CI Scan per MAX(DataArrivoEffettiva) resta a 0.517 (88%).
--   Senza un indice su DataArrivoEffettiva, il motore deve
--   leggere tutte le 90.300 righe del clustered index.
--   Con un indice dedicato il costo scenderebbe a 0.022 (-96%).
-- =============================================================
