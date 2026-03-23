-- =============================================================
-- SOLUZIONE: Ottimizzazione GROUP BY YEAR(DataFattura)
-- =============================================================
-- PROBLEMA ORIGINALE:
--   SELECT YEAR(DataFattura) AS Anno, COUNT(*)
--   FROM dbo.Fatture
--   GROUP BY YEAR(DataFattura);
--
-- Piano originale:
--   Index Scan (unordered) -> Compute Scalar YEAR() -> Hash Match Aggregate
--   - Hash Match su 90.300 righe: costo 0.62 (74% del totale)
--   - Memory Grant: 1024 KB (hash table)
--   - Costo totale: 0.840
--
-- CAUSA: YEAR() rompe l'ordinamento dell'indice, l'optimizer
-- non sa che YEAR(DataFattura) preserva l'ordine di DataFattura.
-- Risultato: Hash Match Aggregate (costoso) invece di Stream Aggregate.
-- =============================================================

-- PREREQUISITO: indice IX_Fatture_DataFattura gia' esistente.
-- Se mancante, crearlo:
-- CREATE NONCLUSTERED INDEX IX_Fatture_DataFattura
--     ON dbo.Fatture (DataFattura);

-- Query ottimizzata: aggregazione a due livelli
-- 1) GROUP BY DataFattura  -> sfrutta l'Ordered Index Scan + Stream Aggregate
--    (90.300 righe -> 208 date distinte, senza Sort ne' Hash)
-- 2) GROUP BY YEAR()       -> Sort + Stream Aggregate su sole 208 righe
SELECT YEAR(DataFattura) AS Anno,
       SUM(cnt)          AS NumFatture
FROM (
    SELECT DataFattura, COUNT(*) AS cnt
    FROM   dbo.Fatture
    GROUP  BY DataFattura
) sub
GROUP BY YEAR(DataFattura);

-- =============================================================
-- CONFRONTO PIANI DI ESECUZIONE STIMATI:
--
-- ORIGINALE:
--   Index Scan (unordered, 90.300 righe)
--     -> Compute Scalar YEAR() su 90.300 righe
--       -> Hash Match Aggregate (90.300 righe, hash table)
--   Costo totale:  0.840
--   Memory Grant:  1.024 KB
--   Operatore piu' costoso: Hash Match (0.621, 74%)
--
-- OTTIMIZZATA:
--   Index Scan (ORDERED FORWARD, 90.300 righe)
--     -> Stream Aggregate GROUP BY DataFattura (90.300 -> 208 righe)
--       -> Compute Scalar YEAR() su 208 righe (non 90.300!)
--         -> Sort su 208 righe (trascurabile)
--           -> Stream Aggregate GROUP BY YEAR (208 -> ~10 righe)
--   Costo totale:  0.278  (-67%)
--   Memory Grant:  560 KB (-45%)
--   Operatore piu' costoso: Index Scan (0.210, inevitabile)
--
-- RIEPILOGO MIGLIORAMENTI:
--   Metrica              Originale   Ottimizzata   Delta
--   ---------------      ---------   -----------   ------
--   Costo totale         0.840       0.278         -67%
--   Memory Grant         1.024 KB    560 KB        -45%
--   Hash Match           SI (90K)    NO            eliminato
--   Sort                 NO          SI (208 righe) trascurabile
--   Stream Aggregate     NO          SI            piu' efficiente
--   YEAR() calcolato su  90.300      208 righe     -99.8%
--   Ordered Scan         NO          SI            sfrutta indice
-- =============================================================
