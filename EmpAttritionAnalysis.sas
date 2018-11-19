							/*PROC FREQUENCY*/
						
/* PROC FREQUENCY */
PROC FREQ DATA = SAS.attritionanalysis;
Run;

/* PROC FREQUENCY for Retain Indicator.*/
PROC FREQ DATA = SAS.attritionanalysis;
	TABLES Retain_Indicator;
Run;
/* PROC FREQUENCY Martial status, Sex Indicator & Relocation Indicator.*/
PROC FREQ DATA = SAS.attritionanalysis;
	TABLES Marital_Status Sex_Indicator Relocation_Indicator;
Run;

/* PROC FREQUENCY for Marital Status. Cross Grid view*/
PROC FREQ DATA = SAS.attritionanalysis;
		Tables Marital_Status*Retain_Indicator;
Run;

		/*PROC FREQUENCY. Cross Grid view with options*/
/*PROC FREQUENCY for Relocation Indicator. Cross Grid view with options*/
PROC FREQ DATA = SAS.attritionanalysis;
		Tables Marital_Status*Retain_Indicator/nocum nocol nopercent norow;
Run;
/*PROC FREQUENCY for Relocation Indicator.Cross Grid view with options*/
PROC FREQ DATA = SAS.attritionanalysis;
		Tables Relocation_Indicator*Retain_Indicator/nocum nocol nopercent norow;
Run;

/*PROC FREQUENCY for Sex Indicator. Cross Grid view with options*/
PROC FREQ DATA = SAS.attritionanalysis;
		Tables Sex_Indicator*Retain_Indicator/nocum nocol nopercent norow;
Run;

					/* PROC FREQUENCY*/
PROC Freq Data = SAS.attritionanalysis;
	Tables Marital_Status*Retain_Indicator/plots=freqplot;
Run;

PROC FREQ DATA = SAS.attritionanalysis;
	Tables Relocation_Indicator*Retain_Indicator/plots=freqplot;
Run;

PROC FREQ DATA = SAS.attritionanalysis;
	Tables Sex_Indicator*Retain_Indicator/plots=freqplot;
Run;

/*Sample*/
PROC surveyselect DATA = SAS.attritionanalysis method=srs samprate=.65  out=SAS.OAttrition;
Run;

/*Validation  */
DATA Validation;
	Merge SAS.attritionanalysis(in=a) SAS.OAttrition (in=b);
	if a and not b;
Run;

/*Validation to check consistency  */
PROC FREQ DATA = SAS.OATTRITION;
	TABLES Retain_Indicator;
Run;


					/* Making predictions*/  
/*Marital_Status = Married, Sex_Indicator = Female Relocation_Indicator=0 */
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL= sas.sas1 desc plots=all;
	CLASS Marital_Status (ref='Unmarried' param=ref) Sex_Indicator (ref='Male' param=ref) Relocation_Indicator (ref='1' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition1 p = predAttrition1;
Run;

/*Marital_Status = Married, Sex_Indicator = Male Relocation_Indicator=0*/
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL= SAS.sas2 desc plots=all;
	CLASS Marital_Status (ref='Unmarried' param=ref) Sex_Indicator (ref='Female' param=ref) Relocation_Indicator (ref='1' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition2 p = predAttrition2;
Run;

/*Marital_Status = Unmarried, Sex_Indicator = Female Relocation_Indicator=0  */
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL= SAS.sas3 desc plots=all;
	CLASS Marital_Status (ref='Married' param=ref) Sex_Indicator (ref='Male' param=ref)Relocation_Indicator (ref='1' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition3 p = predAttrition3;
Run;

/*Marital_Status = Unmarried, Sex_Indicator = Male Relocation_Indicator=0*/
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL=SAS.sas4 desc plots=all;
	CLASS Marital_Status (ref='Married' param=ref) Sex_Indicator (ref='Female' param=ref) Relocation_Indicator (ref='1' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition4 p = predAttrition4;
Run;

/*Marital_Status = Unmarried, Sex_Indicator = Male Relocation_Indicator=1*/
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL=SAS.sas5 desc plots=all;
	CLASS Marital_Status (ref='Married' param=ref) Sex_Indicator (ref='Female' param=ref) Relocation_Indicator (ref='0' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition5 p = predAttrition5;
Run;

/*Marital_Status = Married, Sex_Indicator = Male Relocation_Indicator=1*/
PROC LOGISTIC DATA = SAS.attritionanalysis OUTMODEL=SAS.sas6 desc plots=all;
	CLASS Marital_Status (ref='Unmarried' param=ref) Sex_Indicator (ref='Female' param=ref) Relocation_Indicator (ref='0' param=ref);
	MODEL Retain_Indicator (event = '0') = Marital_Status Sex_Indicator Relocation_Indicator/link=logit;
	Output out = SAS.OutAttrition6 p = predAttrition6;
Run;

				/* Model validation */
PROC LOGISTIC inmodel = SAS.sas1;
	score data = Validation out = SAS.ValidScores;
Run;
/* Model validation */
PROC LOGISTIC inmodel = SAS.sas4;
	score data = Validation out = SAS.ValidScores1;
Run;
/* Model validation */
PROC LOGISTIC inmodel = SAS.sas6;
	score data = Validation out = SAS.ValidScores6;
Run;

/* Proc frequency */
PROC FREQ DATA=SAS.validscores;
	TABLES Retain_Indicator*P_1/noprint measures; /*0.0962*/
Run;
/* Proc frequency */
PROC FREQ DATA=SAS.Validscores1;
	TABLES Retain_Indicator * P_1/noprint measures; /*0.0962*/
Run;

/*Proc univariate  */
PROC UNIVARIATE DATA=SAS.OutAttrition1;
	var predAttrition1;
Run;
/*Proc univariate  */
PROC UNIVARIATE DATA=SAS.Outattrition4;
	var predAttrition4;
Run;
/*Proc univariate  */
PROC UNIVARIATE DATA=SAS.Outattrition6;
	var predAttrition6;
Run;

/* Mean for specific variable */
PROC MEANS DATA = SAS.OUTATTRITION1 n;
	WHERE predAttrition1 >=.45;
Run;

/* Mean for specific variable */
PROC MEANS DATA = SAS.OUTATTRITION4 n;
	WHERE predAttrition4 >=.45;
Run;

/* Mean for specific variable */
PROC MEANS DATA = SAS.OUTATTRITION6 n;
	WHERE predAttrition6 >=.5;
Run;

				/*Predicting  */
DATA SAS.OutAttrition1;
	SET SAS.outattrition1;
	if predAttrition1 >=.45 then Retain_Indicator_PAttri=1;
	else Retain_Indicator_PredAttri=0;
Run;

DATA SAS.OutAttrition4;
	SET SAS.outattrition4;
	if predAttrition4 >=.45 then Retain_Indicator_PAttri=1;
	else Retain_Indicator_PredAttri=0;
Run;

DATA SAS.OutAttrition6;
	SET SAS.outattrition6;
	if predAttrition6 >=.5 then Retain_Indicator_PAttri=1;
	else Retain_Indicator_PredAttri=0;
Run;

DATA SAS.OutAttrition1;
	set SAS.outattrition1;
	if predAttrition1 >=.50 then Categorized_Qty = "H";
	else if predAttrition1 >=.45  then Categorized_Qty = "M";
	else Categorized_Qty = "L";
Run;

DATA SAS.OutAttrition6;
	set SAS.outattrition6;
	if predAttrition6 >=.50 then Categorized_Qty = "H";
	else if predAttrition6 >=.45  then Categorized_Qty = "M";
	else Categorized_Qty = "L";
Run;

PROC FREQ DATA = SAS.Outattrition1;
	TABLES Retain_Indicator_PredAttri*Retain_Indicator;
Run;

PROC FREQ DATA = SAS.Outattrition6;
	TABLES Retain_Indicator_PredAttri*Retain_Indicator;
Run;

/*Sorting*/
PROC SORT DATA= SAS.Outattrition1;
	BY predAttrition1;
Run;	
/*Sorting*/
PROC SORT DATA= SAS.Outattrition6;
	BY predAttrition6;
Run;
