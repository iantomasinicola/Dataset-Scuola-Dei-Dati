---
name: profiling
description: Esegui un profiling completo di un dataset CSV o DataFrame. Usa quando l'utente chiede di esplorare, profilare o fare un'overview dei dati, o quando chiede "com'è fatto questo dataset?", "che dati abbiamo?", "fai un check dei dati".
---

# Skill: Profiling Dataset

Quando viene invocato, segui questa procedura passo per passo.

## 1. Carica il dataset
- Identifica il file CSV nella cartella
- Caricalo con pandas
- Mostra: numero righe, numero colonne, nomi colonne

## 2. Panoramica strutturale
- Tipi di dato per ogni colonna (dtype)
- Memoria occupata dal DataFrame
- Prime 5 righe (head) come anteprima

## 3. Analisi valori mancanti
- Per ogni colonna: conteggio e percentuale di valori nulli
- Evidenzia le colonne con >5% di missing
- Suggerisci se i missing sono casuali o sistematici

## 4. Statistiche descrittive
- Per colonne **numeriche**: media, mediana, min, max, std, Q1, Q3
- Per colonne **categoriche**: valori unici, valore più frequente, distribuzione top 5
- Per colonne **data**: range temporale, eventuali gap

## 5. Anomalie e qualità
- Cerca duplicati esatti (righe identiche)
- Cerca valori negativi dove non dovrebbero esserci (es. quantità, prezzi)
- Cerca outlier usando IQR (valori oltre 1.5x il range interquartile)
- Cerca inconsistenze nei valori categorici (es. "Milano" vs "milano" vs "MILANO")

## 6. Output
- Stampa un riepilogo formattato nel terminale
- Salva un report dettagliato in `output/profiling_report.md`
- Il report deve includere una sezione "Azioni Consigliate" con le priorità di pulizia

## Note
- Usa sempre `pd.set_option('display.max_columns', None)` per mostrare tutte le colonne
- Arrotonda le percentuali a 1 decimale
- Se il file è molto grande (>100K righe), avvisa l'utente e lavora su un campione
