* Authors: Luis F. Gamboa & Paul Rodriguez-Lesmes
* Date: 2017.09.18

clear all
glo carpeta = "D:\Mis Documentos\git\SubjectiveEarnings"

cd "$carpeta"
* Cargar datos del ICFES ***************************
use baseRetornosSubjetivos.dta, clear

cd "$carpeta/documento/tablas"

* 5. Regresiones de los determinantes de los retornos subjetivos

* *********************************************************

* Get sample

qui reg inad_ingresoprofesional inad_ingresotecnitecno inad_ingresobto ///
	i.estu_puntajelenguaje i.estu_puntajematematicas ///
	c.estu_edad i.masc i.disca ///
	c.INSE i.eduPadre_1 i.eduPadre_3 i.eduPadre_4 i.eduMadre_1 i.eduMadre_3 i.eduMadre_4 ///
	c.ret16a11 c.wage11  ///
	c.icv c.ipmincid c.atd_total5 c.homid c.pob c.proprUrbRural i.oro i.carbon  ///
	i.jorn_3 i.carac_2 i.privado i.generoNMxto c.col12Math_mean c.col12Lang_mean c.totEs c.perMales i.periodo ///
	, cluster(insc_id)


	*gen muestra=e(sample)
	keep if muestra==1
preserve
	keep insc_id muestra
	save "$carpeta/miMuestra.dta", replace
restore

gen pri= periodo==20131
label var pri "First Semester"

label var estu_puntajematematicas "Expected score in Maths"
label var estu_puntajelenguaje "Expected score in Lang"
label define expPerform 1 "Very Low (0-30)" 2 "Low (30,01-50)" 3 "Medium (50,01-70,00)" 4 "High (70,01+)", replace
label val estu_puntajematematicas expPerform
label val estu_puntajelenguaje expPerform

*tab estu_puntajelenguaje, gen(estu_puntajelenguaje_)
*tab estu_puntajematematicas, gen(estu_puntajematematicas_)


label var estu_puntajelenguaje_2 "Expects Low Lang scores"
label var estu_puntajelenguaje_3 "Expects Medium Lang scores"
label var estu_puntajelenguaje_4 "Expects High Lang scores"
label var estu_puntajematematicas_2 "Expects Low Math scores"
label var estu_puntajematematicas_3 "Expects Medium Math scores"
label var estu_puntajematematicas_4 "Expects High Math scores"
label var perMales "Proportion of male students"

* ************************************************************************
* ***** PANEL STRATEGY ***************************************************	
* ************************************************************************
	
* Let's prepare the dataset to be a "panel"
gen ing1= inad_ingresobto
gen ing2 = inad_ingresotecnitecno
gen ing3= inad_ingresoprofesional
drop if insc_id==.

rename ingNum_bto ingNum1
rename ingNum_tec ingNum2
rename ingNum_prof ingNum3

foreach val in bto tecnitecno profesional {
	if "`val'"=="bto"         local val2=1
	if "`val'"=="tecnitecno"  local val2=2
	if "`val'"=="profesional" local val2=3

	gen lbound`val2'=0 if inad_ingreso`val'==1
	gen ubound`val2'=589.5 if inad_ingreso`val'==1

	replace lbound`val2'=589.5 if inad_ingreso`val'==2
	replace ubound`val2'=1179 if inad_ingreso`val'==2

	replace lbound`val2'=1768.5 if inad_ingreso`val'==3
	replace ubound`val2'=2358 if inad_ingreso`val'==3

	replace lbound`val2'=2947.5 if inad_ingreso`val'==4
	replace ubound`val2'=4126.5 if inad_ingreso`val'==4

	replace lbound`val2'=4716 if inad_ingreso`val'==5
	replace ubound`val2'=5895 if inad_ingreso`val'==5

	replace lbound`val2'=5895 if inad_ingreso`val'==6
	replace ubound`val2'=. if inad_ingreso`val'==6
}


*sample 10
reshape long ing ingNum lbound ubound, i(insc_id) j(Schl)
* Ready to go!
label var Schl "Schooling level"

* *********************************************************
* *********************************************************
* Different Cutoffs
* *********************************************************
* *********************************************************
if 1==0 {

cap drop pred*

	* Main results
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r1
	predict pred1
	label var pred1 "Estimated Subjective Expected Income 1"	
		
	gen or_lbound=lbound
	gen or_ubound=ubound
	
	* Use Lower Bound as cutoffs
	
	replace lbound=1179 if lbound==1768.5
	replace lbound=2358 if lbound==2947.5
	replace lbound=4126.5 if lbound==4716

	
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r2
	predict pred2
	label var pred2 "Estimated Subjective Expected Income 2"		
	
	replace lbound=or_lbound
	replace ubound=or_ubound
	
	* Use Upper Bound as cutoffs
	
	replace ubound=1768.5 if ubound==1179
	replace ubound=2947.5 if ubound==2358
	replace ubound=4716 if ubound==4126.5		
	
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r3
	predict pred3
	label var pred3 "Estimated Subjective Expected Income 3"		
	
	replace lbound=or_lbound
	replace ubound=or_ubound	
	
	* Use the value in the middle as cutoffs
	
	replace lbound=(1179+1768.5)/2 if lbound==1768.5
	replace lbound=(2358+2947.5)/2 if lbound==2947.5
	replace lbound=(4126.5+4716)/2 if lbound==4716

	replace ubound=(1768.5+1179)/2 if ubound==1179
	replace ubound=(2947.5+2358)/2 if ubound==2358
	replace ubound=(4716+4126.5)/2 if ubound==4126.5	
	
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r4
	predict pred4
	label var pred4 "Estimated Subjective Expected Income 4"	
	
	replace lbound=or_lbound
	replace ubound=or_ubound	


* *********************************************************
* 1. Estimation Output ( To be used when comparing with other models )

	texdoc init intervalsMultiCutoffs , replace force
	
	tex \begin{table}[H]
	tex \caption{Interval Regression Other Cutoffs Part}
	tex \label{robustnessCutoffs1}
	tex \scriptsize
	tex \centering
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X}
	tex \renewcommand{\arraystretch}{0.8}% Tighter
	tex \scalebox{0.7}{
	tex \begin{tabularx} {25cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \toprule 
	tex & \multicolumn{3}{c}{Main Results} & \multicolumn{3}{c}{Lower Cutoffs} & \multicolumn{3}{c}{High Cutoffs} & \multicolumn{3}{c}{Midpoint Cutoffs} \\
	tex & H.School & Voc. & Profess. & H.School & Voc. & Profess. & H.School & Voc. & Profess. & H.School & Voc. & Profess. \\ 
	tex \cmidrule(r){2-4} \cmidrule(r){5-7} \cmidrule(r){8-10} \cmidrule(r){11-13}	
	
	* All Variables *******************	
	foreach miVar in 	estu_edad masc disca ///
						INSE eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 ///
						pri privado catSABER11two generoNMxto col12Math_mean col12Lang_mean totEs ///
						ret16a11 wage11 ///
						ipmincid proprUrbRural homid pob oro ///
						{
	
		local miTitulo : variable label `miVar'
		qui tab `miVar'	
		local bina=r(r)<3	
		disp "`miVar' is binary=`bina'"
		
		tex \rowcolor{Gray}
		tex $ \quad $ `miTitulo'		
		
		forval mod=1(1)4 {
		
		disp "Modelo `mod'"
			est restore r`mod'
			margins Schl , dydx(`miVar') post
			mat list e(b)
			
			if `bina'==1 capture disp _b[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _b[`miVar':1.Schl]	
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {
					if `bina'==1 {			
						local coefo=_b[1.`miVar':`i'.Schl]
						local mise=_se[1.`miVar':`i'.Schl]
					}
					if `bina'==0 {
						local coefo=_b[`miVar':`i'.Schl]
						local mise=_se[`miVar':`i'.Schl]
					}
				
					local coef : di %6.2f `coefo'
					local miz= `coefo'/`mise'
					local star = ""
					if ((abs(`miz') > 1.645) ) local star = "^{*}" 
					if ((abs(`miz') > 1.96)  ) local star = "^{**}" 
					if ((abs(`miz') > 2.575) ) local star = "^{***}"  		
					disp "& $ `coef' `star' $ "
					tex & $ `coef' `star' $ 
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}		
		}
		tex \\
		
		forval mod=1(1)4 {
		disp "Modelo SE `mod'"
			est restore r`mod'	
			margins Schl , dydx(`miVar') post
			mat list e(b)
			
			if `bina'==1 capture disp _se[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _se[`miVar':1.Schl]		
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {	
					if `bina'==1 local mise=_se[1.`miVar':`i'.Schl]	
					if `bina'==0 local mise=_se[`miVar':`i'.Schl]		
				
					local serr : di %6.2f `mise'
					tex & $ (`serr') $
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}	
		}	
		tex \\	
	}
	disp "REady 1st"
	
/*	* Constants ********************************
	tex Constants
	forval mod=1(1)4 {
		tex &
		est restore r`mod'			
		forval i=2(1)3 {
			local coefo=_b[model:`i'.Schl]
			local coef : di %6.2f `coefo'
			tex & $ `coef' `star' $ 
		}
	}
	tex \\
*/
	* *****************************************
	tex \midrule
	
	tex \rowcolor{Gray}
	tex Number of Obs.
	forval mod=1(1)4 {
		est restore r`mod'		
		local numObs = 	e(N)
		tex &  \multicolumn{3}{c}{`numObs'}
	}
	tex \\

	tex Number of Indiv.
	forval mod=1(1)4 {
		est restore r`mod'		
		local clust = e(N_clust)
		tex &  \multicolumn{3}{c}{`clust'} 
	}
	tex \\
	
	tex \rowcolor{Gray}
	tex LR $ \chi^2 test (df)[p-val] $
	forval mod=1(1)4 {
		est restore r`mod'		
		local chi2 : di %10.4f  e(chi2)
		local pchi2 : di %6.2f  e(p)
		local df = e(df_m)
		tex &  \multicolumn{3}{c}{`chi2' (`df')[`pchi2']}
	}
	tex \\
		
	tex Log-likelihood 
	forval mod=1(1)4 {
		est restore r`mod'	
		estat ic
		local logli = el(r(S),1,3)
		tex &  \multicolumn{3}{c}{`logli'}
	}
	tex \\
		
	tex \rowcolor{Gray}	
	tex AIC
	forval mod=1(1)4 {
		est restore r`mod'	
		estat ic
		local aic  : di %10.2f  el(r(S),1,5)
		tex &  \multicolumn{3}{c}{`aic'}
	}
	tex \\
		
	tex BIC
	forval mod=1(1)4 {
		est restore r`mod'	
		estat ic
		local bic  : di %10.2f  el(r(S),1,6)
		tex &  \multicolumn{3}{c}{`bic'}
	}
	tex \\

	tex \rowcolor{Gray}
	tex Percentage of LB hits / UB hits
	forval mod=1(1)4 {
		correlate lbound ubound pred`mod'
		local lbhits : di %6.2f el(r(C),3,1)*100
		local ubhits : di %6.2f el(r(C),3,2)*100		
		tex &  \multicolumn{3}{c}{`lbhits' / `ubhits' }
	}
	tex \\	
	

	tex \addlinespace[1.75ex]

	tex \bottomrule
	tex \addlinespace[.75ex]
	tex \multicolumn{13}{l}{SE clustered at individual level. Significance: * 10\%, ** 5\%, *** 1\%.} \\
	tex \multicolumn{13}{l}{Interval regression marginal effects calculated by the Delta method at the averages.}
	tex \end{tabularx}
	tex }
	tex \normalsize
	tex \end{table}
	texdoc close
	
*/

}


* *********************************************************
* *********************************************************
* Different Covariates and clustering
* *********************************************************
* *******************x**************************************
if 1==0 {

	
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	, cluster(insc_id)
	est store r1
	predict pred1
	label var pred1 "Estimated Subjective Expected Income 1"

intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r2
	predict pred2
	label var pred2 "Estimated Subjective Expected Income 2"	
	

intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r3
	predict pred3
	label var pred3 "Estimated Subjective Expected Income 3"
		
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(codcoleg)
	est store r4
	predict pred4
	label var pred4 "Estimated Subjective Expected Income 4"
	
	
intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(codigomunicipio)
	est store r5
	predict pred5
	label var pred5 "Estimated Subjective Expected Income 5"

		
		
* *********************************************************
* 1. Estimation Output ( To be used when comparing with other models )

	texdoc init intervalsRob , replace force
	
	tex \begin{table}[H]
	tex \caption{Interval Regression: alternative set of covariates and cluster specification}
	tex \label{intervalsRob}
	tex \centering
	tex \renewcommand{\arraystretch}{0.8}% Tighter
	tex \begin{adjustbox}{max totalsize={1.3\textwidth}{1.3\textheight},center}
	tex \begin{tabularx} {44cm} {@{} l c c c c c c c c c c c c c c c} \\
	tex \toprule 
	tex & \multicolumn{3}{c}{\parbox[c]{6cm}{Individual and household controls}} & \multicolumn{3}{c}{\parbox[c]{5cm}{+ School controls}} & \multicolumn{3}{c}{\parbox[c]{5cm}{Main Specification}} & \multicolumn{3}{c}{\parbox[c]{5cm}{School level cluster}} & \multicolumn{3}{c}{\parbox[c]{5cm}{Municipality level cluster}} \\
	tex & H.School & Voc. & Profess. & H.School & Voc. & Profess. & H.School & Voc. & Profess. & H.School & Voc. & Profess.  & H.School & Voc. & Profess. \\ 
	tex \cmidrule(r){2-4} \cmidrule(r){5-7} \cmidrule(r){8-10} \cmidrule(r){11-13}	\cmidrule(r){14-16}	
	
	* All Variables *******************	
*	foreach miVar in 	estu_edad masc disca ///
*						INSE eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 ///

	foreach miVar in 	pri privado catSABER11two generoNMxto col12Math_mean col12Lang_mean totEs ///
						ret16a11 wage11 ///						
						ipmincid proprUrbRural homid pob oro ///						
						{
		
		local miTitulo : variable label `miVar'
		qui tab `miVar'	
		local bina=r(r)<3	
		disp "`miVar' is binary=`bina'"
		
		tex \rowcolor{Gray}
		tex $ \quad $ `miTitulo'
		
		forval mod=1(1)5 {
		
		disp "Modelo `mod'"
			est restore r`mod'	
			cap margins Schl , dydx(`miVar') post
			cap mat list e(b)			
			
			if `bina'==1 capture disp _b[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _b[`miVar':1.Schl]			
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {
					if `bina'==1 {			
						local coefo=_b[1.`miVar':`i'.Schl]
						local mise=_se[1.`miVar':`i'.Schl]
					}
					if `bina'==0 {
						local coefo=_b[`miVar':`i'.Schl]
						local mise=_se[`miVar':`i'.Schl]
					}
				
					local coef : di %6.2f `coefo'
					local miz= `coefo'/`mise'
					local star = ""
					if ((abs(`miz') > 1.645) ) local star = "^{*}" 
					if ((abs(`miz') > 1.96)  ) local star = "^{**}" 
					if ((abs(`miz') > 2.575) ) local star = "^{***}"  		
					disp "& $ `coef' `star' $ "
					tex & $ `coef' `star' $ 
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}		
		}
		tex \\
		
		forval mod=1(1)5 {
		
			est restore r`mod'	
			cap margins Schl , dydx(`miVar') post
			cap mat list e(b)			
			
			if `bina'==1 capture disp _se[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _se[`miVar':1.Schl]	
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {	
					if `bina'==1 local mise=_se[1.`miVar':`i'.Schl]	
					if `bina'==0 local mise=_se[`miVar':`i'.Schl]	
				
					local serr : di %6.2f `mise'
					tex & $ (`serr') $
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}	
		}	
		tex \\	
	}
	disp "REady 1st"
	
	* *****************************************
	tex \cmidrule(r){1-1} \cmidrule(r){2-4} \cmidrule(r){5-7} \cmidrule(r){8-10} \cmidrule(r){11-13}  \cmidrule(r){14-16}
	
	tex \rowcolor{Gray}
	tex Number of Obs.
	forval mod=1(1)5 {
		est restore r`mod'		
		local numObs = 	e(N)
		tex &  \multicolumn{3}{c}{`numObs'}
	}
	tex \\

	tex Number of Indiv.
	forval mod=1(1)5 {
		est restore r`mod'		
		local clust = e(N_clust)
		tex &  \multicolumn{3}{c}{`clust'} 
	}
	tex \\
	
	tex \rowcolor{Gray}
	tex LR $ \chi^2 test (df)[p-val] $
	forval mod=1(1)5 {
		est restore r`mod'		
		local chi2 : di %10.4f  e(chi2)
		local pchi2 : di %6.2f  e(p)
		local df = e(df_m)
		tex &  \multicolumn{3}{c}{`chi2' (`df')[`pchi2']}
	}
	tex \\
		
	tex Log-likelihood 
	forval mod=1(1)5 {
		est restore r`mod'	
		estat ic
		local logli = el(r(S),1,3)
		tex &  \multicolumn{3}{c}{`logli'}
	}
	tex \\
		
	tex \rowcolor{Gray}	
	tex AIC
	forval mod=1(1)5 {
		est restore r`mod'	
		estat ic
		local aic  : di %10.2f  el(r(S),1,5)
		tex &  \multicolumn{3}{c}{`aic'}
	}
	tex \\
		
	tex BIC
	forval mod=1(1)5 {
		est restore r`mod'	
		estat ic
		local bic  : di %10.2f  el(r(S),1,6)
		tex &  \multicolumn{3}{c}{`bic'}
	}
	tex \\

	tex \rowcolor{Gray}
	tex Percentage of LB hits / UB hits
	forval mod=1(1)5 {
		correlate lbound ubound pred`mod'
		local lbhits : di %6.2f el(r(C),3,1)*100
		local ubhits : di %6.2f el(r(C),3,2)*100		
		tex &  \multicolumn{3}{c}{`lbhits' / `ubhits' }
	}
	tex \\	
	

	tex \addlinespace[1.75ex]

	tex \bottomrule
	tex \addlinespace[.75ex]
	tex \multicolumn{16}{l}{Interval regression marginal effects calculated by the Delta method at the averages.} \\
	tex \multicolumn{16}{l}{Significance: * 10\%, ** 5\%, *** 1\%.}
	tex \end{tabularx}
	tex \end{adjustbox}
	tex \end{table}
	texdoc close

}	

* *********************************************************
* *********************************************************
* Premium determinants
* *********************************************************
* *********************************************************
if 1==0 {

use "$carpeta\baseRetornosSubjetivos.dta", clear

foreach val in tecnitecno profesional {
	gen premium`val'=inad_ingreso`val'> inad_ingresobto
}

tab premiumtecnitecno // 76%
tab premiumprofesional //86%

glo conts ///
	estu_edad masc disca ///
	INSE eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 ///
	ret16a11 wage11  ///
	ipmincid proprUrbRural homid pob oro    ///
	pri privado catSABER11two generoNMxto col12Math_mean col12Lang_mean totEs

probit premiumtecnitecno $conts , cluster(codcoleg)
	margins , dydx($conts) post	
est store g1

probit premiumprofesional $conts, cluster(codcoleg)
	margins , dydx($conts) post	
est store g2

	****************************************************************************
	* Latex table
	****************************************************************************
	cd "$tables"
	glo ncols=3
		texdoc init premiumDeterminants , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[h!]
		tex \centering
		tex \scriptsize		
		tex \caption{Correlates on the probability to report a premium \label{tab:premiumDeterminants}}
		tex \begin{tabular}{l*{$ncols}{c}}			
		tex \toprule
		tex & \multicolumn{1}{c}{ Vocational over HS } & \multicolumn{1}{c}{ Professional over HS } \\
		tex \midrule
		
		esttab g1 g2  using premiumDeterminants, star(* 0.1 ** 0.05 *** 0.01) varwidth(25) ///
			stats(N N_clust , label("Observations" "Schools (Cluster)"  )) ///
		    se fragment margin booktabs label append nomtitles nogaps

		tex \bottomrule
		tex \multicolumn{$ncols}{l}{\parbox[l]{10cm}{This table presents the marginal effects after a probit. ///
							The dependent variable of column 1(2) is a binary variable which takes the value of 1 ///
							when the expected earnings under the vocational (professional) ///
							studies scenario are above the ones for the high school scenario. ///
							Significance: * 10\%, ** 5\%, *** 1\%. }} \\

		tex \end{tabular}
		tex \end{table}
		tex }
		texdoc close
	****************************************************************************
}
* *********************************************************
* *********************************************************
* Private schools, according to cost
* *********************************************************
* *********************************************************
if 1==1 {
gen privateHigh = cole_inst_vlr_pension>3 & privado==1 if cole_inst_vlr_pension!=.
gen privateLow = cole_inst_vlr_pension<=3 & privado==1 if cole_inst_vlr_pension!=.

label var privateLow "Private, low cost"
label var privateHigh "Private, high cost"

intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r1
	predict pred1
	label var pred1 "Estimated Subjective Expected Income 1"
	

intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privateLow i.Schl#i.privateHigh i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	est store r2
	predict pred2
	label var pred2 "Estimated Subjective Expected Income 2"	
	



* *********************************************************
* 1. Estimation Output ( To be used when comparing with other models )
	texdoc init intervalsPrivate , replace force
	
	tex \begin{table}[H]
	tex \caption{Interval Regression: private schools alternative}
	tex \label{intervalsRob}
	tex \centering
	tex \renewcommand{\arraystretch}{0.8}% Tighter
	tex \begin{adjustbox}{max totalsize={1.3\textwidth}{1.3\textheight},center}
	tex \begin{tabularx} {20cm} {@{} l c c c c c c } \\
	tex \toprule 
	tex & \multicolumn{3}{c}{\parbox[c]{6cm}{Main Results}} & \multicolumn{3}{c}{\parbox[c]{5cm}{Private}}  \\
	tex & H.School & Voc. & Profess. & H.School & Voc. & Profess.  \\ 
	tex \cmidrule(r){2-4} \cmidrule(r){5-7}	
	
	* All Variables *******************	
	foreach miVar in 	privado privateLow privateHigh {
		
		local miTitulo : variable label `miVar'
		qui tab `miVar'	
		local bina=r(r)<3	
		disp "`miVar' is binary=`bina'"
		
		tex \rowcolor{Gray}
		tex $ \quad $ `miTitulo'
		
		forval mod=1(1)2 {
		
		disp "Modelo `mod'"
			est restore r`mod'	
			cap margins Schl , dydx(`miVar') post
			cap mat list e(b)			
			
			if `bina'==1 capture disp _b[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _b[`miVar':1.Schl]			
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {
					if `bina'==1 {			
						local coefo=_b[1.`miVar':`i'.Schl]
						local mise=_se[1.`miVar':`i'.Schl]
					}
					if `bina'==0 {
						local coefo=_b[`miVar':`i'.Schl]
						local mise=_se[`miVar':`i'.Schl]
					}
				
					local coef : di %6.2f `coefo'
					local miz= `coefo'/`mise'
					local star = ""
					if ((abs(`miz') > 1.645) ) local star = "^{*}" 
					if ((abs(`miz') > 1.96)  ) local star = "^{**}" 
					if ((abs(`miz') > 2.575) ) local star = "^{***}"  		
					disp "& $ `coef' `star' $ "
					tex & $ `coef' `star' $ 
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}		
		}
		tex \\
		
		forval mod=1(1)2 {
		
			est restore r`mod'	
			cap margins Schl , dydx(`miVar') post
			cap mat list e(b)			
			
			if `bina'==1 capture disp _se[1.`miVar':1.Schl]			
			if `bina'==0 capture disp _se[`miVar':1.Schl]	
			disp _rc
			if _rc == 0 { /* If the var IS in the model  */				
				forval i=1(1)3 {	
					if `bina'==1 local mise=_se[1.`miVar':`i'.Schl]	
					if `bina'==0 local mise=_se[`miVar':`i'.Schl]	
				
					local serr : di %6.2f `mise'
					tex & $ (`serr') $
				}
			}
			else {  /* If the var IS NOT in the model  */
				forval i=1(1)3 {
					tex &  				
				}			
			}	
		}	
		tex \\	
	}
	disp "REady 1st"
	
	* *****************************************
	tex \cmidrule(r){1-1} \cmidrule(r){2-4} \cmidrule(r){5-7}
	
	tex \rowcolor{Gray}
	tex Number of Obs.
	forval mod=1(1)2 {
		est restore r`mod'		
		local numObs = 	e(N)
		tex &  \multicolumn{3}{c}{`numObs'}
	}
	tex \\

	tex Number of Indiv.
	forval mod=1(1)2 {
		est restore r`mod'		
		local clust = e(N_clust)
		tex &  \multicolumn{3}{c}{`clust'} 
	}
	tex \\
	
	tex \rowcolor{Gray}
	tex LR $ \chi^2 test (df)[p-val] $
	forval mod=1(1)2 {
		est restore r`mod'		
		local chi2 : di %10.4f  e(chi2)
		local pchi2 : di %6.2f  e(p)
		local df = e(df_m)
		tex &  \multicolumn{3}{c}{`chi2' (`df')[`pchi2']}
	}
	tex \\
		
	tex Log-likelihood 
	forval mod=1(1)2 {
		est restore r`mod'	
		estat ic
		local logli = el(r(S),1,3)
		tex &  \multicolumn{3}{c}{`logli'}
	}
	tex \\
		
	tex \rowcolor{Gray}	
	tex AIC
	forval mod=1(1)2 {
		est restore r`mod'	
		estat ic
		local aic  : di %10.2f  el(r(S),1,5)
		tex &  \multicolumn{3}{c}{`aic'}
	}
	tex \\
		
	tex BIC
	forval mod=1(1)2 {
		est restore r`mod'	
		estat ic
		local bic  : di %10.2f  el(r(S),1,6)
		tex &  \multicolumn{3}{c}{`bic'}
	}
	tex \\

	tex \rowcolor{Gray}
	tex Percentage of LB hits / UB hits
	forval mod=1(1)2 {
		correlate lbound ubound pred`mod'
		local lbhits : di %6.2f el(r(C),3,1)*100
		local ubhits : di %6.2f el(r(C),3,2)*100		
		tex &  \multicolumn{3}{c}{`lbhits' / `ubhits' }
	}
	tex \\	
	

	tex \addlinespace[1.75ex]

	tex \bottomrule
	tex \addlinespace[.75ex]
	tex \multicolumn{7}{l}{Interval regression marginal effects calculated by the Delta method at the averages.} \\
	tex \multicolumn{7}{l}{Significance: * 10\%, ** 5\%, *** 1\%.}
	tex \end{tabularx}
	tex \end{adjustbox}
	tex \end{table}
	texdoc close

}
