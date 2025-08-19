    set LOADREVISION default
	set SAVEREVISION   $LOADREVISION
	set CUSTOM_SCRIPT  $ROOT/scripts/custom
	set PARAMS         $ROOT/scripts/params
	set SCRIPTS        $ROOT/scripts
	set LOADDB	   $ROOT/${LOADREVISION}/db
	set LOADDATA       $ROOT/${LOADREVISION}/data
	set INPUT          $ROOT/inputs
	set LOCAL_SCRIPTS  $ROOT/local_scripts 
	set SAVEDB         $ROOT/${SAVEREVISION}/db
	set SAVEDATA       $ROOT/${SAVEREVISION}/data
	set SAVERPT	   $ROOT/${SAVEREVISION}/rpts
	set SAVELOGS       $ROOT/${SAVEREVISION}/log
	set OUTPUT         $ROOT/${SAVEREVISION}/output
    catch {exec mkdir -p $SAVERPT}
    catch {exec mkdir -p $SAVELOGS}
    catch {exec mkdir -p $SAVEDB}
    catch {exec mkdir -p $SAVEDATA}
    catch {exec mkdir -p $OUTPUT}
    catch {exec mkdir -p $INPUT}
    exec cp [info script] $SAVEDATA/$PHASE.tcl
    ##################end header############################
    
