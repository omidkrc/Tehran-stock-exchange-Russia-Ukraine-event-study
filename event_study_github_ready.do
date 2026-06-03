/****************************************************************************************
Silent Markets in a Turbulent World: Tehran Stock Exchange and the Russia-Ukraine War
GitHub-ready Stata replication / data-preparation script

Author: Omid Karami
Repository purpose: Reproduce the data preparation and grouping steps used in the thesis.

How to use
----------
1. Put this file in the repository folder under: code/event_study_github_ready.do
2. Recommended repository structure:

   project-root/
   ├── code/
   │   └── event_study_github_ready.do
   ├── data/
   │   ├── raw/            optional Excel files, if you want to rebuild from raw data
   │   └── processed/      cleaned Stata dataset(s)
   └── output/             generated files/logs

3. By default, this script starts from a cleaned Stata dataset. The cleaned dataset should
   contain at least these variables:
       date symbol industry closing_return market_cap amihud

   Recommended file name:
       data/processed/analysis_data.dta

4. To rebuild from the original raw Excel files, set the local macro build_from_raw to 1
   below and place the Excel files in data/raw/.

Notes
-----
- All paths are relative; no personal computer paths are used.
- Persian industry names are preserved in filters because they are part of the dataset.
- The script creates group-level files for the whole market, market-cap tertiles,
  liquidity tertiles, and industries.
****************************************************************************************/

version 17.0
clear all
set more off
set linesize 255

* ------------------------------------------------------------------------------
* 0. Project paths and switches
* ------------------------------------------------------------------------------

* Run this do-file from the repository root. If you run it from another location,
* change this local macro to the full path of the repository root.
local project_root "."

local raw_dir       "`project_root'/data/raw"
local processed_dir "`project_root'/data/processed"
local output_dir    "`project_root'/output"
local log_dir       "`output_dir'/logs"

capture mkdir "`output_dir'"
capture mkdir "`log_dir'"
capture mkdir "`processed_dir'"

capture log close _all
log using "`log_dir'/event_study_replication.log", replace text

* Set to 1 only if the original raw Excel files are available in data/raw/.
local build_from_raw 0

* Main cleaned dataset. If your dataset has a different name, edit this line.
local analysis_data "`processed_dir'/analysis_data.dta"

* Fallback names often used during thesis work.
if !fileexists("`analysis_data'") {
    if fileexists("`processed_dir'/new_dta.dta") {
        local analysis_data "`processed_dir'/new_dta.dta"
    }
    else if fileexists("`project_root'/data/new_dta.dta") {
        local analysis_data "`project_root'/data/new_dta.dta"
    }
}

* ------------------------------------------------------------------------------
* 1. Optional: rebuild the combined raw panel from Excel files
* ------------------------------------------------------------------------------

if `build_from_raw' == 1 {

    * Excel files from the original thesis workflow. Keep only the files that are
    * actually included in data/raw/. Missing files are skipped with a message.
    local raw_files ///
        "amlak.xlsx" ///
        "arze_bargh.xlsx" ///
        "bank.xlsx" ///
        "bime.xlsx" ///
        "chand_reshtei.xlsx" ///
        "choob.xlsx" ///
        "dabaghi.xlsx" ///
        "daroo.xlsx" ///
        "dastgah_barghi.xlsx" ///
        "dastgah_ertebati.xlsx" ///
        "enteshar.xlsx" ///
        "estekhraj_naft_gaz.xlsx" ///
        "etelat.xlsx" ///
        "felezat_asasi.xlsx" ///
        "ghand_shekar.xlsx" ///
        "ghazayi.xlsx" ///
        "haml_naghl_abi.xlsx" ///
        "hamlonaghl_anbardari.xlsx" ///
        "kaghazi.xlsx" ///
        "kane_felezi.xlsx" ///
        "kashi.xlsx" ///
        "khadamat_mohandesi.xlsx" ///
        "khodro.xlsx" ///
        "khorde_forooshi.xlsx" ///
        "lastik.xlsx" ///
        "maadan.xlsx" ///
        "mahsoolat_felezi.xlsx" ///
        "mahsoolat_gheyrfelezi.xlsx" ///
        "mali_komaki.xlsx" ///
        "mansoojat.xlsx" ///
        "mokhaberat.xlsx" ///
        "nafti.xlsx" ///
        "peymankari_sanati.xlsx" ///
        "rayane.xlsx" ///
        "restooran.xlsx" ///
        "sarmaye.xlsx" ///
        "sayer_mali.xlsx" ///
        "shimiyayi.xlsx" ///
        "siman.xlsx" ///
        "tajhizat.xlsx" ///
        "tolid_computer.xlsx" ///
        "zeraat.xlsx" ///
        "zoghal.xlsx"

    tempfile combined_raw
    local first_file 1

    foreach f of local raw_files {
        local this_file "`raw_dir'/`f'"
        if fileexists("`this_file'") {
            di as text "Importing `this_file'"
            import excel using "`this_file'", clear
            if `first_file' == 1 {
                save `combined_raw', replace
                local first_file 0
            }
            else {
                append using `combined_raw'
                save `combined_raw', replace
            }
        }
        else {
            di as result "Skipped missing raw file: `this_file'"
        }
    }

    if `first_file' == 1 {
        di as error "No raw Excel files were found. Put them in data/raw/ or set build_from_raw to 0."
        exit 601
    }

    use `combined_raw', clear

    * Column names reflect the structure of the original Excel exports.
    capture drop A D J K L
    rename B name
    rename C symbol
    rename E date
    rename F first_price
    rename G last_price
    rename H closing_price
    rename I Volume
    rename M Number_of_shares
    rename N industry

    drop in 1

    destring date first_price last_price closing_price Volume Number_of_shares, replace force

    replace name   = subinstr(name,   "-ت", "", .)
    replace symbol = subinstr(symbol, "-ت", "", .)

    gen market_cap = closing_price * Number_of_shares * 10^-6
    replace Volume = Volume * 10^-6

    drop if name == "<name>"
    drop if name == "<nemad>"

    sort industry symbol date

    * Remove observations with problematic symbols from the original cleaning step.
    drop if inlist(name, "PELC", "OFST", "KHZZ", "HSHM", "GMEL", "BLSZ")

    gen intraday_return = (last_price - first_price) / first_price
    by industry symbol: gen closing_return = (closing_price - closing_price[_n-1]) / closing_price[_n-1]
    by industry symbol: replace closing_return = . if _n == 1

    gen amihud = abs(intraday_return) / Volume

    * Estimation and event-period coverage used in the thesis workflow.
    keep if (date >= 20201129 & date <= 20211130) | (date >= 20220112 & date <= 20220418)

    save "`processed_dir'/analysis_data.dta", replace
    local analysis_data "`processed_dir'/analysis_data.dta"
}

* ------------------------------------------------------------------------------
* 2. Load and validate the cleaned analysis dataset
* ------------------------------------------------------------------------------

if !fileexists("`analysis_data'") {
    di as error "Analysis dataset not found. Expected: `analysis_data'"
    di as error "Put a cleaned dataset in data/processed/analysis_data.dta or edit local analysis_data."
    exit 601
}

use "`analysis_data'", clear

describe

foreach v in date symbol industry closing_return market_cap amihud {
    capture confirm variable `v'
    if _rc {
        di as error "Required variable missing: `v'"
        exit 111
    }
}

* Keep the industries used in the thesis analysis.
keep if inlist(industry, ///
    "محصولات شیمیایی", ///
    "فلزات اساسی", ///
    "استخراج کانه های فلزی", ///
    "شرکت های چند رشته ای صنعتی", ///
    "سرمایه گذاری ها", ///
    "بانک ها و موسسات اعتباری", ///
    "فرآورده های نفتی، کک و سوخت هسته ای") ///
    | inlist(industry, ///
    "بیمه و صندوق بازنشستگی به جز تامین اجتماعی", ///
    "عرضه برق، گاز، بخار و آب گرم", ///
    "مواد و محصولات دارویی", ///
    "فعالیت های کمکی به نهادهای مالی واسط", ///
    "محصولات غذایی و آشامیدنی به جز قند و شکر", ///
    "سیمان، آهک و گچ") ///
    | inlist(industry, ///
    "مخابرات", ///
    "رایانه", ///
    "خودرو و ساخت قطعات", ///
    "خدمات فنی مهندسی", ///
    "حمل و نقل، انبارداری و ارتباطات", ///
    "انبوه سازی، املاک و مستغلات", ///
    "زراعت و خدمات وابسته")

* Remove duplicate firm-date rows, keeping the first observation.
sort symbol date
by symbol date: keep if _n == 1

* Save cleaned long-format analysis panel.
save "`processed_dir'/analysis_panel_long.dta", replace

* ------------------------------------------------------------------------------
* 3. Construct firm-level averages and grouping variables
* ------------------------------------------------------------------------------

use "`processed_dir'/analysis_panel_long.dta", clear

bysort symbol: egen avg_market_cap = mean(market_cap) if date >= 20201129 & date <= 20220417
bysort symbol: egen avg_amihud     = mean(amihud)     if date >= 20201129 & date <= 20220417

bysort symbol: egen firm_avg_market_cap = max(avg_market_cap)
bysort symbol: egen firm_avg_amihud     = max(avg_amihud)

drop avg_market_cap avg_amihud
rename firm_avg_market_cap avg_market_cap
rename firm_avg_amihud avg_amihud

xtile market_cap_tertile = avg_market_cap, nq(3)
xtile amihud_tertile     = avg_amihud, nq(3)

label define capgrp 1 "Small market capitalization" 2 "Medium market capitalization" 3 "Large market capitalization", replace
label values market_cap_tertile capgrp

label define liqgrp 1 "High liquidity / low Amihud" 2 "Medium liquidity" 3 "Low liquidity / high Amihud", replace
label values amihud_tertile liqgrp

save "`processed_dir'/analysis_panel_with_groups.dta", replace

* ------------------------------------------------------------------------------
* 4. Export wide return matrices for whole market, market-cap groups, liquidity
*    groups, and industries. These are convenient inputs for event-study routines.
* ------------------------------------------------------------------------------

capture program drop save_wide_returns
program define save_wide_returns
    syntax, OUTfile(string)

    preserve
        keep date symbol closing_return
        drop if missing(date) | missing(symbol)
        bysort date symbol: keep if _n == 1
        reshape wide closing_return, i(date) j(symbol) string

        foreach var of varlist closing_return* {
            local newname = substr("`var'", 15, .)
            capture rename `var' `newname'
        }

        save "`outfile'", replace
    restore
end

use "`processed_dir'/analysis_panel_with_groups.dta", clear

save_wide_returns, outfile("`processed_dir'/returns_whole_market_wide.dta")

forvalues g = 1/3 {
    preserve
        keep if market_cap_tertile == `g'
        save_wide_returns, outfile("`processed_dir'/returns_market_cap_tertile_`g'_wide.dta")
    restore
}

forvalues g = 1/3 {
    preserve
        keep if amihud_tertile == `g'
        save_wide_returns, outfile("`processed_dir'/returns_liquidity_tertile_`g'_wide.dta")
    restore
}

levelsof industry, local(industry_levels)
local i = 1
foreach ind of local industry_levels {
    preserve
        keep if industry == "`ind'"
        save_wide_returns, outfile("`processed_dir'/returns_industry_`i'_wide.dta")
    restore
    local ++i
}

* ------------------------------------------------------------------------------
* 5. Summary tables for documentation
* ------------------------------------------------------------------------------

use "`processed_dir'/analysis_panel_with_groups.dta", clear

preserve
    bysort symbol: keep if _n == 1
    tabulate industry
    tabulate market_cap_tertile
    tabulate amihud_tertile
restore

summarize closing_return market_cap amihud avg_market_cap avg_amihud

log close

di as result "Done. Outputs were saved in: `processed_dir'"
