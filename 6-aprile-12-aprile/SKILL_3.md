---
name: profiling
description: Esegui un profiling di un dataset CSV.
---

## 1. Identifica il dataset
- Cerca tutti i file CSV, TSV e Parquet nella cartella data/
- Se ce n'è uno solo, usalo
- Se ce ne sono più di uno, elenca i file trovati con
  nome e dimensione, e chiedi all'utente quale analizzare
- Se non ce n'è nessuno, avvisa e chiedi il percorso

## 2. Procedi con l'analisi
- Tipi di dato per ogni colonna (dtype)
- Memoria occupata dal DataFrame
- Prime 5 righe (head) come anteprima

