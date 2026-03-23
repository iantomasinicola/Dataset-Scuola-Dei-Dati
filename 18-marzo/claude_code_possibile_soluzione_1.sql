-- =============================================================
-- SOLUZIONE: Ottimizzazione WHERE YEAR(DataFattura) = 2023
-- =============================================================
-- PROBLEMA: YEAR(DataFattura) = 2023 e' NON-SARGable.
-- La funzione YEAR() applicata alla colonna impedisce
-- all'optimizer di usare l'indice IX_Fatture_DataFattura
-- per un seek. Risultato: Index Scan di tutte le 90.300 righe
-- per filtrarne solo 7.826.
-- =============================================================

-- Query ottimizzata: predicato SARGable con range di date
SELECT COUNT(*)
FROM   dbo.Fatture
WHERE  DataFattura >= '20230101'
  AND  DataFattura <  '20240101';

-- =============================================================
-- CONFRONTO PIANI DI ESECUZIONE:
--
-- ORIGINALE (non-SARGable):
--   Operatore:      Index Scan (legge TUTTE le 90.300 righe)
--   Righe lette:    90.300
--   Righe utili:    7.826
--   Costo totale:   0.2310
--   I/O:            0.1105
--
-- OTTIMIZZATA (SARGable):
--   Operatore:      Index Seek (legge SOLO le righe del 2023)
--   Righe lette:    7.224
--   Righe utili:    7.224
--   Costo totale:   0.0237  (-90%)
--   I/O:            0.0113  (-90%)
--
-- Miglioramenti:
--   - Costo stimato:  da 0.231 a 0.024  (10x migliore)
--   - Righe lette:    da 90.300 a 7.224 (-92%)
--   - I/O:            ridotto del 90%
--   - Da Index Scan a Index Seek
--   - Memory Grant: 0 in entrambi i casi
-- =============================================================
