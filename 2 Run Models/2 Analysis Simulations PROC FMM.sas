proc datasets lib = work kill noprint memtype=data; run; quit;
dm 'log; clear; output; clear;';

%let PATH = H:\Biostatistics\Jessica L\Lavery\dissertation;
libname A "&PATH\data\Project 1\Simulation";

options fmtsearch=(A);
%let PGM = Analysis Simulations PROC FMM;

%let cdate=%sysfunc(putn("&sysdate9"d,yymmdd10.));
%put &cdate;

/**********************************************************************
Program: Analysis Simulations PROC FMM.sas

Purpose: Run simulations using PROC FMM
**********************************************************************/

%macro run_sims();
	proc printto new log="&PATH\programs\Project 1\Simulation\Logs\run_sims_&sysdate._&SYSHOSTNAME..txt";
	run;

	%local i next_scenario;
	%do i=1 %to %sysfunc(countw(&scenario_list));
	%let scenario = %scan(&scenario_list, &i);

	ods exclude all;
	* run model on events only;
	proc fmm data=sim&scenario..sim_data_tte_events_scenario_&scenario. maxiter=150 NOCENTER cov gconv=0 seed=1123 technique = NEWRAP;
		ods trace on;
		model log_outc_yrs = tx age_dx_centered / cl dist=normal k = 2 equate=scale;
		probmodel pdl1_perc_norm / noint cl;
		* IPTW*IPCW weights;
		weight iptw_ipcw_trim97;
		* run for each iteration;
		by iteration;
		* only run first 500 iterations (some simulation scenario datasets may have more due to BMM not converging);
		where iteration <= 500;
		* output model output;
		ods output  ParameterEstimates = sim&scenario..parms_sim&scenario.
					MixingProbs = sim&scenario..mixprobs_sim&scenario.
					Cov = sim&scenario..cov_sim&scenario.(where=(modelno=1 and parameter ne "Variance"));
		* predicted probabilities;
		output out = sim&scenario..pred_sim&scenario. mixprobs XBETA posterior;
	run;

	
	ods exclude none;
	%end;

	proc printto;
	run;
%mend;
/*%run_sims;*/

%macro run_sims_for_ncomponents();
	proc printto new log="&PATH\programs\Project 1\Simulation\Logs\run_sims_for_n_components_&sysdate._&SYSHOSTNAME..txt";
	run;

	%local l next_scenario;
	%do l=1 %to %sysfunc(countw(&scenario_list));
	%let scenario = %scan(&scenario_list, &l);

	ods exclude all;

	proc fmm data=sim&scenario..sim_data_tte_events_scenario_&scenario. maxiter=150 NOCENTER cov gconv=0 seed=1123  technique = NEWRAP;
		ods trace on;
		model log_outc_yrs = tx age_dx_centered / cl dist=normal kmin = 1 kmax = 3 KRESTART equate = scale;
		probmodel pdl1_perc_norm / noint cl;
		* IPTW*IPCW weights;
		weight iptw_ipcw_trim97;
		* run for each iteration;
		by iteration;
		* only run first 500 iterations (some simulation scenario datasets may have more due to BMM not converging);
		where iteration <= 500;
		* output model output;
		ods output  ParameterEstimates = sim&scenario..parms_k_sim&scenario.
					CriterionPanel = sim&scenario..criterionpanel_sim&scenario.;
	run;
	%end;
	ods exclude none;

	proc printto;
	run;
%mend;
/*%run_sims_for_ncomponents;*/
