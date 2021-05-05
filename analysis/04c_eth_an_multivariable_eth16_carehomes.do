/*==============================================================================
DO FILE NAME:			04c_eth_an_multivariable_eth16_carehomes
PROJECT:				Ethnicity 3rd wave
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					4 May 2021				
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to $Tabfigdir
						complete case analysis	
==============================================================================*/


global outcomes "tested positivetest hes icu onscoviddeath ons_noncoviddeath onsdeath"
sysdir set PLUS ./analysis/adofiles
adopath + ./analysis/adofiles
sysdir



* Open a log file
cap log close
macro drop hr
log using ./logs/04a_eth_an_multivariable_eth16, replace t 

cap file close tablecontent
file open tablecontent using ./output/table2_eth16.txt, write text replace
file write tablecontent ("Table 2: Association between ethnicity in 16 categories and COVID-19 outcomes - in care homes") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh siz")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _tab _n



foreach i of global outcomes {
use ./output/analysis_dataset_STSET_`i'.dta, clear
keep if carehome==1
safetab ethnicity_16 `i', missing row
} //end outcomes

foreach i of global outcomes {
	di "`i'"
	
* Open Stata dataset
use ./output/analysis_dataset_STSET_`i'.dta, clear
keep if carehome==1


/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.ethnicity_16, strata(stp) nolog
estimates save ./output/model/crude_`i'_eth16, replace 
eststo model1
parmest, label eform format(estimate p lb ub) saving(./output/model/crude_`i'_eth16, replace) idstr(crude_`i'_eth16) 
local hr "`hr' ./output/model/crude_`i'_eth16 "


/* Multivariable models */ 
*Age and gender
stcox i.ethnicity_16 i.male age1 age2 age3, strata(stp) nolog
estimates save ./output/model/model0_`i'_eth16, replace 
eststo model2

parmest, label eform format(estimate p lb ub) saving(./output/model/model0_`i'_eth16, replace) idstr(model0_`i'_eth16)
local hr "`hr' ./output/model/model0_`i'_eth16 "
 

* Age, Gender, IMD

stcox i.ethnicity_16 i.male age1 age2 age3 i.imd, strata(stp) nolog
if _rc==0{
estimates
estimates save ./output/model/model1_`i'_eth16, replace 
eststo model3

parmest, label eform format(estimate p lb ub) saving(./output/model/model1_`i'_eth16, replace) idstr(model1_`i'_eth16) 
local hr "`hr' ./output/model/model1_`i'_eth16 "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"

* Age, Gender, IMD and Comorbidities 
stcox i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
										i.bmicat_sa	i.hba1ccat			///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension i.bp_cat	 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis, strata(stp) nolog		
if _rc==0{
estimates
estimates save ./output/model/model2_`i'_eth16, replace 
eststo model4

parmest, label eform format(estimate p lb ub) saving(./output/model/model2_`i'_eth16, replace) idstr(model2_`i'_eth16) 
local hr "`hr' ./output/model/model2_`i'_eth16 "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"

										
* Age, Gender, IMD and Comorbidities  and household size 
stcox i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
										i.bmicat_sa	i.hba1ccat			///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension i.bp_cat	 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis			///
										i.hh_total_cat, strata(stp) nolog		
estimates save ./output/model/model3_`i'_eth16, replace
eststo model5

parmest, label eform format(estimate p lb ub) saving(./output/model/model3_`i'_eth16, replace) idstr(model3_`i'_eth16) 
local hr "`hr' ./output/model/model3_`i'_eth16 "



/* Estout================================================================*/ 
esttab model1 model2 model3 model4 model5 using ./output/estout_table2_eth16_carehomes.txt, b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
eststo clear

										
/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("`i'") _n

* eth16 labelled columns

local lab1: label ethnicity_16 1
local lab2: label ethnicity_16 2
local lab3: label ethnicity_16 3
local lab4: label ethnicity_16 4
local lab5: label ethnicity_16 5
local lab6: label ethnicity_16 6
local lab7: label ethnicity_16 7
local lab8: label ethnicity_16 8
local lab9: label ethnicity_16 9
local lab10: label ethnicity_16 10
local lab11: label ethnicity_16 11
local lab12: label ethnicity_16 12
local lab13: label ethnicity_16 13
local lab14: label ethnicity_16 14
local lab15: label ethnicity_16 15
local lab16: label ethnicity_16 16
local lab17: label ethnicity_16 17

/* counts */
 
* First row, eth16 = 1 (White British) reference cat
	qui safecount if ethnicity_16==1
	local denominator = r(N)
	qui safecount if ethnicity_16 == 1 & `i' == 1
	local event = r(N)
    bysort eth16: egen total_follow_up = total(_t)
	qui su total_follow_up if ethnicity_16 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/17 {
	qui safecount if ethnicity_16==`eth'
	local denominator = r(N)
	qui safecount if ethnicity_16 == `eth' & `i' == 1
	local event = r(N)
	qui su total_follow_up if ethnicity_16 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use ./output/model/crude_`i'_eth16 
	 cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model/model0_`i'_eth16 
	 cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model/model1_`i'_eth16 
	 cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model/model2_`i'_eth16 
	 cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model/model3_`i'_eth16 
	 cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group


} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
drop idstr idstr3
tab model

*save dataset for later
outsheet using ./output/FP_multivariable_eth16_carehomes.txt, replace

* Close log file 
log close


