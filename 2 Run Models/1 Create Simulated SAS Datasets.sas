proc datasets lib = work kill noprint memtype=data; run; quit;
dm 'log; clear; output; clear;';

%let PATH = H:\Biostatistics\Jessica L\Lavery\dissertation\;
libname A "&PATH\data\Project 1\Simulation";

%let PGM = Create Simulated SAS Datasets;

%let cdate=%sysfunc(putn("&sysdate9"d,yymmdd10.));
%put &cdate;
/**********************************************************************
Program: Create Simulated SAS Datasets.sas

Purpose: Read in dimulated data that was generated in R and exported
to an xlsx file

Date
06JUN2024 Create
20NOV2024 Update file paths for new structure
**********************************************************************/

* import simulation scenarios to loop through each relevant scenario;
PROC IMPORT OUT = A.sim_scenarios
            DATAFILE= "&PATH\data\Project 1\Simulation\simulation_scenarios.xlsx" 
            DBMS=EXCELCS REPLACE;
     RANGE="Sheet1$"; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

* set up libname for each simulation scenario;
%macro setup_libnames();
	%local i next_scenario;
	%do i=1 %to %sysfunc(countw(&scenario_list));
	%let scenario = %scan(&scenario_list, &i);

	* set up libname for each setting;
	libname sim&scenario "&PATH\data\Project 1\Simulation\Scenario &scenario";
	%end;
%mend;
/*%setup_libnames();*/


%macro import_sims(complete_data = FALSE);
	%local i next_scenario;
	%do i=1 %to %sysfunc(countw(&scenario_list));
	%let scenario = %scan(&scenario_list, &i);

	* set up libname for each setting;
/*	libname sim&scenario "&PATH\data\Project 1\Simulation\Scenario &scenario";*/

	* read in data from xlsx;
	* complete simulated dataset;
	%if &complete_data = TRUE %then %do;
		PROC IMPORT OUT= sim&scenario..sim_data_tte_scenario_&scenario
		            DATAFILE= "&PATH\data\Project 1\Simulation\Scenario &scenario\scenario&scenario._sim_data_tte_with_confounder.xlsx" 
		            DBMS=EXCELCS REPLACE;
		     RANGE="Sheet1$"; 
		     SCANTEXT=YES;
		     USEDATE=YES;
		     SCANTIME=YES;
		RUN;
	%end;

	* events only;
	PROC IMPORT OUT= sim&scenario..sim_data_tte_events_scenario_&scenario
	            DATAFILE= "&PATH\data\Project 1\Simulation\Scenario &scenario\scenario&scenario._sim_data_tte_with_confounder_events.xlsx" 
	            DBMS=EXCELCS REPLACE;
	     RANGE="Sheet1$"; 
	     SCANTEXT=YES;
	     USEDATE=YES;
	     SCANTIME=YES;
	RUN;
	%end;
%mend;

/*%import_sims;*/
