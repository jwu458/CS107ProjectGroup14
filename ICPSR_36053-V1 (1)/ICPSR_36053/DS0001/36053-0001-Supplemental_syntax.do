/*-------------------------------------------------------------------------*
 |                                                                         
 |            STATA SUPPLEMENTAL SYNTAX FILE FOR ICPSR 36053
 |           COGNITION AND AGING IN THE USA (COGUSA) 2007-2009
 |                    (DATASET 0001: DEMOGRAPHIC DATA)
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

replace HISPANIC = . if (HISPANIC == 8 | HISPANIC == 9)
replace RACEM1 = . if (RACEM1 == 98 | RACEM1 == 99)
replace RACEM2 = . if (RACEM2 == 98 | RACEM2 == 99)
replace W1_VERSIONDATE = "" if (W1_VERSIONDATE == ".")
replace W1_IWMM = . if (W1_IWMM == 98 | W1_IWMM == 99)
replace W1_MARSTAT = . if (W1_MARSTAT == 9)
replace W2_VERSIONDATE = "" if (W2_VERSIONDATE == ".")
replace W2_IWMM = . if (W2_IWMM == 98 | W2_IWMM == 99)
replace W3_VERSIONDATE = "" if (W3_VERSIONDATE == ".")
replace W3_IWMM = . if (W3_IWMM == 98 | W3_IWMM == 99)


