	
* Delete odd characters	
cap program drop cleanName
program define cleanName, rclass
args varDep


	* Some friend names are not names at all
	replace `varDep'="" if `varDep'=="Not At Home"
	replace `varDep'="" if `varDep'=="No Women In The House"
	replace `varDep'="" if `varDep'=="Ladies Members"
	replace `varDep'="" if `varDep'=="Not Found"
	replace `varDep'="" if `varDep'=="(Dead)"
	replace `varDep'="" if `varDep'=="(Died)"
	replace `varDep'="" if `varDep'=="(died)"
	replace `varDep'=subinstr(`varDep', `"""', "",.)
	/* Names or Address?
	"99 Sadam"
	"99 Yadav"
	"99 Sadaya"
	"99 Mahara"
	"99 Shah"
	"99 Sady"
	"99 Adhikari"
	"99 Kadari"
	"99 Saha"
	"99 Mandal"
	"99"
	"99 Shah"
	*/

	
	*1. Remove non-alphabets from the name
	* Clean names and say why they were that odd
	foreach chara in "(Dead)" "(Died)" "(died)" "'" "(" ")" "," "." "=" "-" "#" "[" "]" "/" "\" "`" "&" ";" "{" "1" "4" "6" "8" "9" "0" "2" "7" "’" {
		disp "Cleaning for character `chara'"
		qui gen _hasOdd=strpos(`varDep',"`chara'")
		list `varDep' if _hasOdd==1
		qui drop _hasOdd		
		replace `varDep'=subinstr(`varDep', "`chara'", "",.)
	}

	disp "Cleaning for character " `"""'
	qui gen _hasOdd=strpos(`varDep', `"""')
	list `varDep' if _hasOdd==1
	qui drop _hasOdd		
	replace `varDep'=subinstr(`varDep', `"""', "",.)	
	
	* Simplify things for matching
	replace `varDep'=trim(`varDep')
	replace `varDep'=lower(`varDep')
	
	*ssc install charlist
	charlist `varDep'

end	

* ***********************************************************************************
* @ Generate print-friendly versions of stata coefficients
* @ it has to be run after a regression where the first var is the relevant one, and it will
* @ return $coef`number' $se`number' and $star`number'. Something lile 1.23 (0.4) ^{***}
* @ which can be used directly into texdoc
cap program drop myCoeff 
program define myCoeff, rclass
args number fac which
	if "`which'"=="" {
		matrix B=e(b)
		matrix V=e(V)	
		local coefi= B[1,1]
		local sei  = (V[1,1])^0.5
	}
	else {
	disp "`which'"
		local coefi= _b["`which'"]
		local sei  = _se["`which'"]
	}

	glo coef`number' : di %7.2f `coefi'*`fac'
	glo se`number'   : di %7.2f `sei'*`fac'
	if e(cmd)=="xtreg" | e(cmd)=="rd" {
		scalar pval=2*(1-normal( abs(`coefi'/(`sei'))))			
	}
	else {
		scalar pval=2*ttail( e(df_r) , abs(`coefi'/(`sei')))
	}
	glo starX`number' = ""
	if ((pval < 0.1) )  glo starX`number' = "*" 
	if ((pval < 0.05) ) glo starX`number' = "**" 
	if ((pval < 0.01) ) glo starX`number' = "***" 
	
	glo star`number'="^{${starX`number'}}"
end

* @ An alternative where instead of asuming that you want the first, you give it the 
* @ name of the variable. If the variable is not there, it returns blanks
* @ Example: myCoeff2 2 100 "treatment"
cap program drop myCoeff2
program define myCoeff2, rclass
args number fac vari
	cap disp _b[`vari']
	if _rc==0 {
		local coe=_b[`vari']
		local ste=_se[`vari']
		if e(cmd)=="probit" {
			glo coef`number' : di %7.4f `coe'*`fac'
			glo se`number'   : di %7.4f (`ste')*`fac'			
		}
		else {
			glo coef`number' : di %7.4f `coe'*`fac'
			glo se`number'   : di %7.4f (`ste')*`fac'
		}
		glo se`number' = "(${se`number'})"
		glo sep`number'  = "${se`number'}"
		glo t`number' :  di %7.2f abs(`coe'/`ste' )
		glo tb`number'  = "[${t`number'}]"
		
		if e(cmd)=="margins" | e(cmd)=="probit" | e(cmd)=="oprobit" {
			scalar pval=2*(1-normal( abs(`coe'/`ste' )))			
		}
		else {
			glo df`number' = e(df_r)
			scalar pval=2*ttail( e(df_r) , abs(`coe'/`ste' ))
		}
		glo pval`number' = pval
		glo star`number' = ""
		glo starn`number' = 0
		if ((pval < 0.1) )  glo star`number' = "^{*}" 
		if ((pval < 0.1) )  glo starn`number' = 1
		if ((pval < 0.05) ) glo star`number' = "^{**}" 
		if ((pval < 0.05) ) glo starn`number' = 2	
		if ((pval < 0.01) ) glo star`number' = "^{***}" 
		if ((pval < 0.01) ) glo starn`number' = 3
	}
	else {
		glo coef`number'=""
		glo se`number'=""
		glo sep`number'=""
		glo star`number'=""
	}
end
