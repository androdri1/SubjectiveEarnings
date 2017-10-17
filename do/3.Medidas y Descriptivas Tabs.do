* Authors: Luis F. Gamboa & Paul Rodriguez-Lesmes
* Date: 2017.09.18
* Notes: tables on this file are restricted to the sample dataset only, thus
*        school and muicipality level averages which replicate the entire Saber
*        2013 dataset cannot be produced here (missings table from the appendix 
*        cannot be replicated in any portion). Such dataset has to be requested
*        directly to ICFES (Saber 11 data for 2013-I and 2013-II, including 
*        subjective beliefs sample)

clear all

glo carpeta = "D:\Mis Documentos\git\SubjectiveEarnings"


do "$carpeta\do\00_Programs.do"

* ****************************************************************************
use "$carpeta\baseRetornosSubjetivos.dta", clear

cd "$carpeta\documento\tablas"

////////////////////////////////////////////////////////////////////////////////
// Grafico Distribution of Subjective Expected Earnings (Figure 1)
////////////////////////////////////////////////////////////////////////////////
if 1==0 {

cd "$carpeta\documento\imagenes"

label define vals 1 " " 2 "<1 "   3 "1-2 " 4 "2-3 " 5 "3-4  " 6 "4-5  " 7 "5-7 " 8 "7-8 "  9 "8-10 " 10 "10+ ", replace
foreach wordo in tecnitecno profesional bto {
	recode inad_ingreso`wordo' (1=1) (2=2) (3=4) (4=6) (5=8) (6=9), gen( EXSal`wordo')
	label values EXSal`wordo' vals
}

twoway (hist EXSaltecnitecno, discrete percent yscale(range(0 60)) ) ///
       (hist EXSalbto, discrete fcolor(none) lcolor(black) percent  ) ///
	   if muestra==1, legend(order(1 "Vocational" 2 "High School") pos(5)) scheme(lean2) name(a1, replace) title(Vocational) xtitle(Income in Minimum wages) ytitle(%) xmtick(1(1)10, angle(two_seventy) valuelabel) xlabel(1(1)10, angle(forty_five) valuelabel) 

twoway (hist EXSalprofesional, discrete percent yscale(range(0 60))) ///
       (hist EXSalbto, discrete fcolor(none) lcolor(black) percent ) ///
	   if muestra==1, legend(order(1 "College" 2 "High School") pos(5) ) scheme(lean2) name(a2, replace) title(College) xtitle(Income in Minimum wages) ytitle(%) xmtick(1(1)10, angle(two_seventy) valuelabel) xlabel(1(1)10, angle(forty_five) valuelabel) 
	
graph combine a1 a2, scheme(lean2)  ycommon // caption(Note:Income is ploted in Minimun Wages intervals. Own calculations based on ICFES expectations survey. ) 
graph export "distribucionIngresos.pdf", as(pdf) replace 
xx
hist INSE if muestra==1, percent scheme(lean2)
graph export "distribucionINSE.pdf", as(pdf) replace			

}

////////////////////////////////////////////////////////////////////////////////
// Grafico Distribution Expected vs. Observed Earnings (Figure 2)
////////////////////////////////////////////////////////////////////////////////
if 1==0 {

cd "$carpeta\documento\imagenes"

label define vals 1 "<1 " 2 "1-2" 3 "2-3" 4 "3-4" 5 "4-5  " 6 "5-7 " 7 "7-8 "  8 "8-10 " 9 "10+ ", replace // Exactly as in 0.salarios2011a2013
foreach wordo in tecnitecno profesional bto {
	cap recode inad_ingreso`wordo' (1=1) (2=2) (3=4) (4=6) (5=8) (6=9), gen( EXSal`wordo')
	label values EXSal`wordo' vals	
}

preserve
	append using "$carpeta\otrosDatos\Figure2ObsWages.dta" 

	twoway (hist EXSalbto, discrete percent yscale(range(0 60)) ) ///
		   (hist cingObs_bto  , discrete fcolor(none) lcolor(black) percent  ) ///
		   if muestra==1, legend(order(1 "Expected" 2 "Observed") pos(5) cols(2)) scheme(lean2) name(a1, replace) title(High School Only) xtitle(Income in Minimum wages) ytitle(%) xmtick(1(1)9, angle(two_seventy) valuelabel) xlabel(1(1)9, angle(forty_five) valuelabel) 

	twoway (hist EXSalprofesional, discrete percent yscale(range(0 60))) ///
		   (hist cingObs_profesional , discrete fcolor(none) lcolor(black) percent ) ///
		   if muestra==1, legend(order(1 "Expected" 2 "Observed") pos(5) cols(2)) scheme(lean2) name(a2, replace) title(College) xtitle(Income in Minimum wages) ytitle(%) xmtick(1(1)9, angle(two_seventy) valuelabel) xlabel(1(1)9, angle(forty_five) valuelabel) 

	twoway (hist EXSaltecnitecno, discrete percent yscale(range(0 60))) ///
		   (hist cingObs_tecnitecno , discrete fcolor(none) lcolor(black) percent ) ///
		   if muestra==1, legend(order(1 "Expected" 2 "Observed") pos(5) cols(2)) scheme(lean2) name(a3, replace) title(Vocational) xtitle(Income in Minimum wages) ytitle(%) xmtick(1(1)9, angle(two_seventy) valuelabel) xlabel(1(1)9, angle(forty_five) valuelabel) 
   		   
	grc1leg a1 a2, scheme(lean2)  ycommon // caption(Note:Income is ploted in Minimum Wages intervals. Own calculations based on ICFES expectations survey. ) 
	graph export "distriIngExpObs.pdf", as(pdf) replace 
	
	grc1leg a1 a2 a3, scheme(lean2)  ycommon // caption(Note:Income is ploted in Minimum Wages intervals. Own calculations based on ICFES expectations survey. ) 
	graph export "distriIngExpObsALL.pdf", as(pdf) replace 	

restore
}


* mapas se hacen en ArcMap utilizando lo que está en la carpeta de los mapas
* El mapa lo descargué de SIG-OT y lo transformé para que San Andrés y Providencia se vieran y
* para que el departamento "NN" (por alguna razón aparece suelto un pedazo entre huila y cauca)
* quedara pegado al huila

* 4. Construir tablas Descriptivas
cd "$carpeta\documento\tablas"

////////////////////////////////////////////////////////////////////////////////
// Avg expectations according to covariates
////////////////////////////////////////////////////////////////////////////////
if 1==0 { // Table not in use, is redundant to the interval regression

	qui { 
		texdoc init categoriasCovars , replace force
		tex \begin{table}[H]
		tex \caption{Expected Income Categories by Covariates}
		tex \label{retornosCovars}
		tex \centering
		tex \scalebox{0.7}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
		tex \begin{tabularx} {17cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \toprule
		tex  & & & \multicolumn{2}{c}{\textbf{High School}} & \multicolumn{2}{c}{\textbf{Technical}}  & \multicolumn{2}{c}{\textbf{College}} \\
		tex \textbf{Variables} & \textbf{N.} & \textbf{\%} & \textbf{1-2}& \textbf{5-6} & \textbf{1-2}& \textbf{5-6} & \textbf{1-2} & \textbf{5-6} \\
		tex \cmidrule(r){4-5} \cmidrule(r){6-7} \cmidrule(r){8-9}
	}
			
		foreach vari in genero eduPadre eduMadre pubPrivado categSABER11  {	
			cap drop myVar_*
		
			local miTitulo : variable label `vari'
			local miLabel : value label `vari'
			
			tex \multicolumn{9}{l}{\textbf{`miTitulo'}} \\
			tab `vari', gen(myVar_)
			local totCat=r(r)
			
			forval i=1(1)`totCat' {
				local miTitulito : label `miLabel' `i'
				
				count if  myVar_`i'==1 & muestra==1
				local obs=r(N)
				count if  `vari'!=. & muestra==1
				local totObs=r(N)
				local percent = `obs'*100/`totObs'
				local percent : di %7.1f `percent'
				tex $\quad $ `miTitulito' & `obs' & `percent'\%
				*foreach var in dBa1 dBa2 dBa3 dTe1 dTe2 dTe3 dCo1 dCo2 dCo3 {
				foreach var in dBa1 dBa3 dTe1 dTe3 dCo1 dCo3 {
					sum `var' if  myVar_`i'==1 & muestra==1
					local mean : di %6.1f r(mean)*100
					tex & `mean'
				}
				tex \\
			}
		}

		tex \midrule
		* National level
		count if muestra==1
		local obs=r(N)
		tex Total & `obs' & 100\%
		foreach var in dBa1 dBa3 dTe1 dTe3 dCo1 dCo3 {
			sum `var' if muestra==1
			local mean : di %6.1f r(mean)*100
			tex & `mean'
		}
		tex \\	
		
	qui {
		tex \bottomrule
		tex \multicolumn{9}{l}{Source: Own calculations based on a 10\% student sample from SABER 11 2013-II.} \\
		tex \multicolumn{9}{l}{$ \dagger$ data from ICFES oficial classification for 2010 if 2011 is not available.} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}
	
}


////////////////////////////////////////////////////////////////////////////////
// Descriptive tables
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
	glo varsC1 = "tema_lenguaje tema_matematica estu_edad INSE"
	glo varsC2 = "col12Math_mean col12Lang_mean totEs"
	glo varsC3 = "ret16a11 wage11 ipmincid proprUrbRural homid pob"
	
	glo varsD1 = "masc disca eduPadre_1 eduPadre_2 eduPadre_3 eduPadre_4 eduMadre_1 eduMadre_2 eduMadre_3 eduMadre_4"
	glo varsD2 = "pri privado generoNMxto catSABER11two "
	glo varsD3 = "oro"
	
	
	glo title1 = "Student and family level"
	glo title2 = "School level"
	glo title3 = "Municipality level"
	
	glo conda1 = "estu_consecutivo"
	glo conda2 = "codcoleg"
	glo conda3 = "codigomunicipio"	

		
	qui {
		texdoc init descriptives1 , replace force
		tex \begin{table}[H]
		tex \caption{Descriptive Statistics I}
		tex \label{descriptives1}
		tex \centering
		tex \scalebox{0.7}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
		tex \begin{tabularx} {21cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \toprule
		tex  & Population & \multicolumn{7}{c}{Survey Sample} \\
		tex \textbf{Continuous Variables} & \textbf{Mean} & \textbf{Mean $  \diamond$ } & \textbf{SD} & \textbf{Min} & \textbf{P10} & \textbf{P50} & \textbf{P90} & \textbf{Max}\\
		tex \cmidrule(l){2-2} \cmidrule(l){3-9}
	}
		forval k=1(1)1 { // Level of covariates			
			preserve
				duplicates drop ${conda`k'}, force
				count if InBase==1
				local eneSam = r(N) 
				tex \multicolumn{9}{l}{\textbf{${title`k'}} (n=`eneSam') } \\
								
				foreach vari in ${varsC`k'}  {	// For each covariate
				
					local miTitulo : variable label `vari'

					qui sum `vari' if muestra==1 & InBase==1, d
					local eneSam = r(N) 
					local mean : di %6.2f r(mean) 
					local sd   : di %6.2f r(sd)
					local min : di %6.2f r(min) 
					local p10 : di %6.2f r(p10) 
					local p50 : di %6.2f r(p50) 
					local p90 : di %6.2f r(p90) 
					local max : di %6.2f r(max)

					qui sum `vari'
					local meanPop : di %6.2f r(mean) 		
					local enePop = r(N) 
					qui reg `vari' InBase
					myCoeff2 1 1 "InBase"
					
					tex $ \quad $ `miTitulo' & `meanPop' & `mean' $ $star1$ & `sd' & `min' & `p10' & `p50' & `p90' & `max' \\
				
				}
			restore
		}
		
		tex \midrule	
		qui sum muestra, d
		local ene = r(N) 	
		tex \textbf{Total Ind.} & `enePop' & `eneSam' &  & & &  & \\

	qui {
		tex \bottomrule
		tex \multicolumn{9}{l}{Source: Own calculations based on a 10\% student sample from SABER 11 2013-II.} \\
		tex \multicolumn{9}{l}{$ \dagger$ data from ICFES official classification for 2010 if 2011 is not available.} \\
		tex \multicolumn{9}{l}{\parbox[c]{21cm}{$ \diamond$ Starts show the significance of a test checking if the difference between the sampled and non-sampled mean is equal to zero (* 0.1 ** 0.05 *** 0.01).}} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}

	* Table on discrete vars ***************************************************
	qui {
		texdoc init descriptives1 , replace force
		tex \begin{table}[H]
		tex \caption{Descriptive Statistics II}
		tex \label{descriptives2}
		tex \centering
		tex \scalebox{0.7}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
		tex \begin{tabularx} {18cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \toprule	
		tex  & Population & \multicolumn{3}{c}{Survey Sample} \\
		tex \textbf{Dummy Variables} & \textbf{\% } & \textbf{\% $  \diamond$ } & \textbf{Ones} & \textbf{SD}\\
		tex \cmidrule(l){2-2} \cmidrule(l){3-5}
	}
		
		forval k=1(1)3 { // Level of covariates
			preserve
			
				duplicates drop ${conda`k'}, force
				count if InBase==1
				local eneSam = r(N) 
				tex \multicolumn{5}{l}{\textbf{${title`k'}} (n=`eneSam') } \\			
			
				foreach vari in ${varsD`k'}  {	// For each covariate

						local miTitulo : variable label `vari'

						qui sum `vari' if muestra==1 & InBase==1, d
						local ene = r(N) 
						local mean : di %6.2f r(mean)*100 
						local sd   : di %6.2f r(sd)*100

						count if `vari'==1 & InBase==1
						local eno = r(N) 
						
						qui sum `vari' , mean
						local meanPop : di %6.2f r(mean)*100 		
						qui reg `vari' InBase
						myCoeff2 1 1 "InBase"
									
						
						tex $ \quad $ `miTitulo' & `meanPop'\% & `mean'\% $ $star1$ & `eno' & `sd'pp. \\
				}
			restore
		}

	qui {
		tex \bottomrule
		tex \multicolumn{5}{l}{Source: Own calculations based on a 10\% student sample from SABER 11 2013-II.} \\
		tex \multicolumn{5}{l}{$ \dagger$ data from ICFES official classification for 2010 if 2011 is not available.} \\
		tex \multicolumn{5}{l}{\parbox[c]{18cm}{$ \diamond$ Starts show the significance of a test checking if the difference between the sampled and non-sampled mean is equal to zero (* 0.1 ** 0.05 *** 0.01).}} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}
}

////////////////////////////////////////////////////////////////////////////////
// Graph on test expectations and actual performance (Figure 4)
if 1==0 {
	glo genOpts="  graphregion(color(white) lwidth(medium)) scheme(lean2)"		
			
	graph box tema_lenguaje, over(estu_puntajelenguaje) name(a1, replace) xalternate $genOpts title(Language) subtitle(Expect results in Language to be)
	graph bar, over(estu_puntajelenguaje) name(a2, replace) fysize(25) blabel(bar, format(%3.1f)) $genOpts

	graph box tema_matematica, over(estu_puntajematematicas) name(a3, replace) xalternate $genOpts title(Mathematics) subtitle(Expect results in Mathematics to be)
	graph bar, over(estu_puntajematematicas) name(a4, replace) fysize(25) blabel(bar, format(%3.1f)) $genOpts 

	cd "$carpeta\documento\imagenes"
	graph combine a1 a3 a2 a4,  $genOpts caption("Source: Own calculations based on a sample from SABER11 2013 data.")
	*graph export "testExpectationsResults.pdf", as(pdf) replace // Edit it carefuly, offset lower graphs by 0.7, and set y-labels on %8.1f

	reg tema_lenguaje i.estu_puntajelenguaje
	reg tema_matematica i.estu_puntajematematicas
}
////////////////////////////////////////////////////////////////////////////////
// Graph on progress to higher education epectation and actual performance (Figure 5)
if 1==0 {
	glo genOpts="  graphregion(color(white) lwidth(medium)) scheme(lean2)"		
			
	graph box tema_lenguaje, over(estu_ingresaprograma) name(a1, replace) xalternate $genOpts title(Language) subtitle(Expect to enter into high education)
	graph bar, over(estu_ingresaprograma) name(a2, replace) fysize(25) blabel(bar, format(%3.1f)) $genOpts

	graph box tema_matematica, over(estu_ingresaprograma) name(a3, replace) xalternate $genOpts title(Mathematics) subtitle(Expect to enter into high education)
	graph bar, over(estu_ingresaprograma) name(a4, replace) fysize(25) blabel(bar, format(%3.1f)) $genOpts 

	cd "$carpeta\documento\imagenes"
	graph combine a1 a3 a2 a4,  $genOpts caption("Source: Own calculations based on a sample from SABER11 2013 data.")
	graph export "enterExpectationsResults.pdf", as(pdf) replace // Edit it carefuly, offset lower graphs by 0.7, and set y-labels on %8.1f

	reg tema_lenguaje i.estu_ingresaprograma
	reg tema_matematica i.estu_ingresaprograma
}
