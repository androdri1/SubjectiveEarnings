* Authors: Luis F. Gamboa & Paul Rodriguez-Lesmes
* Date: 2017.09.18

clear all
glo carpeta = "D:\Mis Documentos\git\SubjectiveEarnings"


do "$carpeta\do\00_Programs.do"
cd "$carpeta"
* Cargar datos del ICFES ***************************
use baseRetornosSubjetivos.dta, clear


cd "$carpeta/documento/tablas"

	
gen pri= periodo==20131
label var pri "First Semester"
	
gen ratSupBac=(ingNum_prof)/ingNum_bto
gen ratTecBac=(ingNum_tec)/ingNum_bto
gen ratSupTec=(ingNum_prof)/ingNum_tec

label var ratSupBac "Ratio College over HS"
label var ratTecBac "Ratio Tech over HS"
label var ratSupTec "Ratio College over Tech"

********************************************************************************

reg est_math tema_matematica
margins, at( tema_matematica=(0 30 50 70 100) ) post
/*Expression   : Linear prediction, predict() // These are the corresponding cutoffs of the question into the standardised measure
------------------------------------------------------------------------------
             |            Delta-method
             |     Margin   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         _at |
          1  |  -6.106604          .        .       .            .           .
          2  |  -2.230305          .        .       .            .           .
          3  |   .3538941          .        .       .            .           .
          4  |   2.938093          .        .       .            .           .
          5  |   6.814392          .        .       .            .           .
------------------------------------------------------------------------------
*/
gen lboundMath=_b[1._at] if estu_puntajematematicas==1
gen uboundMath=_b[2._at] if estu_puntajematematicas==1

replace lboundMath=_b[2._at] if estu_puntajematematicas==2
replace uboundMath=_b[3._at] if estu_puntajematematicas==2

replace lboundMath=_b[3._at] if estu_puntajematematicas==3
replace uboundMath=_b[4._at] if estu_puntajematematicas==3

replace lboundMath=_b[4._at] if estu_puntajematematicas==4
replace uboundMath=_b[5._at] if estu_puntajematematicas==4

********

reg est_leng tema_lenguaje, cluster(codcoleg)
margins, at( tema_lenguaje=(0 30 50 70 100) ) post
/*Expression   : Linear prediction, predict() // These are the corresponding cutoffs of the question into the standardised measure
------------------------------------------------------------------------------
             |            Delta-method
             |     Margin   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         _at |
          1  |  -6.106603          .        .       .            .           .
          2  |  -2.230305          .        .       .            .           .
          3  |   .3538941          .        .       .            .           .
          4  |   2.938093          .        .       .            .           .
          5  |   6.814392          .        .       .            .           .
------------------------------------------------------------------------------
*/

gen lboundLang=_b[1._at] if estu_puntajelenguaje==1
gen uboundLang=_b[2._at] if estu_puntajelenguaje==1

replace lboundLang=_b[2._at] if estu_puntajelenguaje==2
replace uboundLang=_b[3._at] if estu_puntajelenguaje==2

replace lboundLang=_b[3._at] if estu_puntajelenguaje==3
replace uboundLang=_b[4._at] if estu_puntajelenguaje==3

replace lboundLang=_b[4._at] if estu_puntajelenguaje==4
replace uboundLang=_b[5._at] if estu_puntajelenguaje==4


gen univLikely= estu_ingresaprograma>=3 if estu_ingresaprograma!=.
label var univLikely "Reports to be likely to enrol into tertiary education"

gen matLow=estu_puntajematematicas==2
gen matMed=estu_puntajematematicas==3
gen matHigh=estu_puntajematematicas==4
label var matLow "Expected low result"
label var matMed "Expected medium result"
label var matHigh "Expected high result"

gen lanLow=estu_puntajelenguaje==2
gen lanMed=estu_puntajelenguaje==3
gen lanHigh=estu_puntajelenguaje==4
label var lanLow "Expected low result"
label var lanMed "Expected medium result"
label var lanHigh "Expected high result"
	
glo controls ///
	estu_edad masc disca INSE eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 ///
	pri privado catSABER11two col12Math_mean col12Lang_mean totEs generoNMxto ///
	ret16a11 wage11 ipmincid proprUrbRural homid pob oro
	
	

////////////////////////////////////////////////////////////////////////////////
// Expected Test Scores (intervalreg)
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

intreg lboundLang uboundLang $controls, cluster(codcoleg)
	local N_clust=e(N_clust)	
margins , dydx(	$controls ) post
	estadd scalar N_clust = `N_clust'
	est store rX1
	

intreg lboundMath uboundMath  $controls , cluster(codcoleg)
	local N_clust=e(N_clust)	
margins , dydx($controls) post
	estadd scalar N_clust = `N_clust'
	est store rX2
	
probit univLikely  $controls , cluster(codcoleg )
	local N_clust=e(N_clust)	
margins , dydx($controls ) post
	estadd scalar N_clust = `N_clust'
	est store rX3

	
* *****************************************************************************	

qui {
	texdoc init expTestScoresDeter, replace force
	tex {
	tex \scriptsize
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	tex \begin{longtable}{l*{5}{c}}
		tex \caption{Expected academic outcomes and student, school and municipality characteristics \label{expTestScores}}\\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{1}{c}{Language} & \multicolumn{1}{c}{Mathematics} & \multicolumn{1}{c}{College Likely} \\
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)}  \\
		tex \midrule
	tex \endfirsthead
		tex \caption[]{(Continued)} \\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{1}{c}{Language} & \multicolumn{1}{c}{Mathematics} & \multicolumn{1}{c}{College Likely} \\
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)}   \\
		tex \midrule
	tex \endhead
		tex \midrule \multicolumn{5}{r}{\emph{Continued on next page}}
	tex \endfoot
		tex \bottomrule
		tex \multicolumn{5}{l}{\parbox[c]{13cm}{ ///
		     Columns 1 and 2 present marginal effects from a model using intervals of the expected SABER 11 test scores as outcomes. Column 3 presents marginal effects after a probit regression ///
			 where the outcome is whether the student considers it likely or very likely to enrol into college education. ///
			 SE clustered at school level. Significance: 99\% ***; 95\% **; 90\% *. }} \\
	tex \endlastfoot
}


foreach varDep in $controls { 

	loca fac=1
	local lname : variable label `varDep' // Label of the variables		
	* ********************************************

	sum `varDep', d
	local meand : disp  %6.2f r(mean)
	local sed : disp  %6.2f r(sd)		
	
	foreach i in 1 2 3 {
		est restore rX`i'
		myCoeff2 `i' `fac' "`varDep'"			
	}
	
	tex \rowcolor{Gray}
	tex \parbox[c]{5cm}{\raggedright `lname' } & `meand' &  $ ${coef1} ${star1} $ & $ ${coef2} ${star2} $ & $ ${coef3} ${star3} $   \\
	tex                                        & (`sed') &             $ ${se1} $ &            $ ${se2} $ &            $ ${se3} $   \\
	tex \addlinespace[1pt]	
}
tex \addlinespace[2pt]


* Statistics **********************************
foreach i in 1 2 3 {
	est restore rX`i'

	local stat2`i'=e(N)
	local stat4`i'=e(N_clust)
}

tex \rowcolor{Gray}
tex \parbox[c]{5cm}{N Observations }  & & `stat21' & `stat22' & `stat23'  \\
tex \parbox[c]{5cm}{N Clusters }      & & `stat41' & `stat42' & `stat43'   \\

	
* Close the table file *************************************
qui {
	tex \end{longtable}
	tex }
	texdoc close	
}

}






////////////////////////////////////////////////////////////////////////////////
// Test Scores as a function of income and test expectations
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

reg est_leng  ///
	$controls , cluster(codcoleg)
	estadd  ysumm
	est store rX1
	
reg est_leng ratSupBac ratSupTec univLikely lanLow  lanMed lanHigh ///
	$controls , cluster(codcoleg)
	estadd  ysumm
	est store rX2	

reg est_leng ratSupBac ratSupTec univLikely lanLow  lanMed lanHigh ///
	, cluster(codcoleg)
	estadd  ysumm
	est store rX4
	
	
reg est_math  /// // ratTecBac
	$controls , cluster(codcoleg)
	estadd  ysumm
	est store rX5
	
reg est_math ratSupBac ratSupTec univLikely matLow matMed matHigh /// // ratTecBac
	$controls , cluster(codcoleg)
	estadd  ysumm
	est store rX6	

reg est_math ratSupBac ratSupTec univLikely matLow matMed matHigh /// // ratTecBac
	 , cluster(codcoleg)
	estadd  ysumm
	est store rX7	
	
* *****************************************************************************	

qui {
	texdoc init testScores, replace force
	tex {
	tex \scriptsize
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	tex \begin{longtable}{l*{8}{c}}
		tex \caption{Subjective expected earnings, academic outputs, and Test Scores \label{testScores}}\\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{3}{c}{Language} & \multicolumn{3}{c}{Mathematics} \\
		tex \cmidrule(r){3-4} \cmidrule(r){5-6} \cmidrule(r){7-8}
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)}  \\
	tex \endfirsthead
		tex \caption[]{(Continued)} \\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{3}{c}{Language} & \multicolumn{3}{c}{Mathematics} \\
		tex \cmidrule{3-4} \cmidrule{5-6}	 \cmidrule(r){7-8}	
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)}  \\
	tex \endhead
		tex \midrule \multicolumn{8}{r}{\emph{Continued on next page}}
	tex \endfoot
		tex \bottomrule
		tex \multicolumn{8}{l}{\parbox[c]{15cm}{Estimates from Ordinary least squares regressions. ///
		     SE clustered at school level. Dependant variables, in the columns, are standarized SABER 11 test scores. ///
			 Independent variables, in the rows, include ratios derived from the subjective income expectations, where the medium value is assigned to each response category. ///
			 Significance: 99\% ***; 95\% **; 90\% *. }} \\
	tex \endlastfoot
	tex \cmidrule{3-4} \cmidrule{5-6} \cmidrule(r){7-8}
}

foreach varDep in ratSupBac ratSupTec univLikely matLow matMed matHigh lanLow lanMed lanHigh $controls { // ratTecBac

	loca fac=1
	local lname : variable label `varDep' // Label of the variables		
	* ********************************************

	sum `varDep', d
	local meand : disp  %6.2f r(mean)
	local sed : disp  %6.2f r(sd)
	
	foreach i in 1 2 4 5 6 7 {
		est restore rX`i'
		myCoeff2 `i' `fac' "`varDep'"			
	}
	
	tex \rowcolor{Gray}
	tex \parbox[c]{4cm}{\raggedright `lname' } & `meand' &  $ ${coef1} ${star1} $ & $ ${coef2} ${star2} $ &  $ ${coef4} ${star4} $ & $ ${coef5} ${star5} $ & $ ${coef6} ${star6} $ & $ ${coef7} ${star7} $  \\
	tex                                        & (`sed') &             $ ${se1} $ &            $ ${se2} $ &            $ ${se4} $ &            $ ${se5} $ &            $ ${se6} $ &            $ ${se7} $  \\
	tex \addlinespace[1pt]	
}
tex \addlinespace[2pt]


* Statistics **********************************
foreach i in 1 2 4 5 6 7 {
	est restore rX`i'

	local stat0`i': di %7.2f e(ymean)
	local stat1`i': di %7.2f e(ysd)
	local stat2`i'=e(N)
	local stat3`i': di %7.2f  e(r2)
	local stat4`i'=e(N_clust)
}

tex \rowcolor{Gray}
tex \parbox[c]{4cm}{N Observations }  & & `stat21' & `stat22' & `stat24' & `stat25' & `stat26' & `stat27'  \\
tex \parbox[c]{4cm}{N Clusters }      & & `stat41' & `stat42' & `stat44' & `stat45' & `stat46' & `stat47'   \\
tex \rowcolor{Gray}
tex \parbox[c]{4cm}{$ R^2$ }          & & `stat31' & `stat32' & `stat34' & `stat35' & `stat36' & `stat37' \\	

* Close the table file *************************************
qui {
	tex \end{longtable}
	tex }
	texdoc close	
}

}






////////////////////////////////////////////////////////////////////////////////
// Test Scores with private 
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

glo controlsGG ///
	estu_edad masc disca INSE eduPadre_1 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_3 eduMadre_4 ///
	pri catSABER11two col12Math_mean col12Lang_mean totEs generoNMxto ///
	ret16a11 wage11 ipmincid proprUrbRural homid pob oro

gen privateHigh = cole_inst_vlr_pension>3 & privado==1 if cole_inst_vlr_pension!=.
gen privateLow = cole_inst_vlr_pension<=3 & privado==1 if cole_inst_vlr_pension!=.

label var privateLow "Private, low cost"
label var privateHigh "Private, high cost"


reg est_leng ratSupBac ratSupTec univLikely lanLow  lanMed lanHigh ///
	$controlsGG privado , cluster(codcoleg)
	estadd  ysumm
	est store rX1

reg est_leng ratSupBac ratSupTec univLikely lanLow  lanMed lanHigh ///
	$controlsGG privateLow privateHigh , cluster(codcoleg)
	estadd  ysumm
	est store rX2		
	
reg est_math ratSupBac ratSupTec univLikely matLow matMed matHigh /// // ratTecBac
	$controlsGG privado , cluster(codcoleg)
	estadd  ysumm
	est store rX3	
	
reg est_math ratSupBac ratSupTec univLikely matLow matMed matHigh /// // ratTecBac
	$controlsGG privateLow privateHigh , cluster(codcoleg)
	estadd  ysumm
	est store rX4		
	
	tab privateLow if e(sample)==1
	tab privateHigh if e(sample)==1
	
* *****************************************************************************	

qui {
	texdoc init testScoresPriv, replace force
	tex {
	tex \scriptsize
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	tex \begin{longtable}{l*{6}{c}}
		tex \caption{Subjective expected earnings, academic outputs, and Test Scores \label{testScores}}\\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{2}{c}{Language} & \multicolumn{2}{c}{Mathematics} \\
		tex \cmidrule(r){3-4} \cmidrule(r){5-6}
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)}  \\
	tex \endfirsthead
		tex \caption[]{(Continued)} \\
		tex \toprule
		tex & $ \bar{X} $ & \multicolumn{2}{c}{Language} & \multicolumn{2}{c}{Mathematics} \\
		tex \cmidrule{3-4} \cmidrule{5-6}		
		tex Independent Variables & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)}  \\
	tex \endhead
		tex \midrule \multicolumn{6}{r}{\emph{Continued on next page}}
	tex \endfoot
		tex \bottomrule
		tex \multicolumn{6}{l}{\parbox[c]{13cm}{Estimates from Ordinary least squares regressions. ///
		     SE clustered at school level. Dependant variables, in the columns, are standarized SABER 11 test scores. ///
			 Independent variables, in the rows, include ratios derived from the subjective income expectations, where the medium value is assigned to each response category. ///
			 In Panel B, regressions include controls on students, family and counties characteristics (see data section for more details). Significance: 99\% ***; 95\% **; 90\% *. }} \\
	tex \endlastfoot
	tex \cmidrule{3-4} \cmidrule{5-6}
}

foreach varDep in privado privateLow privateHigh { // ratTecBac

	loca fac=1
	local lname : variable label `varDep' // Label of the variables		
	* ********************************************

	sum `varDep', d
	local meand : disp  %6.2f r(mean)
	local sed : disp  %6.2f r(sd)
	
	foreach i in 1 2 3 4 {
		est restore rX`i'
		myCoeff2 `i' `fac' "`varDep'"			
	}
	
	tex \rowcolor{Gray}
	tex \parbox[c]{4cm}{\raggedright `lname' } & `meand' &  $ ${coef1} ${star1} $ & $ ${coef2} ${star2} $ &  $ ${coef3} ${star3} $ & $ ${coef4} ${star4} $  \\
	tex                                        & (`sed') &             $ ${se1} $ &            $ ${se2} $ &            $ ${se3} $ &            $ ${se4} $  \\
	tex \addlinespace[1pt]	
}
tex \addlinespace[2pt]


* Statistics **********************************
foreach i in 1 2 3 4 {
	est restore rX`i'

	local stat0`i': di %7.2f e(ymean)
	local stat1`i': di %7.2f e(ysd)
	local stat2`i'=e(N)
	local stat3`i': di %7.2f  e(r2)
	local stat4`i'=e(N_clust)
}

tex \rowcolor{Gray}
tex \parbox[c]{4cm}{N Observations }  & & `stat21' & `stat22' & `stat23' & `stat24'  \\
tex \parbox[c]{4cm}{N Clusters }      & & `stat41' & `stat42' & `stat43' & `stat44'   \\
tex \rowcolor{Gray}
tex \parbox[c]{4cm}{$ R^2$ }          & & `stat31' & `stat32' & `stat33' & `stat34'  \\	

* Close the table file *************************************
qui {
	tex \end{longtable}
	tex }
	texdoc close	
}

}




