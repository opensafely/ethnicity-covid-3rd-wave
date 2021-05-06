/*==============================================================================
DO FILE NAME:			02a_outcomes_checks_eth16
PROJECT:				Ethnicity 3rd wave
DATE: 					4th May
AUTHOR:					R Mathur
						adapted from A Schultze 	
DESCRIPTION OF FILE:	Produce a table of baseline characteristics, by ethnicity
						Generalised to produce same columns as levels of ethnicity_16
						Output to a textfile for further formatting
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: $Tabfigdir\table1.txt 
						Log file: $Logdir\02a_eth_table1_descriptives
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)	
  
 Notes:
 Table 1 population is people who are alive on indexdate
 It does not exclude anyone who experienced any outcome prior to indexdate
 change the analysis_dataset to exlucde people with any of the following as of Feb 1st 2020:
 COVID identified in primary care
 COVID test result via  SGSS
 ICU admission for COVID-19
 

 ==============================================================================*/
global outcomes "tested positivetest hes icu onscoviddeath ons_noncoviddeath onsdeath"

* Open a log file
capture log close
log using ./logs/02a_outcomes_checks_eth16.log, replace t


 /* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	qui cou
	local overalldenom=r(N)
	
	qui sum `variable' if `variable' `condition'
	file write tablecontent (r(max)) _tab
	
	qui cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent %9.0gc (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=1/17{
	qui cou if  == `i'
	local rowdenom = r(N)
	qui cou if ethnicity_16 == `i' & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end


* Output one row of table for co-morbidities and meds

cap prog drop generaterow2
program define generaterow2
syntax, variable(varname) condition(string) 
	
	qui cou
	local overalldenom=r(N)
	
	qui cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent %9.0gc (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=1/17{
	qui cou if ethnicity_16 == `i'
	local rowdenom = r(N)
	qui cou if ethnicity_16 == `i' & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end



/* Explanatory Notes 

defines a program (SAS macro/R function equivalent), generate row
the syntax row specifies two inputs for the program: 

	a VARNAME which is your variable 
	a CONDITION which is a string of some condition you impose 
	
the program counts if variable and condition and returns the counts
column percentages are then automatically generated
this is then written to the text file 'tablecontent' 
the number followed by space, brackets, formatted pct, end bracket and then tab

the format %3.1f specifies length of 3, followed by 1 dp. 

*/ 

********************************************************************************
* Generic code to output one section (varible) within table (calls above)

cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) min(real) max(real) [missing]

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	forvalues varlevel = `min'/`max'{ 
		generaterow, variable(`variable') condition("==`varlevel'")
	}
	
	if "`missing'"!="" generaterow, variable(`variable') condition("== 12")
	


end

********************************************************************************

/* Explanatory Notes 

defines program tabulate variable 
syntax is : 

	- a VARNAME which you stick in variable 
	- a numeric minimum 
	- a numeric maximum 
	- optional missing option, default value is . 

forvalues lowest to highest of the variable, manually set for each var
run the generate row program for the level of the variable 
if there is a missing specified, then run the generate row for missing vals

*/ 

********************************************************************************
* Generic code to qui summarize a continous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 


	qui summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	forvalues i=1/12{							
	qui summarize `variable' if ethnicity_16 == `i', d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}

file write tablecontent _n

	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	
	forvalues i=1/17{
	qui summarize `variable' if ethnicity_16 == `i', d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	}
	
file write tablecontent _n
	
end


/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using ./output/table0_outcomes_eth16.txt, write text replace

file write tablecontent ("Table 0: Outcome counts by ethnic group") _n

* ethnicity_16 labelled columns

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



file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab1'")  						  _tab ///
							 ("`lab2'")  						  _tab ///
							 ("`lab3'")  						  _tab ///
							 ("`lab4'")  						  _tab ///
							 ("`lab5'")  						  _tab ///
							 ("`lab6'")  						  _tab ///							 
							 ("`lab7'")  						  _tab ///
							 ("`lab8'")  						  _tab ///
							 ("`lab9'")  						  _tab ///
							 ("`lab10'")  						  _tab ///
							 ("`lab11'")  						  _tab ///
							 ("`lab12'")  						  _tab ///
							 ("`lab13'")  						  _tab ///
							 ("`lab14'")  						  _tab ///
							 ("`lab15'")  						  _tab ///
							 ("`lab16'")  						  _tab ///
							 ("`lab17'")  						  _n
							 
/*STEP 1: NO CARE HOMES*/

use ./output/analysis_dataset.dta, clear
keep if carehome==0
							 
*Denominator
file write tablecontent ("Main population: no care homes") _n
gen byte cons=1
file write tablecontent ("N") _tab

generaterow2, variable(cons) condition("==1")
file write tablecontent _n 


*Outcomes 
foreach var of global outcomes {

file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}

*icu outcomes
local p" "any_resp_support_flag" "basic_resp_support_flag" "advanced_resp_support_flag" "
foreach var of local p {
file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}


/* STEP 2: CAREHOMES*/
use ./output/analysis_dataset.dta, clear
keep if carehome==1
gen byte cons=1

*Denominator
file write tablecontent ("Care home population") _n
file write tablecontent ("N") _tab

generaterow2, variable(cons) condition("==1")
file write tablecontent _n 


*Outcomes 
foreach var of global outcomes {

file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}

*icu outcomes
local p" "any_resp_support_flag" "basic_resp_support_flag" "advanced_resp_support_flag" "
foreach var of local p {
file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}



file close tablecontent


* Close log file 
log close

