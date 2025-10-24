clear all

clear

*This director should contain the data file all_data. It is also where the output files will be written

global table_directory C:\Users\ss3977\Desktop\Research\Projects\Current\NSHAP\Output for Paper\Weighted\Public\

/************************************************************************************/
/* Use the full merged dataset so later I can model mortality later                 */
/************************************************************************************/

use "${table_directory}all_data", replace

/************************************************************************************/
/* Just keeping the people in W2 & W3                                               */
/************************************************************************************/

keep if _merge==3

/************************************************************************************/
/* Just keeping the people where total MOCA time is recorded (drop 1 person)        */
/************************************************************************************/
keep if t_moca ~=.

/************************************************************************************/
/* Standardize the two time measure using W2 weights                                */
/************************************************************************************/

*replace weight_adj=1

/************************************************************************************/
/* generate interviewer number                                                      */
/************************************************************************************/

destring fi_id, gen(fid2)

gen walk_time_w2=walk_1_numsec+walk_2_numsec

gen smell_id_w2=(bluepen_1==3)+(bluepen_2==3)+(bluepen_3==1)+(bluepen_4==2)+(bluepen_5==2)
replace smell_id_w2=. if bluepen_1==.c
tab smell_id_w2, miss
gen smell_threshold_w2=(redpen2_1==2)+(redpen2_2==1)+(redpen2_3==3)+(redpen2_4==2)+(redpen2_5==1)+(redpen2_6==3)
replace smell_threshold_w2=. if redpen2_1==.c
tab smell_threshold_w2, miss

gen smell_w2=smell_id_w2+smell_threshold_w2
					  	
foreach x of varlist  $times3_w3 {
	sum `x' [aw=weight_adj]
	gen z_`x'=(`x'-r(mean))/r(sd)
	drop `x'
}

foreach x of varlist  $times2_w2 {
	sum `x' [aw=weight_adj]
	gen z_`x'=(`x'-r(mean))/r(sd)
	drop `x'
}


quietly {
	sum age [aw=weight_adj]
    gen age_demeaned=age-r(mean)
	sum moca_sa [aw=weight_adj]
    gen moca_sa_demeaned= moca_sa-r(mean)
}

pca z_t_month2_w3 z_t_date3_w3 z_t_rhino_w3 z_t_clock_w3 z_t_trail_w3 z_t_immed1_w3 z_t_immed2_w3 z_t_digits5_w3 z_t_digits3_w3 z_t_subtract_w3 z_t_cat_w3 z_t_word2_w3 z_t_ruler_w3 z_t_delayed_w3 [aw=weight_adj], comp(1) covariance
predict pc1_w3


pca z_t_month2_w2 z_t_date2_w2 z_t_rhino_w2 z_t_clock_w2 z_t_trail_w2 z_t_immed1_w2 z_t_immed2_w2 z_t_digits5_w2 z_t_digits3_w2 z_t_subtract_w2 z_t_cat_w2 z_t_word2_w2 z_t_ruler_w2 z_t_delayed_w2 [aw=weight_adj], comp(1) covariance
predict pc1_w2

corr pc1_w*

gen pc1=pc1_w2
gen pc1_demeaned=.

*Col 1 Table 1
quietly regress moca_sa age_demeaned i.fid2 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly regress moca_sa age_demeaned i.fid2 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_1_08012022", keep(age_demeaned) replace cttop("Round 2") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
													
*Col 2 Table 1													
regress moca_sa pc1 age_demeaned i.fid2 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly regress moca_sa pc1_demeaned age_demeaned i.fid2 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_1_08012022", keep(age_demeaned pc1_demeaned) append cttop("Round 2") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Col 3 Table 1
quietly regress moca_sa_w3 pc1 age_demeaned i.fid2 i.fid3 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly regress moca_sa_w3 pc1_demeaned age_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_1_08012022", keep(age_demeaned pc1_demeaned) append cttop("Round 3") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel

quietly regress moca_sa_w3 pc1 age_demeaned moca_sa_demeaned i.fid2 i.fid3  [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly sum moca_sa [aw=weight_adj]  if e(sample)==1
replace moca_sa_demeaned=moca_sa-r(mean)
quietly regress moca_sa_w3 pc1_demeaned moca_sa_demeaned age_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_1_08012022", keep(age_demeaned pc1_demeaned  moca_sa_demeaned) append cttop("Round 3") ///
                 addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel

reg smell_w2 age_demeaned [aw=weight_adj] 
predict smell_w2_d
gen smell_d=smell_w2 if smell_w2 ~=.
replace smell_d=smell_w2_d if smell_w2 ==.
sum smell_d [aw=weight_adj]
replace smell_d=smell_d-r(mean)
gen smell_d_miss=(smell_w2==.)

drop smell_d smell_d_miss smell_w2_d
areg smell_w2 age_demeaned [aw=weight_adj] , absorb(fid2)
predict smell_w2_d
gen smell_d=smell_w2 if smell_w2 ~=.
replace smell_d=smell_w2_d if smell_w2 ==.
sum smell_d [aw=weight_adj]
replace smell_d=smell_d-r(mean)
gen smell_d_miss=(smell_w2==.)

drop smell_d smell_d_miss smell_w2_d

areg smell_w2 age_demeaned [aw=weight_adj] , absorb(fid2)
predict smell_w2_d
gen smell_d=smell_w2 if smell_w2 ~=.
replace smell_d=smell_w2_d if smell_w2 ==.
sum smell_d [aw=weight_adj]
replace smell_d=smell_d-r(mean)
gen smell_d_miss=(smell_w2==.)

drop smell_d smell_d_miss smell_w2_d



/************************************************************************************/
/* This sets up three levels of cognition 0-10, 11-16 and 17-20.                    */
/************************************************************************************/

gen cognition = 1 if moca_sa <11
replace cognition = 2 if moca_sa >=11 & moca_sa <= 16
replace cognition = 3 if moca_sa > 16

gen cognition_w3 = 1 if moca_sa_w3 <11
replace cognition_w3 = 2 if moca_sa_w3 >=11 & moca_sa_w3 <= 16
replace cognition_w3 = 3 if moca_sa_w3 > 16

label define moca_sa_cat 1 "Dementia" 2 "MCI" 3 "Normal"
label values cognition moc_sa_cat
label values cognition_w3 moc_sa_cat

gen dementia=cognition==1
gen mci=cognition==2

gen mci_w3=cognition_w3==2
gen dementia_w3=cognition_w3==1

gen border=(moca_sa >=10 & moca_sa <=11) | (moca_sa >=16 & moca_sa <=17) 

replace pc1=pc1_w2

quietly {
	*sum moca_sa [aw=weight_adj]
    *gen moca_sa_demeaned=moca_sa-r(mean)
	sum walk_time_w2 [aw=weight_adj]
    gen walk_time_w2_d=walk_time_w2-r(mean)
    sum t_consent [aw=weight_adj]
    gen t_consent_d=t_consent-r(mean)
	sum smell_w2 [aw=weight_adj]
    *gen smell_w2_d=smell_w2-r(mean)
	sum moca_sa [aw=weight_adj] if cognition==3
    gen moca_sa_demeaned3=moca_sa-r(mean) if cognition==3
		sum moca_sa [aw=weight_adj] if cognition==2
    gen moca_sa_demeaned2=moca_sa-r(mean) if cognition==2
		sum moca_sa [aw=weight_adj] if cognition==1
    gen moca_sa_demeaned1=moca_sa-r(mean) if cognition==1
	sum age [aw=weight_adj] if cognition==3
    gen age_demeaned3=age-r(mean) if cognition==3
	sum age [aw=weight_adj] if cognition==2
    gen age_demeaned2=age-r(mean) if cognition==2
	sum age [aw=weight_adj] if cognition==1
    gen age_demeaned1=age-r(mean) if cognition==1
		
	
}


gen age_d=age_demeaned
gen moca_d=moca_sa_demeaned

areg smell_w2 moca_d pc1 age_d[aw=weight_adj], absorb(fid2) 
predict smell_w2_d
gen smell_d=smell_w2 if smell_w2 ~=.
replace smell_d=smell_w2_d if smell_w2 ==.

sum smell_d [aw=weight_adj]
replace smell_d=smell_d-r(mean)
gen smell_d_miss=(smell_w2==.)

replace age_d=age_demeaned
replace moca_d=moca_sa_demeaned
quietly regress moca_sa_w3 moca_d i.moca_sa#c.pc1  age_d i.fid2 i.fid3 [aw=weight_adj], nocons
outreg2 using "${table_directory}CoefPlot_Estimates08012022", replace cttop("ALL") addtext(Interviewer FE, YES) excel
coefplot, nolabel drop(moca_d age_d *fid*) keep(*:) xline(0)  rename(*.moca_sa#c.pc1 = .) ///
          order(20. 19. 18. 17. 16. 15. 14. 13. 12. 11. 10. 9. 8. 7. 6. 5. 4. 3. 2.) ///
		  title(Effect of Response Time on Round 3 MoCA Score) subtitle(By Round 3 MoCA Score) ///
		  xtitle(Effect of Std. Change in Response time) ytitle(Round 2 MoCA Score) yline(10.5 4.5) ///
		  text(2 1  "Normal" 7 1 "MCI" 14 1 "Dementia", place(se) )
graph export "${table_directory}Effect_of_RT_by_W2_MOCA_08012022.png" , replace  


/***********************************************************************************/
/* Walktime, Consent time and smell in W3 as a predictor of MOCA W3                */
/***********************************************************************************/

gen pc1_dementia=pc1*dementia
gen pc1_mci=pc1*mci
gen pc1_normal=pc1*(1-mci-dementia)
gen smell_w2_new=smell_d
gen smell_w2_miss=smell_d_miss
gen smell_w2_new_dementia =  smell_w2_new*dementia
gen smell_w2_new_mci = smell_w2_new*mci
gen smell_w2_new_normal = smell_w2_new*(1-mci-dementia)

quietly regress walk_time_w3 i.fid3
quietly predict walk_time_w3_resid, resid
quietly regress walk_time_w2_d i.fid2
quietly predict walk_time_w2_d_resid, resid
quietly regress moca_d i.fid2
quietly predict moca_d_resid, resid
quietly regress pc1 i.fid2
quietly predict pc1_resid, resid
quietly regress age_d i.fid2
quietly predict age_d_resid, resid

areg walk_time_w3 walk_time_w2_d moca_d pc1 age_d[aw=weight_adj], absorb(fid2)

quietly regress walk_time_w3 walk_time_w2_d moca_d pc1 age_d i.fid2 i.fid3 [aw=weight_adj]
estimates table,  keep(walk_time_w2_d moca_d pc1 age_d) b star(.1 .05 .01)


quietly regress t_consent3 t_consent_d moca_d pc1 age_d i.fid2 i.fid3 [aw=weight_adj]
estimates table,  keep(t_consent_d  moca_d pc1 age_d) b star(.1 .05 .01)

regress walk_time_w3_resid walk_time_w2_d_resid moca_d_resid pc1_resid age_d_resid [aw=weight_adj]

areg walk_time_w3_resid walk_time_w2_d moca_d pc1 age_d[aw=weight_adj], absorb(fid2)
*Col 1 Table 2
quietly regress walk_time_w3 walk_time_w2_d moca_d pc1 age_d i.fid2 i.fid3 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly sum moca_sa [aw=weight_adj]  if e(sample)==1
replace moca_sa_demeaned=moca_sa-r(mean)
quietly sum walk_time_w2 [aw=weight_adj]  if e(sample)==1
replace walk_time_w2_d=walk_time_w2-r(mean)
quietly regress walk_time_w3 walk_time_w2_d moca_sa_demeaned pc1_demeaned age_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum walk_time_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_2_08012022", replace keep(walk_time_w2_d moca_sa_demeaned pc1_demeaned age_demeaned) cttop("ALL") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Col 2 Table 2
quietly regress t_consent3 t_consent_d moca_d pc1 age_d i.fid2 i.fid3 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly sum moca_sa [aw=weight_adj]  if e(sample)==1
replace moca_sa_demeaned=moca_sa-r(mean)
quietly sum t_consent [aw=weight_adj]  if e(sample)==1
replace t_consent_d=t_consent-r(mean)
quietly regress t_consent3 t_consent_d moca_sa_demeaned pc1_demeaned age_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.01)
quietly sum t_consent3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_2_08012022", append keep(t_consent_d moca_sa_demeaned pc1_demeaned age_demeaned) cttop("ALL") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel

* Col 1 Table 3 (repeat of Table 1 Col 2)
*Column 1 Overall Effect of PC1
quietly regress moca_sa_w3 pc1 age_demeaned moca_sa_demeaned i.fid2 i.fid3  [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly sum moca_sa [aw=weight_adj]  if e(sample)==1
replace moca_sa_demeaned=moca_sa-r(mean)
quietly regress moca_sa_w3 pc1_demeaned moca_sa_demeaned age_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_3_08012022", keep(pc1_demeaned moca_sa_demeaned age_demeaned) replace cttop("Round 3") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Column 2 Effect of PC1 by level of cognition
quietly regress moca_sa_w3 pc1_normal pc1_mci pc1_dementia age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
quietly sum age [aw=weight_adj]  if e(sample)==1
replace age_demeaned=age-r(mean)
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
gen pc1_normal_demeaned=pc1_demeaned*(1-mci-dementia) if e(sample)==1
gen pc1_mci_demeaned=pc1_demeaned*(mci) if e(sample)==1
gen pc1_dementia_demeaned=pc1_demeaned*(dementia) if e(sample)==1
quietly sum moca_sa [aw=weight_adj]  if e(sample)==1
replace moca_sa_demeaned=moca_sa-r(mean)
quietly regress moca_sa_w3 pc1_normal_demeaned pc1_mci_demeaned pc1_dementia_demeaned age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_3_08012022", append cttop("ALL") keep(pc1_normal_demeaned pc1_mci_demeaned pc1_dementia_demeaned ///
                                                                             age_demeaned moca_sa_demeaned) ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Column 3 Overall Effect of Smell
quietly regress moca_sa_w3 smell_w2_new ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1
local mean=round(r(mean),0.01)	  
outreg2 using "${table_directory}Table_3_08012022", keep(moca_sa_w3 smell_w2_new age_demeaned moca_sa_demeaned) append cttop("Round 3") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Column 4 Effect of Smell by level of cognition
quietly regress moca_sa_w3 smell_w2_new_normal smell_w2_new_mci smell_w2_new_dementia ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1 & smell_w2_miss==0
local mean=round(r(mean),0.01)			  
outreg2 using "${table_directory}Table_3_08012022", ///
                                                keep(smell_w2_new_normal smell_w2_new_mci smell_w2_new_dementia age_demeaned moca_sa_demeaned) ///
												append cttop("ALL") addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Column 5 Overall Effect of PC1 and Smell
quietly regress moca_sa_w3 pc1 smell_w2_new ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
quietly sum pc1 [aw=weight_adj]  if e(sample)==1
replace pc1_demeaned=pc1-r(mean)
quietly regress moca_sa_w3 pc1_demeaned smell_w2_new ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1 & smell_w2_miss==0
local mean=round(r(mean),0.01)
outreg2 using "${table_directory}Table_3_08012022", ///
                                                    keep(pc1_demeaned smell_w2_new age_demeaned moca_sa_demeaned) append cttop("Round 3") ///
                                                    addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel
*Column 6 Effect of PC1 and Smell by level of cognition
quietly regress moca_sa_w3 pc1_normal pc1_mci pc1_dementia smell_w2_new_normal smell_w2_new_mci smell_w2_new_dementia ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
replace pc1_demeaned=pc1-r(mean)
replace pc1_normal_demeaned=pc1_demeaned*(1-mci-dementia) if e(sample)==1
replace pc1_mci_demeaned=pc1_demeaned*(mci) if e(sample)==1
replace pc1_dementia_demeaned=pc1_demeaned*(dementia) if e(sample)==1
quietly regress moca_sa_w3 pc1_normal pc1_mci pc1_dementia smell_w2_new_normal smell_w2_new_mci smell_w2_new_dementia ///
              smell_w2_miss age_demeaned moca_sa_demeaned i.fid2 i.fid3 [aw=weight_adj]
local df=e(N)
local rmse=round(e(rmse),0.01)
local se=round(`rmse'/sqrt(`df'),0.0001)
quietly sum moca_sa_w3 [aw=weight_adj] if e(sample)==1 & smell_w2_miss==0
local mean=round(r(mean),0.01)			  
outreg2 using "${table_directory}Table_3_08012022", ///
                        keep(pc1_normal_demeaned pc1_mci_demeaned pc1_dementia_demeaned ///
						smell_w2_new_normal smell_w2_new_mci smell_w2_new_dementia age_demeaned moca_sa_demeaned) ///
                        append cttop("ALL") addtext(Interviewer FE, YES, Mean Dep. Var, `mean', Standard Error ,"( "`se'" )") excel


sum pc1 [aw=weight_adj], det
sum t_moca [aw=weight_adj] if pc1 > -0.025 & pc1 < 0.025
sum t_moca [aw=weight_adj] if pc1 > 1-0.025 & pc1 < 1+0.025


clear

use "${table_directory}all_data"


/************************************************************************************/
/* Just keeping the people where total MOCA time is recorded (drop 1 person)        */
/************************************************************************************/
keep if t_moca ~=.

/************************************************************************************/
/* Standardize the two time measure using W2 weights                                */
/************************************************************************************/

*replace weight_adj=1

/************************************************************************************/
/* generate interviewer number                                                      */
/************************************************************************************/

destring fi_id, gen(fid2)

					  	
foreach x of varlist  $times2_w2 {
	sum `x' [aw=weight_adj]
	gen z_`x'=(`x'-r(mean))/r(sd)
	drop `x'
}


quietly {
	sum age [aw=weight_adj]
    gen age_d=age-r(mean)
	sum moca_sa [aw=weight_adj]
    gen moca_d=moca_sa-r(mean)
}


pca z_t_month2_w2 z_t_date2_w2 z_t_rhino_w2 z_t_clock_w2 z_t_trail_w2 z_t_immed1_w2 z_t_immed2_w2 z_t_digits5_w2 z_t_digits3_w2 z_t_subtract_w2 z_t_cat_w2 z_t_word2_w2 z_t_ruler_w2 z_t_delayed_w2 [aw=weight_adj], comp(1) covariance
predict pc1

sort su_id
drop _merge
merge su_id using "${stata_data_directory}nshap_w3_times"

tab disp

gen status=1 if disp==1 | disp==5
replace status=3 if disp==2
replace status=2 if disp==3 | disp==4
*replace status=4 if status==.
sum status

label define status_lbl 1 "Alive"  2 "Poor Health" 3 "Dead" 4 "Unknown"
label values status status_lbl

tab status
/*
mlogit status moca_d pc1 age_d
margins, dydx(pc1) post
outreg2 using "${table_directory}Table_4", replace  excel cttop("ALL") addtext(Interviewer FE, NO) 
*/


gen smell_id_w2=(bluepen_1==3)+(bluepen_2==3)+(bluepen_3==1)+(bluepen_4==2)+(bluepen_5==2)
replace smell_id_w2=. if bluepen_1==.c
tab smell_id_w2, miss
gen smell_threshold_w2=(redpen2_1==2)+(redpen2_2==1)+(redpen2_3==3)+(redpen2_4==2)+(redpen2_5==1)+(redpen2_6==3)
replace smell_threshold_w2=. if redpen2_1==.c
tab smell_threshold_w2, miss

gen smell_w2=smell_id_w2+smell_threshold_w2

areg smell_w2 moca_d pc1  age_d [aw=weight_adj], absorb(fid2)
predict t
gen smell_w2_miss=(smell_w2==.)
gen smell_w2_new=smell_w2
replace smell_w2_new=t if smell_w2_miss==1
sum smell_w2_new
replace smell_w2_new=smell_w2_new-r(mean)

gen sensitive= moca_sa <=16 & moca_sa>=9
gen pc1_sensitive=pc1 if sensitive==1
replace pc1_sensitive= 0 if sensitive==0
gen smell_w2_new_sensitive=smell_w2_new*sensitive

gen cognition = 1 if moca_sa <11
replace cognition = 2 if moca_sa >=11 & moca_sa <= 16
replace cognition = 3 if moca_sa > 16

label define moca_sa_cat 1 "Dementia" 2 "MCI" 3 "Normal"
label values cognition moc_sa_cat

gen dementia=cognition==1
gen mci=cognition==2


gen pc1_dementia=pc1*dementia
gen pc1_mci=pc1*mci
gen smell_w2_new_dementia=smell_w2_new*dementia
gen smell_w2_new_mci=smell_w2_new*mci
gen smell_w2_miss_mci=smell_w2_miss*mci
gen smell_w2_miss_dementia=smell_w2_miss*dementia

mlogit status moca_d pc1 age_d i.fid2
estimates store status
margins, dydx(moca_d pc1 age_d) post
matrix b=e(b)
matrix v=e(V)

matrix results=J(8,3,0)
forvalues r=1(1)3 {
	forvalues c=1(1)3 {
		matrix results[2*`r'-1,`c']=b[1,3*(`r'-1)+`c']
		matrix results[2*`r',`c']=sqrt(v[3*(`r'-1)+`c',3*(`r'-1)+`c'])
	}
}


estimates restore status
margins, post
matrix b=e(b)
matrix v=e(V)
forvalues c=1(1)3 {
	matrix results[7,`c']=b[1,`c']
	matrix results[8,`c']=sqrt(v[`c',`c'])
}
matrix list results

putexcel set "${table_directory}Table_3_mortality_08012022", replace 

putexcel B2 = "(3)"
putexcel C2 = "(4)"
putexcel D2 = "(5)"
putexcel B4 = "Alive"
putexcel C4 = "Poor Health"
putexcel D4 = "Dead"

putexcel A6 = matrix(results), names 
putexcel B15 = matrix(e(_N))
