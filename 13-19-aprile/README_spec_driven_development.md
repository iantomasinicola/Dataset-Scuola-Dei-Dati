# Demo Spec-Driven Development — Corso Claude Code per Data Analyst

Questo progetto dimostra il workflow **Spec-Driven Development (SDD)**
applicato all'analisi dati. È il materiale per la sezione finale del corso.

## Idea chiave

> Tu scrivi il **cosa** e il **perché**. Claude scrive il **come**.

Invece di chiedere a Claude "analizza i dati" e vedere cosa succede, scrivi
prima una specifica chiara di cosa vuoi ottenere. Poi Claude la progetta,
te la mostra, e solo dopo la tua approvazione la implementa.

## Le 3 fasi del workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. SPECIFICA   │ ──→ │    2. DESIGN    │ ──→ │ 3. IMPLEMENTA  │
│   (la scrivi    │     │  (Claude + tu   │     │   (Claude la    │
│    tu)          │     │   la progettate)│     │    esegue)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
      ↑                       ↑                       │
      │       revisione       │      approvazione      │
      └───────────────────────┴────────────────────────┘
```

**Fase 1 — Specifica**: tu scrivi un documento che descrive l'obiettivo,
i dati di input, gli output attesi, e i criteri di accettazione. Nessun
codice, nessun tecnicismo — solo il problema di business.

**Fase 2 — Design**: dai la spec a Claude (in Plan Mode) e chiedi di
progettare la soluzione. Claude produce un design document con i passi
tecnici. Tu rivedi e approvi.

**Fase 3 — Implementazione**: Claude scrive il codice seguendo il design
approvato. Tu rivedi il risultato finale, non ogni singola riga.

## Come fare la demo

### Setup iniziale
```bash
cd demo-sdd/
python -m venv .venv
.venv/bin/pip install pandas matplotlib seaborn    # Linux/Mac/Git Bash
# oppure: .venv\Scripts\pip install pandas matplotlib seaborn  # Windows CMD
claude
```

### Demo 1 — Mostra il workflow completo

Dentro Claude Code:

```
# Passo 1: mostra le spec disponibili
> ls specs/

# Passo 2: implementa la prima spec
> /implement-spec 01_profiling

# Claude legge la spec, produce il design, chiede approvazione
# Tu approvi, Claude implementa, verifica i criteri

# Passo 3: verifica il risultato
> /check-spec 01_profiling

# Passo 4: passa alla spec successiva
> /implement-spec 02_pulizia

# E così via...
```

### Demo 2 — Crea una spec da zero

```
> /new-spec

# Claude ti guida con domande:
# - Cosa vuoi scoprire?
# - Quali dati usiamo?
# - Chi legge il risultato?
# - Che output vuoi?

# Alla fine produce una spec strutturata in specs/
```

### Demo 3 — Mostra cosa succede SENZA spec

```
> /clear
> analizza i dati

# Claude fa qualcosa di generico e poco utile.
# Poi:

> /clear
> /implement-spec 03_report_vendite

# Claude segue la spec, produce esattamente quello che serve.
# La differenza è evidente.
```

## Struttura del progetto

```
demo-sdd/
├── CLAUDE.md                          ← Contesto progetto + regole
├── README.md                          ← Questo file
│
├── specs/                             ← Le specifiche (scritte dall'analyst)
│   ├── 01_profiling.md                ← Fase 1: esplorazione dati
│   ├── 02_pulizia.md                  ← Fase 2: pulizia pipeline
│   └── 03_report_vendite.md           ← Fase 3: report finale
│
├── design/                            ← Design documents (generati con Claude)
│   └── (vuoto — verrà popolato)
│
├── data/                              ← Dati grezzi (NON MODIFICARE)
│   ├── vendite_2025.csv               ← 50 transazioni retail
│   └── clienti.csv                    ← Anagrafica 11 clienti
│
├── output/                            ← Report e risultati
│   └── grafici/                       ← Grafici generati
│
├── scripts/                           ← Script Python riutilizzabili
│   └── (vuoto — verrà popolato)
│
└── .claude/
    ├── settings.json                  ← Permessi (deny rm, pip install, edit data/)
    └── skills/
        ├── implement-spec/SKILL.md    ← /implement-spec — esegue una spec
        ├── new-spec/SKILL.md          ← /new-spec — crea una nuova spec
        └── check-spec/SKILL.md        ← /check-spec — verifica i criteri
```

## Le skill disponibili

| Comando           | Cosa fa                                         |
|-------------------|------------------------------------------------|
| `/implement-spec` | Legge una spec, produce il design, implementa   |
| `/new-spec`       | Guida l'analyst a scrivere una nuova spec       |
| `/check-spec`     | Verifica i criteri di accettazione              |

## Le protezioni configurate

Nel file `.claude/settings.json` sono configurati questi blocchi:

| Azione                  | Permesso  | Motivo                               |
|------------------------|-----------|--------------------------------------|
| `rm`, `del`, `rmdir`   | ❌ Deny   | Non cancellare mai nulla             |
| `pip install`          | ❌ Deny   | Non installare senza permesso        |
| `Edit(data/**)`        | ❌ Deny   | I dati grezzi sono sacri             |

## Problemi intenzionali nel dataset

Il file `vendite_2025.csv` contiene problemi di qualità per le esercitazioni:

- **3 valori mancanti** in `cliente_id` (righe 1006, 1021, 1035)
- **1 valore mancante** in `totale` (riga 1032)
- **1 duplicato esatto** (righe 1023 e 1024)
- **1 reso** con quantità negativa (riga 1046)

## Perché SDD funziona meglio per gli analyst

1. **Ti forza a pensare prima** — "cosa voglio sapere?" viene prima di "come lo calcolo"
2. **Claude ha tutto il contesto** — in un documento strutturato, non sparso in 20 messaggi
3. **Errori facili da correggere** — se il risultato è sbagliato, torni alla spec
4. **Documentazione gratis** — le spec restano come documentazione del progetto
5. **Riproducibile** — la stessa spec può essere ri-eseguita su dati nuovi
