
source ./scripts/custom/lib_lef_search_path.tcl
   

# Load libs
 
set liberty_search_path_std "$AF_LIBERTY_SEARCH_PATH_STD" 
set liberty_search_path_macro "" 
set liberty_search_path_ip ""
set liberty_search_path "$AF_LIBERTY_SEARCH_PATH" 
set mcmm_liberty_file_std "$AF_LIBERTY_FILES_STD"
set mcmm_liberty_file_macro {}
set mcmm_liberty_file_ip {}

 set_link_path $mcmm_liberty_file_std
 if {$mcmm_liberty_file_macro != {}} {
	set_link_path -append $mcmm_liberty_file_macro
} 
if {$mcmm_liberty_file_ip != {}} {
	set_link_path -append $mcmm_liberty_file_ip
}


# link design
link_project 

# Read SDC
#source $AF_SDC_FILES
foreach sdc $AF_SDC_FILES {
        if {[file exist $sdc]} {
        echo "-I- Reading $sdc"
        source -continue_on_error $sdc
        } else {
        echo "-E- SDC File $sdc Doesnot Exist"
        }
        }

import_ocv_table "$AF_SOCV_FILES"

set_param ta timing_lvf_enable_analysis true
set_param ta timing_socvm_enable_analysis true  

#Set parasitic condition
set_parasitic_condition cworst_ccworst
 
#set_operating_condition
set_operating_condition -analysis_type on_chip_variation
#Set Delay type
set_timing_delay_type min_max
  
  
