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


gen ratSupBac=(ingNum_prof)/ingNum_bto
gen ratTecBac=(ingNum_tec)/ingNum_bto
gen ratSupTec=(ingNum_prof)/ingNum_tec

label var ratSupBac "Ratio College over HS"
label var ratTecBac "Ratio Tech over HS"
label var ratSupTec "Ratio College over Tech"

////////////////////////////////////////////////////////////////////////////////
// Graphic: Observed and Expected earnings by level of education (Figure 3)
if 1==1 { // Graphs on labour markets and expected earnings
	glo genOpts="  graphregion(color(white) lwidth(medium)) scheme(lean2)"		

	* Graph!
	replace inguniversi20_3013=inguniversi20_3013/1000
	replace inguniversi20_3012=inguniversi20_3012/1000
	replace ingtecnico20_3013=ingtecnico20_3013/1000
	replace ingtecnico20_3012=ingtecnico20_3012/1000
	replace ingNothing20_3013=ingNothing20_3013/1000
	replace ingNothing20_3012=ingNothing20_3012/1000


	tw (lpolyci ingNum_prof  inguniversi20_3013 , bw(100) ) (lpolyci ingNum_prof  inguniversi20_3012 , bw(100) ) , $genOpts title(College) name(a1, replace) legend(order(2 "Labour income 2013, ages 20 to 30" 3 "Labour income 2012, ages 20 to 30") pos(5)) xtitle("Observed, 1000 COP") ytitle("Expected, 1000 COP")
	tw (lpolyci ingNum_tec  ingtecnico20_3013 , bw(100)) (lpolyci ingNum_tec  ingtecnico20_3012 , bw(100)) , $genOpts  title(Vocational) name(a2, replace) legend(order(2 "Labour income 2013, ages 20 to 30" 3 "Labour income 2012, ages 20 to 30") pos(5)) xtitle("Observed, 1000 COP") ytitle("Expected, 1000 COP")
	tw (lpolyci ingNum_prof  ingNothing20_3013 , bw(100)) (lpolyci ingNum_prof  ingNothing20_3012 , bw(100)) , $genOpts  title(High School) name(a3, replace) legend(order(2 "Labour income 2013, ages 20 to 30" 3 "Labour income 2012, ages 20 to 30") pos(5)) xtitle("Observed, 1000 COP") ytitle("Expected, 1000 COP")

	grc1leg a1 a2 a3, $genOpts caption("Smoothed local linear averages (bandwidth=100), Epanechnikov kernel. Includes 95% CI.")
	graph export "$carpeta\documento\imagenes\localpolWages.pdf", as(pdf) replace
}

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
label define schol 1 "Secondary School Graduate" 2 "Vocational Education Gradutate" 3 "University Education Graduate"
label values Schl schol

* Check differences on the mean

reg ing i.Schl
/*
-------------------------------------------------------------------------------------------------
                         ingNum |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------------------+----------------------------------------------------------------
                           Schl |
Vocational Education Gradutate  |   708.4628   8.731589    81.14   0.000     691.3491    725.5766
 University Education Graduate  |   2256.466   8.731589   258.43   0.000     2239.353     2273.58
                                |
                          _cons |   758.2908   6.174166   122.82   0.000     746.1895     770.392
-------------------------------------------------------------------------------------------------
*/
reg ing i.Schl if Schl>1
/*
                        ingNum |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------------------------+----------------------------------------------------------------
                          Schl |
University Education Graduate  |   1548.004   9.553515   162.03   0.000     1529.279    1566.728
                         _cons |   1466.754   6.755355   217.12   0.000     1453.513    1479.994
------------------------------------------------------------------------------------------------
*/

* *********************************************************
* *********************************************************
* Intervals Regresion
* *********************************************************
* *********************************************************

intreg lbound ubound  i.Schl  ///
	i.Schl#c.estu_edad i.Schl#i.masc i.Schl#i.disca ///
	i.Schl#c.INSE i.Schl#i.eduPadre_1 i.Schl#i.eduPadre_3 i.Schl#i.eduPadre_4 i.Schl#i.eduMadre_1 i.Schl#i.eduMadre_3 i.Schl#i.eduMadre_4 ///
	i.Schl#c.ret16a11 i.Schl#c.wage11  ///
	i.Schl#c.ipmincid i.Schl#c.proprUrbRural i.Schl#c.homid i.Schl#c.pob i.Schl#i.oro    ///
	i.Schl#i.pri i.Schl#i.privado i.Schl#i.catSABER11two i.Schl#i.generoNMxto i.Schl#c.col12Math_mean i.Schl#c.col12Lang_mean i.Schl#c.totEs  ///
	, cluster(insc_id)
	
	est store rX
	predict pred
	label var pred "Estimated Subjective Expected Income"

preserve
	keep if e(sample)==1
	keep insc_id muestra
	save "$carpeta/miMuestra.dta", replace
restore	
	
	
	
	* c.totEs
	* *********************************************************
	preserve
		reshape wide ing ingNum lbound ubound pred, i(insc_id) j(Schl)
		keep insc_id pred*
		label var pred1 "Predicted wages: High School"
		label var pred2 "Predicted wages: Vocational Ed."
		label var pred3 "Predicted wages: College"	
		save "$carpeta\results.dta", replace
		
	restore	
*/


* *********************************************************
* 2. Marginal effects >>> The resulting table has to be ordered afterwards!!! Sorry!
*

qui {
	texdoc init marginsInterval, replace force
	tex {
	tex \scriptsize
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	tex \begin{longtable}{l*{7}{c}}
		tex \caption{Interval Regression Marginal Effects \label{marginsTestsInterval}}\\
		tex \toprule
		tex & \multicolumn{3}{c}{A. Income Levels} & & \multicolumn{2}{c}{B. Ratio $ R_{s,0}$ } \\
		tex Ed. Level: & High School & Vocational & Professional & & Vocational & Professional \\
		tex \cmidrule{2-4} \cmidrule{6-7}
	tex \endfirsthead
		tex \caption[]{(Continued)} \\
		tex \toprule
		tex & \multicolumn{3}{c}{A. Income Levels} & & \multicolumn{2}{c}{B. Ratio $ R_{s,0}$ } \\
		tex Ed. Level: & High School & Vocational & Professional & & Vocational & Professional \\
		tex \cmidrule{2-4} \cmidrule{6-7}
	tex \endhead
		tex \midrule \multicolumn{7}{r}{\emph{Continued on next page}}
	tex \endfoot
		tex \bottomrule
		tex \multicolumn{7}{l}{\parbox[c]{14cm}{Calculated by the Delta method at the averages. ///
		     SE clustered at individual level. Significance: 99\% ***; 95\% **; 90\% *. }} \\
	tex \endlastfoot
}
		
	* Continuous Variables *******************	
	foreach miVar in  estu_edad ///
					INSE   ///
					ret16a11 wage11  ///
					ipmincid proprUrbRural homid pob  ///
					  col12Math_mean col12Lang_mean totEs  {
		
		qui sum ingNum if Schl==1
		local w0=r(mean)
		qui sum ingNum if Schl==2
		local w12=r(mean)
		qui sum ingNum if Schl==3
		local w13=r(mean)

		est restore rX
		margins Schl, dydx(`miVar') post
*		nlcom (Dev2: ((_b[`miVar':2.Schl]-_b[`miVar':1.Schl])*`w0'-_b[`miVar':1.Schl]*(`w12'-`w0'))/(`w0'^2)  )  ///
*			  (Dev3: ((_b[`miVar':3.Schl]-_b[`miVar':1.Schl])*`w0'-_b[`miVar':1.Schl]*(`w13'-`w0'))/(`w0'^2)  ) 

		* The ratio, rather than the "return"
		nlcom (Dev2: (_b[`miVar':2.Schl]*`w0'-_b[`miVar':1.Schl]*`w12')/(`w0'^2)  )  ///
			  (Dev3: (_b[`miVar':3.Schl]*`w0'-_b[`miVar':1.Schl]*`w13')/(`w0'^2)  ) 

			  
		matrix CO = r(b)
		matrix VA = vecdiag(r(V))		
		
		est restore rX
		local miTitulo : variable label `miVar'
		
		tex \rowcolor{Gray}
		tex $ \quad $ `miTitulo'
		forval i=1(1)5 {
			if `i'==4 tex &
			if `i'<4 {
				local coefo=_b[model:`i'.Schl#c.`miVar']
				local mise=_se[model:`i'.Schl#c.`miVar']
			}
			if `i'>=4 {
				local coefo = CO[1,`i'-3]*100
				local mise  = (VA[1,`i'-3]^0.5)*100
			}
		
			local coef : di %6.2f `coefo'
			local miz= `coefo'/`mise'
			local star = ""
			if ((abs(`miz') > 1.645) ) local star = "^{*}" 
			if ((abs(`miz') > 1.96)  ) local star = "^{**}" 
			if ((abs(`miz') > 2.575) ) local star = "^{***}"  		
		
			tex & $ `coef' `star' $ 
		}
		tex \\
		forval i=1(1)5 {	
			if `i'==4 tex &
			if `i'<4 {
				local mise=_se[model:`i'.Schl#c.`miVar']
			}
			if `i'>=4 {
				local mise  = (VA[1,`i'-3]^0.5)*100
			}		

			local serr : di %6.2f `mise'
			tex & $ (`serr') $
		}
		tex \\	
	}
*	texdoc init marginsInterval , append
		
	* Discrete Variables *******************
	foreach miVar in  masc disca eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 oro privado catSABER11two generoNMxto   {
	                  
		qui sum ingNum if Schl==1
		local w0=r(mean)
		qui sum ingNum if Schl==2
		local w12=r(mean)
		qui sum ingNum if Schl==3
		local w13=r(mean)

		est restore rX
		margins Schl, dydx(`miVar') post
*		nlcom (Dev2:  (`w12'+ _b[1.`miVar':2.Schl])/(`w0'+ _b[1.`miVar':1.Schl]) - `w12'/`w0' ) ///
*			  (Dev3:  (`w13'+ _b[1.`miVar':3.Schl])/(`w0'+ _b[1.`miVar':1.Schl]) - `w13'/`w0' ) 

		* The ratio, rather than the "return"
		nlcom (Dev2: (_b[1.`miVar':2.Schl]*`w0'-_b[1.`miVar':1.Schl]*`w12')/(`w0'^2)  )  ///
			  (Dev3: (_b[1.`miVar':3.Schl]*`w0'-_b[1.`miVar':1.Schl]*`w13')/(`w0'^2)  ) 
			  
		matrix CO = r(b)
		matrix VA = vecdiag(r(V))	
		
		est restore rX	  
		local miTitulo : variable label `miVar'
		
		tex \rowcolor{Gray}
		tex $ \quad $ `miTitulo'
		forval i=1(1)5 {
			if `i'==4 tex &
			if `i'<4 {
			local coefo=_b[model:`i'.Schl#1.`miVar']
			local mise=_se[model:`i'.Schl#1.`miVar']
			}
			if `i'>=4 {
				local coefo = CO[1,`i'-3]*100
				local mise  = (VA[1,`i'-3]^0.5)*100
			}		
		
			local coef : di %6.2f `coefo'
			local miz= `coefo'/`mise'
			local star = ""
			if ((abs(`miz') > 1.645) ) local star = "^{*}" 
			if ((abs(`miz') > 1.96)  ) local star = "^{**}" 
			if ((abs(`miz') > 2.575) ) local star = "^{***}"  		
		
			tex & $ `coef' `star' $ 
		}
		tex \\
		forval i=1(1)5 {
			if `i'==4 tex &
			if `i'<4 {
				local mise=_se[model:`i'.Schl#1.`miVar']
			}
			if `i'>=4 {
				local mise  = (VA[1,`i'-3]^0.5)*100
			}			
		
			local serr : di %6.2f `mise'
			tex & $ (`serr') $
		}
		tex \\	
	}	
	* Constants ********************************
	tex Constants &
	forval i=2(1)3 {
		local coefo=_b[model:`i'.Schl]
		local coef : di %6.2f `coefo'
		tex & $ `coef' `star' $ 
	}
	tex & & & \\

	* *****************************************
	tex \midrule
	
	local chi2 : di %10.4f  e(chi2)
	local pchi2 : di %6.2f  e(p)
	local df = e(df_m)
	local clust = e(N_clust)
	local numObs = 	e(N)

	tex \rowcolor{Gray}
	tex Number of Obs. &  \multicolumn{6}{c}{`numObs'} \\
	tex Number of Indiv. &  \multicolumn{6}{c}{`clust'} \\
	tex \rowcolor{Gray}
	tex LR $ \chi^2 $ (`df') test [p-val] & \multicolumn{6}{c}{`chi2' [`pchi2']} \\

	estat ic

	local aic  : di %10.2f  el(r(S),1,5)
	local bic  : di %10.2f  el(r(S),1,6)
	local logli = el(r(S),1,3)
	
	tex Log-likelihood & \multicolumn{6}{c}{`logli'} \\	
	tex \rowcolor{Gray}
	tex AIC &  \multicolumn{6}{c}{`aic'} \\
	tex BIB &  \multicolumn{6}{c}{`bic'} \\
	

	correlate lbound ubound pred
	local lbhits : di %6.2f el(r(C),3,1)*100
	local ubhits : di %6.2f el(r(C),3,2)*100
	
	tex \rowcolor{Gray}
	tex Percentage of LB hits / UB hits  &  \multicolumn{6}{c}{`lbhits' / `ubhits' } \\
	
	
* Close the table file *************************************
qui {
	tex \end{longtable}
	tex }
	texdoc close	
}	
