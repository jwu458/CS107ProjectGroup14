/*-------------------------------------------------------------------------*
 |                                                                         
 |            STATA SUPPLEMENTAL SYNTAX FILE FOR ICPSR 36053
 |           COGNITION AND AGING IN THE USA (COGUSA) 2007-2009
 |                    (DATASET 0002: TEST SCORE DATA)
 |
 |
 | This Stata missing value recode program is provided for optional use with
 | the Stata system version of this data file as distributed by ICPSR.
 | The program replaces user-defined numeric missing values (e.g., -9)
 | with generic system missing "."  Note that Stata allows you to specify
 | up to 27 unique missing value codes.  Only variables with user-defined
 | missing values are included in this program.
 |
 | To apply the missing value recodes, users need to first open the
 | Stata data file on their system, apply the missing value recodes if
 | desired, then save a new copy of the data file with the missing values
 | applied.  Users are strongly advised to use a different filename when
 | saving the new file.
 |
 *------------------------------------------------------------------------*/

replace W1_D_RM = . if (W1_D_RM == 8 | W1_D_RM == 9)
replace W1_D_RPM = . if (W1_D_RPM == 8 | W1_D_RPM == 9)
replace W2_RTR1 = . if (W2_RTR1 == 8 | W2_RTR1 == 9)
replace W2_RTR2 = . if (W2_RTR2 == 8 | W2_RTR2 == 9)
replace W2_RTR3 = . if (W2_RTR3 == 8 | W2_RTR3 == 9)
replace W2_RTR4 = . if (W2_RTR4 == 8 | W2_RTR4 == 9)
replace W2_RTR5 = . if (W2_RTR5 == 8 | W2_RTR5 == 9)
replace W3_D_RM = . if (W3_D_RM == 8 | W3_D_RM == 9)
replace W3_D_RPM = . if (W3_D_RPM == 8 | W3_D_RPM == 9)


