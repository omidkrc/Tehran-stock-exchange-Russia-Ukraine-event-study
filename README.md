# Silent Markets in a Turbulent World: The Weak Response of the Tehran Stock Exchange to the Russia–Ukraine War

Event-study analysis of the Tehran Stock Exchange reaction to the Russia–Ukraine war, including a short English thesis version, Stata code, and dataset.

The thesis studies how investors in the Tehran Stock Exchange reacted to the beginning of the Russia–Ukraine war. The event date is defined as **February 26, 2022** / **7 Esfand 1400**, which corresponds to the first relevant trading date for the Iranian stock market after the start of the war.

## Thesis Overview

The Russia–Ukraine war created major disruptions in global commodity markets, increased geopolitical risk, and affected energy, agricultural, and metals markets. Since Iran is both an exporter and importer of important commodities, the war could have affected Iranian firms in different ways.

This thesis examines whether the Tehran Stock Exchange showed a statistically significant reaction to the outbreak of the war. The analysis uses an **event study** framework and focuses on abnormal returns around the event date.

The main research questions are:

1. Did the Tehran Stock Exchange experience significant abnormal returns after the beginning of the Russia–Ukraine war?
2. Did firms react differently depending on their market capitalization?
3. Did firms react differently depending on stock liquidity?
4. Did different industries show heterogeneous responses to the event?

## Methodology

The empirical method is based on an event study approach. The study calculates:

- **Abnormal Return (AR)**
- **Average Abnormal Return (AAR)**
- **Cumulative Average Abnormal Return (CAAR)**

The main event window is a seven-day window, including three trading days before and three trading days after the event date. A robustness check is also conducted by changing the estimation window.

The firms are grouped based on:

- Market capitalization
- Stock liquidity
- Industry classification

## Main Findings

The results suggest that the average abnormal return of the Iranian stock market was not strongly significant compared with evidence from many other markets. This weak reaction may be related to Iran’s relative financial isolation and the specific institutional conditions of the Iranian capital market.

The study also finds that:

- There was no strong statistically significant difference between large, medium, and small firms, although smaller firms appeared slightly more affected.
- Firms with lower liquidity showed a weaker response.
- Industry-level reactions were heterogeneous.
- Significant price reactions were mainly observed in the automobile, cement, and food and beverages sectors.
- The robustness analysis supports the stability of the main findings.

## Repository Structure

```text
.
├── README.md
├── thesis/
│   └── Karami_English_Thesis_Short.pdf
├── code/
│   └── event_study_github_ready.do
└── data/
    └── processed/
        └── analysis_data.dta
```

## Files

### `thesis/`

Contains the short English version of the thesis.

### `code/`

Contains the Stata do-file used to prepare the analysis panel, create firm groups, and generate replication outputs.

### `data/processed/`

Contains the cleaned analysis dataset used by the Stata code.

## How to Run the Stata Code

To reproduce the data preparation and grouping outputs, open Stata, set the working directory to the root folder of this repository, and run:

```stata
do code/event_study_github_ready.do
```

The code assumes that the cleaned analysis dataset is stored at:

```text
data/processed/analysis_data.dta
```

If you use a different file name or folder structure, update the `analysis_data` path near the beginning of the `.do` file.

## Data

The dataset contains firm-level daily stock return observations from the Tehran Stock Exchange and related firm characteristics used in the event-study analysis.

Main variables include:

- `date`: trading date
- `symbol`: firm ticker/symbol
- `industry`: industry classification
- `closing_return`: daily stock return
- `market_cap`: market capitalization
- `amihud`: Amihud illiquidity measure
- `market_cap_tertile`: market-capitalization group
- `amihud_tertile`: liquidity group

## Requirements

The analysis was prepared for Stata 17. The code should also work in recent versions of Stata, although minor adjustments may be required depending on the local Stata installation.

## Suggested Citation

Karami, O. (2024). *Silent Markets in a Turbulent World: The Weak Response of the Tehran Stock Exchange to the Russia–Ukraine War*. Master’s Thesis, Sharif University of Technology.

## Author

**Omid Karami**  
Master’s in Financial Economics  
Sharif University of Technology

## Notes

This repository is intended for academic and research purposes. The short thesis version is provided in English to make the research more accessible to international readers. The original thesis was written in Persian.
