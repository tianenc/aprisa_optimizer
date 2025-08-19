	
	######################################################################################
	### Copyright Mentor, A Siemens Business						##
	### All Rights Reserved								##
	### Version : /google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP		##
	###											##
	### THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY					##
	### INFORMATION WHICH ARE THE PROPERTY OF MENTOR					##
	### GRAPHICS CORPORATION OR ITS LICENSORS AND IS					##
	### SUBJECT TO LICENSE TERMS.							##
	######################################################################################
	set AP_BUILD [info nameofexecutable]
	puts "
	######################################################################################
	### Aprisa Import Stage								##
	### Version : $AP_BUILD		##
	### Imports technology & design info to prepare					##
	### design for place and route.							##
	######################################################################################
	"
	if { $AP_BUILD != "/google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP" } {
	puts "WARNING: Run build different from the build used to generate script via flowgen. Incompatibility could cause errors."
	}
	###########################################
	### Initial variable & working area setup ##
	############################################
	set ROOT    [pwd] 
	set PHASE    init 
	source scripts/header.tcl
	#################################
	### Source customization script ##
	################################## 
	set STEP "pre"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	source $CUSTOM_SCRIPT/lib_lef_search_path.tcl
	
	source $PARAMS/init_params.tcl
	source $SCRIPTS/proj_setup_variables.tcl
	
	#	source $SCRIPTS/flow_design_settings.tcl
	set AF_LIBERTY_SEARCH_PATH_STD "/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/libs"
	set AF_LIBERTY_SEARCH_PATH_MACRO "" 
	set AF_LIBERTY_SEARCH_PATH_IP ""	
	set AF_LIBERTY_SEARCH_PATH "$AF_LIBERTY_SEARCH_PATH_STD $AF_LIBERTY_SEARCH_PATH_MACRO $AF_LIBERTY_SEARCH_PATH_IP" 
	set AF_LIBERTY_FILES_STD {
                tcbn03e_bwp143mh117l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_googll_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh117l3p48cpd_googll_lvtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh117l3p48cpd_googll_svtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh117l3p48cpd_googll_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh117l3p48cpd_googll_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh117l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh117l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec2_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_basec_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_googll_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh169l3p48cpd_googll_lvtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh169l3p48cpd_googll_svtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh169l3p48cpd_googll_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh169l3p48cpd_googll_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_ccstnp_lvf.lib
                tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvl_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvl_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvl_svtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc2_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh169l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_basec2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_basec2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_basec2_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_googpm_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib
                tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvl_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvl_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvl_svtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_mb_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_mb_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_mb_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_mb_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_mb_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc2_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc_lvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc_svtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh286l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_hm_lvf.lib.gz
                tcbn03e_bwp143mh403l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccs.lib.gz
                tcbn03e_bwp143mh403l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_ccs.lib.gz
                tcbn03e_bwp143mh403l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_ccs.lib.gz
                tcbn03e_bwp143mh403l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_ccs.lib.gz
                tcbn03e_bwp143mh403l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_ccs.lib.gz
                ts1n03ehslvta1024x16m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x23m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x26m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x29m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x36m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x46m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta1024x55m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x111m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x128m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x129m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x39m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x39m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x50m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x50m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta128x74m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x109m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x38m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x38m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x51m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x51m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x52m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x52m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x72m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x72m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x78m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta256x82m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x109m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x10m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x10m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x110m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x126m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x127m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x140m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x38m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x38m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x39m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x39m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x46m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x46m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x52m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x52m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x71m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x71m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x74m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta512x78m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta64x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta64x50m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta64x62m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03ehslvta64x96m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvta4096x133m4qwzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvta4096x89m4qwzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvta4096x96m4qwzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvtb4096x133m4qwzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvtb4096x89m4qwzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03emblvtb4096x96m4qwzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x16m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x23m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x26m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x29m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x36m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x46m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta1024x55m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x111m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x111m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x128m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x128m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x128m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x129m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x129m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x39m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x39m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x48m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x50m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x50m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x50m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x74m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x74m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta128x74m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta16x102m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta16x96m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x109m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x109m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x38m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x38m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x38m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x48m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x51m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x51m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x52m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x52m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x52m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x72m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x72m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x72m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x78m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x78m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x78m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x82m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x82m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta256x82m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x101m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x168m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x168m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x62m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x62m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x80m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x80m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x96m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta32x96m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x109m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x109m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x10m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x10m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x110m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x110m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x126m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x126m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x127m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x127m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x140m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x140m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x38m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x38m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x39m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x39m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x46m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x46m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x48m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x52m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x52m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x71m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x71m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x74m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x74m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x78m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta512x78m4wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x168m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x168m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x48m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x48m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x50m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x50m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x62m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x62m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x96m1wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvta64x96m2wzhodcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x16m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x16m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x23m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x23m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x26m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x26m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x29m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x29m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x36m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x36m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x46m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x46m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x55m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb1024x55m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x111m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x128m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x129m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x39m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x39m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x48m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x48m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x50m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x50m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb128x74m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x109m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x38m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x38m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x48m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x48m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x51m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x51m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x52m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x52m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x72m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x72m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x78m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb256x82m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x109m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x10m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x10m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x110m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x126m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x127m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x140m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x38m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x38m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x39m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x39m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x46m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x46m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x48m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x48m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x52m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x52m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x71m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x71m8wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x74m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb512x78m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb64x48m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb64x50m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb64x62m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
                ts1n03esblvtb64x96m4wzhodxcp_ssgnp_0p675v_0p675v_m25c_cworst_ccworst_t.lib
}
	set AF_LIBERTY_FILES_MACRO {}
	set AF_LIBERTY_FILES_IP {}
	set AF_LEF_SEARCH_PATH_STD "/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/lefs"
	set AF_LEF_SEARCH_PATH_MACRO "" 
	set AF_LEF_SEARCH_PATH_IP "" 
	set AF_LEF_SEARCH_PATH "$AF_LEF_SEARCH_PATH_STD $AF_LEF_SEARCH_PATH_MACRO $AF_LEF_SEARCH_PATH_IP"
	set AF_LEF_FILES_STD {
               fiducial_h143.lef
               fiducial_h169.lef
               gen_vp_CLOCK_HIGH_DRIVE.lef
               gen_vp_CLOCK.lef
               gen_vp_COMMON.lef
               tcbn03e_bwp143mh117l3p48cpd_base_lvt.lef
               tcbn03e_bwp143mh117l3p48cpd_base_lvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_base_lvtll_par.lef
               tcbn03e_bwp143mh117l3p48cpd_base_lvt_par.lef
               tcbn03e_bwp143mh117l3p48cpd_base_svt.lef
               tcbn03e_bwp143mh117l3p48cpd_base_svt_par.lef
               tcbn03e_bwp143mh117l3p48cpd_base_ulvt.lef
               tcbn03e_bwp143mh117l3p48cpd_base_ulvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_base_ulvtll_par.lef
               tcbn03e_bwp143mh117l3p48cpd_base_ulvt_par.lef
               tcbn03e_bwp143mh117l3p48cpd_googll_lvt.lef
               tcbn03e_bwp143mh117l3p48cpd_googll_lvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_googll_svt.lef
               tcbn03e_bwp143mh117l3p48cpd_googll_ulvt.lef
               tcbn03e_bwp143mh117l3p48cpd_googll_ulvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_lvt.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_lvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_lvtll_par.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_lvt_par.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_svt.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_svt_par.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_ulvt.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_ulvtll.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_ulvtll_par.lef
               tcbn03e_bwp143mh117l3p48cpd_pm_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec2_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_basec_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_base_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_base_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_base_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_base_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_base_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_base_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_base_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_base_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_base_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_base_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_googll_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_googll_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_googll_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_googll_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_googll_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_lvl_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pmc_ulvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_lvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_lvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_lvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_lvt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_svt.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_svt_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_ulvt.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_ulvtll.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_ulvtll_par.lef
               tcbn03e_bwp143mh169l3p48cpd_pm_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_basec2_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_base_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_base_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_base_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_base_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_base_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_base_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_base_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_base_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_base_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_base_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_googpm_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_lvl_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_mb_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pmc_ulvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_lvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_lvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_lvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_lvt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_svt.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_svt_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_ulvt.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_ulvtll.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_ulvtll_par.lef
               tcbn03e_bwp143mh286l3p48cpd_pm_ulvt_par.lef
               tcbn03e_bwp143mh403l3p48cpd_base_lvt.lef
               tcbn03e_bwp143mh403l3p48cpd_base_lvtll.lef
               tcbn03e_bwp143mh403l3p48cpd_base_lvtll_par.lef
               tcbn03e_bwp143mh403l3p48cpd_base_lvt_par.lef
               tcbn03e_bwp143mh403l3p48cpd_base_svt.lef
               tcbn03e_bwp143mh403l3p48cpd_base_svt_par.lef
               tcbn03e_bwp143mh403l3p48cpd_base_ulvt.lef
               tcbn03e_bwp143mh403l3p48cpd_base_ulvtll.lef
               tcbn03e_bwp143mh403l3p48cpd_base_ulvtll_par.lef
               tcbn03e_bwp143mh403l3p48cpd_base_ulvt_par.lef
               ts1n03ehslvta1024x16m4wzhodcp.lef
               ts1n03ehslvta1024x23m4wzhodcp.lef
               ts1n03ehslvta1024x26m4wzhodcp.lef
               ts1n03ehslvta1024x29m4wzhodcp.lef
               ts1n03ehslvta1024x36m4wzhodcp.lef
               ts1n03ehslvta1024x46m4wzhodcp.lef
               ts1n03ehslvta1024x55m4wzhodcp.lef
               ts1n03ehslvta128x111m2wzhodcp.lef
               ts1n03ehslvta128x128m2wzhodcp.lef
               ts1n03ehslvta128x129m2wzhodcp.lef
               ts1n03ehslvta128x39m2wzhodcp.lef
               ts1n03ehslvta128x39m4wzhodcp.lef
               ts1n03ehslvta128x48m2wzhodcp.lef
               ts1n03ehslvta128x48m4wzhodcp.lef
               ts1n03ehslvta128x50m2wzhodcp.lef
               ts1n03ehslvta128x50m4wzhodcp.lef
               ts1n03ehslvta128x74m2wzhodcp.lef
               ts1n03ehslvta256x109m2wzhodcp.lef
               ts1n03ehslvta256x38m2wzhodcp.lef
               ts1n03ehslvta256x38m4wzhodcp.lef
               ts1n03ehslvta256x48m2wzhodcp.lef
               ts1n03ehslvta256x48m4wzhodcp.lef
               ts1n03ehslvta256x51m2wzhodcp.lef
               ts1n03ehslvta256x51m4wzhodcp.lef
               ts1n03ehslvta256x52m2wzhodcp.lef
               ts1n03ehslvta256x52m4wzhodcp.lef
               ts1n03ehslvta256x72m2wzhodcp.lef
               ts1n03ehslvta256x72m4wzhodcp.lef
               ts1n03ehslvta256x78m2wzhodcp.lef
               ts1n03ehslvta256x82m2wzhodcp.lef
               ts1n03ehslvta512x109m2wzhodcp.lef
               ts1n03ehslvta512x10m2wzhodcp.lef
               ts1n03ehslvta512x10m4wzhodcp.lef
               ts1n03ehslvta512x110m2wzhodcp.lef
               ts1n03ehslvta512x126m2wzhodcp.lef
               ts1n03ehslvta512x127m2wzhodcp.lef
               ts1n03ehslvta512x140m2wzhodcp.lef
               ts1n03ehslvta512x38m2wzhodcp.lef
               ts1n03ehslvta512x38m4wzhodcp.lef
               ts1n03ehslvta512x39m2wzhodcp.lef
               ts1n03ehslvta512x39m4wzhodcp.lef
               ts1n03ehslvta512x46m2wzhodcp.lef
               ts1n03ehslvta512x46m4wzhodcp.lef
               ts1n03ehslvta512x48m2wzhodcp.lef
               ts1n03ehslvta512x48m4wzhodcp.lef
               ts1n03ehslvta512x52m2wzhodcp.lef
               ts1n03ehslvta512x52m4wzhodcp.lef
               ts1n03ehslvta512x71m2wzhodcp.lef
               ts1n03ehslvta512x71m4wzhodcp.lef
               ts1n03ehslvta512x74m2wzhodcp.lef
               ts1n03ehslvta512x78m2wzhodcp.lef
               ts1n03ehslvta64x48m2wzhodcp.lef
               ts1n03ehslvta64x50m2wzhodcp.lef
               ts1n03ehslvta64x62m2wzhodcp.lef
               ts1n03ehslvta64x96m2wzhodcp.lef
               ts1n03emblvta4096x133m4qwzhodcp.lef
               ts1n03emblvta4096x89m4qwzhodcp.lef
               ts1n03emblvta4096x96m4qwzhodcp.lef
               ts1n03emblvtb4096x133m4qwzhodxcp.lef
               ts1n03emblvtb4096x89m4qwzhodxcp.lef
               ts1n03emblvtb4096x96m4qwzhodxcp.lef
               ts1n03esblvta1024x16m4wzhodcp.lef
               ts1n03esblvta1024x23m4wzhodcp.lef
               ts1n03esblvta1024x26m4wzhodcp.lef
               ts1n03esblvta1024x29m4wzhodcp.lef
               ts1n03esblvta1024x36m4wzhodcp.lef
               ts1n03esblvta1024x46m4wzhodcp.lef
               ts1n03esblvta1024x55m4wzhodcp.lef
               ts1n03esblvta128x111m2wzhodcp.lef
               ts1n03esblvta128x111m4wzhodcp.lef
               ts1n03esblvta128x128m1wzhodcp.lef
               ts1n03esblvta128x128m2wzhodcp.lef
               ts1n03esblvta128x128m4wzhodcp.lef
               ts1n03esblvta128x129m2wzhodcp.lef
               ts1n03esblvta128x129m4wzhodcp.lef
               ts1n03esblvta128x39m2wzhodcp.lef
               ts1n03esblvta128x39m4wzhodcp.lef
               ts1n03esblvta128x48m1wzhodcp.lef
               ts1n03esblvta128x48m2wzhodcp.lef
               ts1n03esblvta128x48m4wzhodcp.lef
               ts1n03esblvta128x50m1wzhodcp.lef
               ts1n03esblvta128x50m2wzhodcp.lef
               ts1n03esblvta128x50m4wzhodcp.lef
               ts1n03esblvta128x74m1wzhodcp.lef
               ts1n03esblvta128x74m2wzhodcp.lef
               ts1n03esblvta128x74m4wzhodcp.lef
               ts1n03esblvta16x102m1wzhodcp.lef
               ts1n03esblvta16x96m1wzhodcp.lef
               ts1n03esblvta256x109m2wzhodcp.lef
               ts1n03esblvta256x109m4wzhodcp.lef
               ts1n03esblvta256x38m1wzhodcp.lef
               ts1n03esblvta256x38m2wzhodcp.lef
               ts1n03esblvta256x38m4wzhodcp.lef
               ts1n03esblvta256x48m1wzhodcp.lef
               ts1n03esblvta256x48m2wzhodcp.lef
               ts1n03esblvta256x48m4wzhodcp.lef
               ts1n03esblvta256x51m2wzhodcp.lef
               ts1n03esblvta256x51m4wzhodcp.lef
               ts1n03esblvta256x52m1wzhodcp.lef
               ts1n03esblvta256x52m2wzhodcp.lef
               ts1n03esblvta256x52m4wzhodcp.lef
               ts1n03esblvta256x72m1wzhodcp.lef
               ts1n03esblvta256x72m2wzhodcp.lef
               ts1n03esblvta256x72m4wzhodcp.lef
               ts1n03esblvta256x78m1wzhodcp.lef
               ts1n03esblvta256x78m2wzhodcp.lef
               ts1n03esblvta256x78m4wzhodcp.lef
               ts1n03esblvta256x82m1wzhodcp.lef
               ts1n03esblvta256x82m2wzhodcp.lef
               ts1n03esblvta256x82m4wzhodcp.lef
               ts1n03esblvta32x101m2wzhodcp.lef
               ts1n03esblvta32x168m1wzhodcp.lef
               ts1n03esblvta32x168m2wzhodcp.lef
               ts1n03esblvta32x62m1wzhodcp.lef
               ts1n03esblvta32x62m2wzhodcp.lef
               ts1n03esblvta32x80m1wzhodcp.lef
               ts1n03esblvta32x80m2wzhodcp.lef
               ts1n03esblvta32x96m1wzhodcp.lef
               ts1n03esblvta32x96m2wzhodcp.lef
               ts1n03esblvta512x109m2wzhodcp.lef
               ts1n03esblvta512x109m4wzhodcp.lef
               ts1n03esblvta512x10m2wzhodcp.lef
               ts1n03esblvta512x10m4wzhodcp.lef
               ts1n03esblvta512x110m2wzhodcp.lef
               ts1n03esblvta512x110m4wzhodcp.lef
               ts1n03esblvta512x126m2wzhodcp.lef
               ts1n03esblvta512x126m4wzhodcp.lef
               ts1n03esblvta512x127m2wzhodcp.lef
               ts1n03esblvta512x127m4wzhodcp.lef
               ts1n03esblvta512x140m2wzhodcp.lef
               ts1n03esblvta512x140m4wzhodcp.lef
               ts1n03esblvta512x38m2wzhodcp.lef
               ts1n03esblvta512x38m4wzhodcp.lef
               ts1n03esblvta512x39m2wzhodcp.lef
               ts1n03esblvta512x39m4wzhodcp.lef
               ts1n03esblvta512x46m2wzhodcp.lef
               ts1n03esblvta512x46m4wzhodcp.lef
               ts1n03esblvta512x48m2wzhodcp.lef
               ts1n03esblvta512x48m4wzhodcp.lef
               ts1n03esblvta512x52m2wzhodcp.lef
               ts1n03esblvta512x52m4wzhodcp.lef
               ts1n03esblvta512x71m2wzhodcp.lef
               ts1n03esblvta512x71m4wzhodcp.lef
               ts1n03esblvta512x74m2wzhodcp.lef
               ts1n03esblvta512x74m4wzhodcp.lef
               ts1n03esblvta512x78m2wzhodcp.lef
               ts1n03esblvta512x78m4wzhodcp.lef
               ts1n03esblvta64x168m1wzhodcp.lef
               ts1n03esblvta64x168m2wzhodcp.lef
               ts1n03esblvta64x48m1wzhodcp.lef
               ts1n03esblvta64x48m2wzhodcp.lef
               ts1n03esblvta64x50m1wzhodcp.lef
               ts1n03esblvta64x50m2wzhodcp.lef
               ts1n03esblvta64x62m1wzhodcp.lef
               ts1n03esblvta64x62m2wzhodcp.lef
               ts1n03esblvta64x96m1wzhodcp.lef
               ts1n03esblvta64x96m2wzhodcp.lef
               ts1n03esblvtb1024x16m4wzhodxcp.lef
               ts1n03esblvtb1024x16m8wzhodxcp.lef
               ts1n03esblvtb1024x23m4wzhodxcp.lef
               ts1n03esblvtb1024x23m8wzhodxcp.lef
               ts1n03esblvtb1024x26m4wzhodxcp.lef
               ts1n03esblvtb1024x26m8wzhodxcp.lef
               ts1n03esblvtb1024x29m4wzhodxcp.lef
               ts1n03esblvtb1024x29m8wzhodxcp.lef
               ts1n03esblvtb1024x36m4wzhodxcp.lef
               ts1n03esblvtb1024x36m8wzhodxcp.lef
               ts1n03esblvtb1024x46m4wzhodxcp.lef
               ts1n03esblvtb1024x46m8wzhodxcp.lef
               ts1n03esblvtb1024x55m4wzhodxcp.lef
               ts1n03esblvtb1024x55m8wzhodxcp.lef
               ts1n03esblvtb128x111m4wzhodxcp.lef
               ts1n03esblvtb128x128m4wzhodxcp.lef
               ts1n03esblvtb128x129m4wzhodxcp.lef
               ts1n03esblvtb128x39m4wzhodxcp.lef
               ts1n03esblvtb128x39m8wzhodxcp.lef
               ts1n03esblvtb128x48m4wzhodxcp.lef
               ts1n03esblvtb128x48m8wzhodxcp.lef
               ts1n03esblvtb128x50m4wzhodxcp.lef
               ts1n03esblvtb128x50m8wzhodxcp.lef
               ts1n03esblvtb128x74m4wzhodxcp.lef
               ts1n03esblvtb256x109m4wzhodxcp.lef
               ts1n03esblvtb256x38m4wzhodxcp.lef
               ts1n03esblvtb256x38m8wzhodxcp.lef
               ts1n03esblvtb256x48m4wzhodxcp.lef
               ts1n03esblvtb256x48m8wzhodxcp.lef
               ts1n03esblvtb256x51m4wzhodxcp.lef
               ts1n03esblvtb256x51m8wzhodxcp.lef
               ts1n03esblvtb256x52m4wzhodxcp.lef
               ts1n03esblvtb256x52m8wzhodxcp.lef
               ts1n03esblvtb256x72m4wzhodxcp.lef
               ts1n03esblvtb256x72m8wzhodxcp.lef
               ts1n03esblvtb256x78m4wzhodxcp.lef
               ts1n03esblvtb256x82m4wzhodxcp.lef
               ts1n03esblvtb512x109m4wzhodxcp.lef
               ts1n03esblvtb512x10m4wzhodxcp.lef
               ts1n03esblvtb512x10m8wzhodxcp.lef
               ts1n03esblvtb512x110m4wzhodxcp.lef
               ts1n03esblvtb512x126m4wzhodxcp.lef
               ts1n03esblvtb512x127m4wzhodxcp.lef
               ts1n03esblvtb512x140m4wzhodxcp.lef
               ts1n03esblvtb512x38m4wzhodxcp.lef
               ts1n03esblvtb512x38m8wzhodxcp.lef
               ts1n03esblvtb512x39m4wzhodxcp.lef
               ts1n03esblvtb512x39m8wzhodxcp.lef
               ts1n03esblvtb512x46m4wzhodxcp.lef
               ts1n03esblvtb512x46m8wzhodxcp.lef
               ts1n03esblvtb512x48m4wzhodxcp.lef
               ts1n03esblvtb512x48m8wzhodxcp.lef
               ts1n03esblvtb512x52m4wzhodxcp.lef
               ts1n03esblvtb512x52m8wzhodxcp.lef
               ts1n03esblvtb512x71m4wzhodxcp.lef
               ts1n03esblvtb512x71m8wzhodxcp.lef
               ts1n03esblvtb512x74m4wzhodxcp.lef
               ts1n03esblvtb512x78m4wzhodxcp.lef
               ts1n03esblvtb64x48m4wzhodxcp.lef
               ts1n03esblvtb64x50m4wzhodxcp.lef
               ts1n03esblvtb64x62m4wzhodxcp.lef
               ts1n03esblvtb64x96m4wzhodxcp.lef
               	}
	set AF_LEF_FILES_MACRO {}
	set AF_LEF_FILES_IP {}
	set AF_SOCV_FILES {
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh117l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec2_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_basec_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvlc_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvlc_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvl_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvl_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvl_svtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_lvl_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc2_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pmc_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh169l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_basec2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_basec2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_basec2_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_basec2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_base_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_base_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_base_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_base_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_base_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvlc_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvlc_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvl_lvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvl_lvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvl_svtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtllssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_lvl_ulvtssgnp_0p675v_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_mb_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_mb_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_mb_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_mb_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_mb_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc2_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc2_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc2_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pmc_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pm_lvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pm_lvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pm_svtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pm_ulvtllssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv
		/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/socv/tcbn03e_bwp143mh286l3p48cpd_pm_ulvtssgnp_0p675v_m25c_cworst_CCworst_T_sp.socv

	}
	
	set AF_TECH_FILE {/usr/local/google/gcpu/orion/prj-pd/rajivdarji/Tech/Aprisa-N3E15M_1Xa1Xb1Xc1Xd1Ya1Yb4Y2Yy2Z_UTRDL_SHDMIM-m2h_143H.tcl.011624}
	set AF_RLC_MODEL_FILES {/usr/local/google/gcpu/orion/prj-pd/krishnakodali/aprisa/cdns/gcpu_ecore_lsu_wrapper_h143/tech/rlc/cworst_ccworst.rlc}
	set AF_DEFAULT_PARASITIC_CONDITION "cworst_ccworst"
	
        ################################
	### Import the verilog netlist ##
	#################################
	import_verilog "$AF_VERILOG_SEARCH_PATH/$AF_VERILOG_FILES"
	current_module $AF_CURRENT_DESIGN   
	
	###################################
	### Identify the timing libraries ##
	####################################
	set liberty_search_path $AF_LIBERTY_SEARCH_PATH
	set_link_path $AF_LIBERTY_FILES_STD
	if {$AF_LIBERTY_FILES_MACRO != {}} {
	set_link_path -append $AF_LIBERTY_FILES_MACRO
	}
	if {$AF_LIBERTY_FILES_IP != {} } {
	set_link_path -append $AF_LIBERTY_FILES_IP
	}
	
	#########################################
	### Import the technology rules and LEF ##
	##########################################
	
	source $AF_TECH_FILE
	set lef_search_path $AF_LEF_SEARCH_PATH
	foreach lef $AF_LEF_FILES_STD {
	import_lef -lib_cell_only $lef 
	}
	if {$AF_LEF_FILES_MACRO != {}} {
	foreach lef $AF_LEF_FILES_MACRO {
	import_lef -lib_cell_only $lef
	}
	}
	if {$AF_LEF_FILES_IP != {}} {
	foreach lef $AF_LEF_FILES_IP {
	import_lef -lib_cell_only $lef
	}
	}
	######################################
	### Import the parasitic information ##
	#######################################
	foreach rlc $AF_RLC_MODEL_FILES {
	source $rlc
	}
	set_parasitic_condition $AF_DEFAULT_PARASITIC_CONDITION
	#######################
	### Link the project ##
	#######################
	link_proj
        save_proj $SAVEDB/link.proj
	
        if { $PG_EEQ_STR != "" } {
	foreach lib_cell [ get_lib_cells *$PG_EEQ_STR* ] {
	set foreign_name [ get_property $lib_cell lef_foreign_name ]
	regsub $PG_EEQ_STR $foreign_name "" pg_eeq_name
	set_property $lib_cell lef_pg_eeq_cell_name $pg_eeq_name
	}
	}
	link_proj
	#####################################################
	### Set props to prevent adding new top level ports ##
	######################################################
	set_property [get_module [current_module] ] dont_add_clock_port true
	set_property [get_module [current_module] ] dont_add_signal_port true
	###################################
	### Import the timing constraints ##
	####################################
	## use this command to set timing default unit to ns
	source $SCRIPTS/mapping_all.tcl
	set_units -time ns
	foreach sdc $AF_SDC_FILES {
	if {[file exist $sdc]} {
	echo "-I- Reading $sdc" 
	source -continue_on_error $sdc 
	} else {
	echo "-E- SDC File $sdc Doesnot Exist"
	}
	}
	
	#####################################################
	### Define design power intent                      ##
	###   Either read UPF or connect global supply nets ##
	######################################################
	
	if {$AF_ENABLE_UPF == 1} {
	if {$AF_UPF_FILE == ""} {
	echo "-I- reading ${AF_CURRENT_DESIGN}\.upf from $INPUTS"
	set AF_UPF_FILE "$INPUTS/${AF_CURRENT_DESIGN}.upf"
	} else {
	echo "-I- reading $AF_UPF_FILE"
	}
	if {[file exist $AF_UPF_FILE]} {
	import_upf $AF_UPF_FILE
	#	 connect_power_domain_supply -create_module_port
	} else {
	echo "-E- $AF_UPF_FILE doesnot exist"
	return
	}  
	} else {
	connect_global_net $AF_DEFAULT_POWER_NET -usage power -pin_pattern VDD -create_port -create_module_port
	connect_global_net $AF_DEFAULT_GROUND_NET -usage ground -pin_pattern VSS -create_port -create_module_port
	}
	
	###########################
	### Fix any name conflicts ##
	#############################
	check_project -fix_conflict_name -fix_hier_net -fix_dup_name
	
	################
	### MCMM setup ##
	#################
	set AF_ENABLE_ALL_SCENARIO 0 
	set AF_DEFAULT_SETUP_SCENARIO "func.ssgnp-NM-m25-cworst_ccworst"
	set  AF_MCMM_SEARCH_PATH ./scripts/mcmm
	if { [file exist ./scripts/mcmm/mcmm.tcl] } {
	set AF_MCMM_FILE ./scripts/mcmm/mcmm.tcl
	}
	if {$AF_MCMM_SEARCH_PATH != {}} {
	echo "-I- Sourcing $AF_MCMM_FILE"
	set scenario_search_path $AF_MCMM_SEARCH_PATH 
	# set AF_MCMM_FILE scripts/mcmm/mcmm.tcl	
	source -echo -v $AF_MCMM_FILE
	} else {
	echo "-E- $AF_MCMM_FILE doesnot exist"
	return
	}
	
	if {$AF_ENABLE_ALL_SCENARIO == 1} { 
	current_mcmm -every
	} elseif {$AF_DEFAULT_SETUP_SCENARIO != ""} {
	current_mcmm $AF_DEFAULT_SETUP_SCENARIO
	};	
	#################################
	### Source customization script ##
	################################## 
	set STEP "post"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	check_project -remove_assign
	##################################
	### Run some basic design checks ##
	###################################
	check_netlist
	check_setup
	check_timing_setup
	
	#######################
	### Save the project ##
	#######################
	save_project -symbolic_link_for_lib $SAVEDB/init.proj 
	puts  "Generated init flow script:init.tcl"
	exec cp scripts/custom/flowgen_custom_inputs.tcl $SAVEDATA/flowgen_custom_inputs.tcl
	exec cp $PARAMS/${PHASE}_params.tcl $SAVEDATA/${PHASE}_params.tcl
	set use_flow_params_for_reports 0
	if { $use_flow_params_for_reports } { report_param -all > $SAVERPT/${PHASE}_params.tcl }
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
