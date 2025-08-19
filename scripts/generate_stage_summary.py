#!/pkg/qct/software/anaconda/anaconda3-4.3.1/anaconda3/bin/python
'''
read Aprisa PnR output reports to build CSV results summary table

This application expects to be given a string list of file names

Usage:

dump_report_excel.py "route1 cts1"

Output files:
    csv_file_path = main_dir + '/' + my_stage + '/data/reports/' + my_stage + '.csv'
    txt_file_path = main_dir + '/' + my_stage + '/data/reports/' + my_stage + '.txt'

Input files:
    /data/reports/
      *.allowed_lib_cell.rpt
      my_stage + '.csv'
      my_stage + '.txt'

  lib_prep
  build_db
      mcmm.rpt
  place
      place_check.report
      placement.report
  cts
      skew.rpt
      drv.rpt
      clkcells.rpt
      power.rpt
      mvt.rpt
      vt_detail.rpt
  route


'''

import sys
import csv
import re
# import time
# import json
import os
# import getpass
import math
import glob
import datetime
import shutil
class ReportParser:
    '''
    generalized ReportParser base class

    has no test
    '''

    def __init__(self, run_name, stage, report_name):
        '''

        has no test
        '''
        try:
            self.tab = dict()
            self.stage = stage
            self.ffp = ''
            self.ffn = ''
            self.ffi = ''
            if report_name == "log":
                self.ffi = main_dir + '/' + run_name + '/log/' + stage+ '.' + report_name
                cmds = list()
                cmds.append('egrep')
                # pylint: disable=line-too-long
                cmds.append('"Warnings & |Elapsed|Combined|Finish|Peak|load_proj|Number of phyCore|Aprisa Version|version:"')
                # pylint: enable=line-too-long
                cmds.append(self.ffi)
                cmds.append('> ./.tmplog')
                cmd = ' '.join(cmds)
                os.system(cmd)
                # pylint: disable=line-too-long
                # os.system('egrep  " Warnings & |Elapsed|Combined|Finish|Peak|load_proj|Number of phyCore|Aprisa Version|version:" ' + self.ffi + '  > ./.tmplog')
                # pylint: enable=line-too-long
                self.ffn = './.tmplog'
            elif report_name == "timing.summary.*":
                self.ffi = main_dir + '/' + run_name + '/rpts/' + stage+ '.timing.summary.*'
                cmds = list()
                cmds.append('egrep "RRWNS|CGWNS" ')
                cmds.append(self.ffi)
                cmds.append(' > ./.tmgsum')
                cmd = ' '.join(cmds)
                os.system(cmd)
                self.ffn = './.tmgsum'
            elif report_name == "max.qor.*":
                self.ffi = main_dir + '/' + run_name + '/rpts/' + stage+ '.max.qor.*'
                cmds = list()
                cmds.append('cat ')                
                cmds.append(self.ffi)                
                cmds.append('| egrep "Setup Timing Summary"  ')
                #cmds.append(self.ffi)
                cmds.append('|sort |uniq -c')                
                cmds.append(' > ./.tmgsum')
                cmd = ' '.join(cmds)
                os.system(cmd)
                self.ffn = './.tmgsum'
            elif report_name == "min.qor.*":
                self.ffi = main_dir + '/' + run_name + '/rpts/' + stage+ '.min.qor.*'
                cmds = list()
                cmds.append('cat ')                
                cmds.append(self.ffi)
                cmds.append('| egrep "Hold Timing Summary" ')
                #cmds.append(self.ffi)
                cmds.append('|sort |uniq -c')
                cmds.append(' > ./.tmgsum')
                cmd = ' '.join(cmds)
                os.system(cmd)
                self.ffn = './.tmgsum'

            else:
                self.ffn = main_dir+'/'+run_name + '/rpts/' + stage + '.' + report_name
            self.ffp = open(self.ffn, 'r')
        except IOError as _exx:
            self.ffp = ''

class SetupParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'max.qor.*')
        self.tab['Setup Views'] = 0

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.search(r'Setup Timing Summary',line)
            if match:
               self.tab['Setup Views'] += 1
        return self.tab

class HoldParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'min.qor.*')
        self.tab['Hold Views'] = 0

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.search(r'Hold Timing Summary',line)
            if match:
               self.tab['Hold Views'] += 1
        #os.system('rm ./.tmgsum')

        return self.tab

class FlowVariableParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'rundetails.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.match('.*Tag Name:(.*)', line)
            if match:
                self.tab['Tag Name'] = match.group(1).strip()
            match = re.match('.*Flow Name:(.*)', line)
            if match:
                self.tab['Flow Name'] = match.group(1).strip()
        return self.tab

class TimingParserNew(ReportParser):
    '''

    has no test
    '''

    def __init__(self, stage_name, stage):
        ReportParser.__init__(self, stage_name, stage, 'timing.summary.*')
        
    def parse(self):

        if not self.ffp:
            return self.tab

	for var in ('Setup R2ICG WNS','Setup R2ICG TNS','Setup R2ICG NFE','Setup R2R WNS','Setup R2R TNS','Setup R2R NFE','Hold R2R WNS','Hold R2R TNS','Hold R2R NFE'):
		self.tab[var] = None
        for line in self.ffp:
            # pylint: disable=line-too-long
            match = re.search(r'.* CGWNS\[(.*?):(.*?) \]. * CGTNS\[(.*?) :(.*?) \] .* CGFEP\[(.*?) :(.*?) \]', line)
            # pylint: enable=line-too-long
            if match:
		if self.tab ['Setup R2ICG WNS'] == None:
                	self.tab['Setup R2ICG WNS'] = match.group(1).strip()
                	self.tab['Setup R2ICG TNS'] = float(match.group(3).strip())
                	self.tab['Setup R2ICG NFE'] = int(match.group(5).strip())
		else :
			if match.group(1).strip() != '-':
				if self.tab['Setup R2ICG WNS'] != '-':
					self.tab['Setup R2ICG WNS'] = min(self.tab['Setup R2ICG WNS'],float(match.group(1).strip()))
				else :
					self.tab['Setup R2ICG WNS'] = float(match.group(1).strip())
			self.tab['Setup R2ICG WNS'] = match.group(1).strip()
                	self.tab['Setup R2ICG TNS'] = self.tab['Setup R2ICG TNS'] + float(match.group(3).strip())
                	self.tab['Setup R2ICG NFE'] = self.tab['Setup R2ICG NFE'] + int(match.group(5).strip())

            
            match1 = re.search(r'.* RRWNS\[(.*?):(.*?) \] .* RRTNS\[(.*?) :(.*?) \] .* RRFEP\[(.*?) :(.*?) \]', line)
            if match1:
	    	if self.tab ['Setup R2R WNS'] == None:	    	
                	self.tab['Setup R2R WNS'] = match1.group(1).strip()
                	self.tab['Setup R2R TNS'] = float(match1.group(3).strip())
                	self.tab['Hold R2R WNS'] = match1.group(2).strip()
                	self.tab['Hold R2R TNS'] = float(match1.group(4).strip())
                	self.tab['Setup R2R NFE'] = int(match1.group(5).strip())
                	self.tab['Hold R2R NFE'] = int(match1.group(6).strip())

		else :
			if match1.group(1).strip() != '-':
				if self.tab['Setup R2R WNS'] != '-':
					self.tab['Setup R2R WNS'] = min(self.tab['Setup R2R WNS'],float(match1.group(1).strip()))
				else :
					self.tab['Setup R2R WNS'] = float(match1.group(1).strip())
                	self.tab['Setup R2R TNS'] = self.tab['Setup R2R TNS'] + float(match1.group(3).strip())
                	self.tab['Setup R2R NFE'] = self.tab['Setup R2R NFE'] + int(match1.group(5).strip())

			if match1.group(2).strip() != '-':
				if self.tab['Hold R2R WNS'] != '-':
					self.tab['Hold R2R WNS'] = min(self.tab['Hold R2R WNS'],float(match1.group(2).strip()))
				else :
					self.tab['Hold R2R WNS'] = float(match1.group(2).strip())
                	self.tab['Hold R2R TNS'] =  self.tab['Hold R2R TNS'] + float(match1.group(4).strip())
                	self.tab['Hold R2R NFE'] =  self.tab['Hold R2R NFE'] +  int(match1.group(6).strip())

	for var in ('Setup R2ICG WNS','Setup R2ICG TNS','Setup R2R WNS','Setup R2R TNS','Hold R2R WNS','Hold R2R TNS'):
		if self.tab[var] != '-' and self.tab[var]!= None:
			self.tab[var] = round(float(self.tab[var]),3)

	
        return self.tab

class TimingParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'timing.summary')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        if not self.parse_all():
            self.parse_single()
        return self.tab

    def parse_all(self):
        '''

        has no test
        '''
        flag1 = False
        flag2 = False
        flag3 = False
        for line in self.ffp:
            match = re.match('.*ALL.*', line)
            if not match:
                continue
            if not flag1:
                match = re.search(r'.*WNS\[(.*?):(.*?) \] .* TNS\[(.*?) :(.*?) \] .* FEP\[(.*?) :', line)
                if match:
                    self.tab['wns'] = match.group(1).strip()
                    self.tab['tns'] = match.group(3).strip()
                    self.tab['hwns'] = match.group(2).strip()
                    self.tab['htns'] = match.group(4).strip()
                    self.tab['sfep'] = match.group(5).strip()
                    flag1 = True
            if not flag2:
                # pylint: disable=line-too-long
                match1 = re.search(r'.* RRWNS\[(.*?):(.*?) \] .* RRTNS\[(.*?) :(.*?) \] .* RRFEP\[(.*?) :(.*?) \]', line)
                # pylint: enable=line-too-long
                if match1:
                    self.tab['Setup R2R WNS'] = match1.group(1).strip()
                    self.tab['Setup R2R TNS'] = match1.group(3).strip()
                    self.tab['Hold R2R WNS'] = match1.group(2).strip()
                    self.tab['Hold R2R TNS'] = match1.group(4).strip()
                    self.tab['Setup R2R NFE'] = match1.group(5).strip()
                    self.tab['Hold R2R NFE'] = match1.group(6).strip()
                    flag2 = True
            if not flag3:
                # pylint: disable=line-too-long
                match1 = re.search(r' .* CGWNS\[(.*?):(.*?) \] .* CGTNS\[(.*?) :(.*?) \] .* CGFEP\[(.*?) :(.*?) \]', line)
                # pylint: enable=line-too-long
                if match1:
                    self.tab['Setup R2ICG WNS'] = match1.group(1).strip()
                    self.tab['Setup R2ICG TNS'] = match1.group(3).strip()
                    self.tab['ighwns'] = match1.group(2).strip()
                    self.tab['ightns'] = match1.group(4).strip()
                    self.tab['Setup R2ICG NFE'] = match1.group(5).strip()
                    self.tab['ighfep'] = match1.group(6).strip()
                    flag3 = True
            if flag1 and flag2 and flag3:
                return True
        return False

    def parse_single(self):
        '''

        has no test
        '''
        flag1 = False
        flag2 = False
        # flag3 = False
        self.ffp.seek(0)
        for line in self.ffp:
            # pylint: disable=line-too-long
            match = re.search(r'.* IGWNS\[(.*?):(.*?) \]. * IGTNS\[(.*?) :(.*?) \] .* IGFEP\[(.*?) :(.*?) \]', line)
            # pylint: enable=line-too-long
            if match:
                self.tab['Setup R2ICG WNS'] = match.group(1).strip()
                self.tab['Setup R2ICG TNS'] = match.group(3).strip()
                self.tab['ighwns'] = match.group(2).strip()
                self.tab['ightns'] = match.group(4).strip()
                self.tab['Setup R2ICG NFE'] = match.group(5).strip()
                self.tab['ighfep'] = match.group(6).strip()
                flag1 = True
            else:
                # pylint: disable=line-too-long
                match1 = re.search(r'.* RRWNS\[(.*?):(.*?) \] .* RRTNS\[(.*?) :(.*?) \] .* RRFEP\[(.*?) :(.*?) \]', line)
                # pylint: enable=line-too-long
                if match1:
                    self.tab['Setup R2R WNS'] = match1.group(1).strip()
                    self.tab['Setup R2R TNS'] = match1.group(3).strip()
                    self.tab['Hold R2R WNS'] = match1.group(2).strip()
                    self.tab['Hold R2R TNS'] = match1.group(4).strip()
                    self.tab['Setup R2R NFE'] = match1.group(5).strip()
                    self.tab['Hold R2R NFE'] = match1.group(6).strip()
                    flag2 = True
            if flag1 and flag2:
                return True
        return False



class PlaceCheckParser(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'place_check.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        if re.search(r'build_db', self.stage):
            self.tab['Place Violations'] = 0
        for line in self.ffp:
            match = re.match(r'.*No.*violation.*', line)
            if match:
            	self.tab['Place Violations'] = 0
            	break
            if re.search(r'build_db', self.stage):
            	match2 = re.match(r' .*Fixed.*violation:(.*)', line)
            	if match2:
            		self.tab['Place Violations'] = match2.group(1).strip()
                        break
            else:
            	match2 = re.match(r' .*Total.*violation:(.*)', line)
            	if match2:
            		self.tab['Place Violations'] = match2.group(1).strip()
                        break
        #
        return self.tab

# class LicenseParser(ReportParser):
#     '''
#     '''
#     def __init__(self, stage):
#         '''
#
#         has no test
#         '''
#         ReportParser.__init__(self, stage, 'license.rpt')
#
#     def parse(self):
#         '''
#
#         has no test
#         '''
#         if self.ffp == None:
#             return self.tab
#         for line in self.ffp:
#             match = re.match(r'.*AprisaAPR:([0-9]+)', line)
#             if match:
#                 b = match.group(1)
#                 self.tab['Licenses'] = b[0]
#         return self.tab


class DRVParser2(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage, scn):
        '''

        has no test
        '''
    	rpt_path = main_dir+'/'+run_name + '/rpts/' 
    	summary_exists = len(glob.glob(rpt_path+stage+'.drv.rpt'))
    	if summary_exists == 1:
        	ReportParser.__init__(self, run_name, stage, 'drv.rpt')
	else :
		file_name = 'drv.rpt.'+scn 
        	ReportParser.__init__(self, run_name, stage, file_name)

        self.scn = scn
        self.stage = stage

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        scn_t = ''
        # my_scn = ''
        for line in self.ffp:
            match = re.search(r'.*Design.*:(.*)', line)
            if match:
                bbx = match.group(1).split()
                self.tab['Design'] = bbx[0]
            match = re.search(r'.*Scenario: (.*)', line)
            if match:
                scn_t = match.group(1).strip()
            if scn_t == self.scn:
                match = re.match(r'.*max_capacitance.*', line)
                if match:
                    bbx = match.group().split()
                    self.tab['Max Cap NFE'] = bbx[6]
                match = re.match(r'.*max_fanout.*', line)
                if match:
                    bbx = match.group().split()
                    self.tab['Max Fanout NFE'] = bbx[6]
                match = re.match(r'.*max_transition.*', line)
                if match:
                    bbx = line.split()
                    self.tab['Max Trans WNS'] = bbx[2]
                    self.tab['Max Trans TNS'] = bbx[4]
                    self.tab['Max Trans NFE'] = bbx[6]
        return self.tab



class MVTParser(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'mvt.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.match (r'Vt Level-1 .*?\(.*?\((.*?)%',line)
            if match :
                b = match.group(1).split ()
                self.tab ['ULVT'] = b[0]
            match = re.match (r'Vt Level-2 .*?\((.*?)%',line)
            if match :
                b = match.group(1).split ()
                self.tab ['LVT'] = b[0]
            match = re.match (r'Vt Level-3 .*?\((.*?)%',line)
            if match :
                b = match.group(1).split ()
                self.tab ['SVT'] = b[0]
            match = re.match(r'Low Vt .*?\(.*?\((.*?)%', line)
            if match:
                bbx = match.group(1).split()
                self.tab['ULVT'] = bbx[0]
            match = re.match(r'Normal Vt .*?\((.*?)%', line)
            if match:
                bbx = match.group(1).split()
                self.tab['LVT'] = bbx[0]
            match = re.match(r'High Vt .*?\((.*?)%', line)
            if match:
                bbx = match.group(1).split()
                self.tab['SVT'] = bbx[0]
            match = re.match(r'Un-Classified Vt .*?\((.*?)%', line)
            if match:
                bbx = match.group(1).split()
                self.tab['Un-Classified VT'] = bbx[0]
                break
        return self.tab


class UtilizationParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'placement.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.search(r'die area \s+=(.*?)\(u', line)
            if match:
                self.tab['Floorplan Area'] = match.group(1).strip()
            match = re.match(r'.*die utilization \s+=(.*?)%', line)
            if match:
                self.tab['Floorplan Util'] = match.group(1).strip()
            match = re.match(r'.*core utilization \s+=(.*?)%', line)
            if match:
                self.tab['util'] = match.group(1).strip()
            match1 = re.match(r' .*macro cell area.*=(.*?)\(u', line)
            if match1:
                self.tab['Macro Area'] = match1.group(1).strip()
            match2 = re.match(r' .*std cell area.*=(.*?)\(u', line)
            if match2:
                self.tab['Std Cell Area'] = match2.group(1).strip()
            match5 = re.search(r'placeable cell area \s+=(.*?)\(u', line)
            if match5:
                self.tab['Row Area'] = match5.group(1).strip()
            match3 = re.match(r'.*std-cell utilization.*=(.*?)%', line)
            if match3:
                self.tab['Std Cell Util'] = match3.group(1).strip()
            match4 = re.search(r'.*# std cells.*=(.*)', line)
            if match4:
                self.tab['Std Cell Count'] = match4.group(1).strip()
        return self.tab

class CTSParser3(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage, scn):
        '''

        has no test
        '''
        rpt_path = main_dir+'/'+run_name + '/rpts/' 
    	summary_exists = len(glob.glob(rpt_path+stage+'.skew.rpt'))
    	if summary_exists == 1:
        	ReportParser.__init__(self, run_name, stage, 'skew.rpt')
	else :
		file_name = 'skew.rpt.'+scn 
        	ReportParser.__init__(self, run_name, stage, file_name)

        self.scn = scn

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab

        sink = 0
        sg_scan = 0
        max_lat = ''
        global_skew = ''
        slew_mean = ''
        skew_group = ''
        slew_max = ''
        avg_lat = ''
        avg_skew = ''
        for line in self.ffp:
            match = re.search(r'.*Scenario.*: (.*)', line)
            if match:
                scn1 = match.group(1)
            match = re.search(r'.*Skew Group:(.*)', line)
            if match and scn1 == self.scn:
                skew_group = match.group(1)
                match2 = re.search(r'.*SCAN.*', skew_group)
                if match2:
                    sg_scan = 1
            match = re.search(r'.*Sink Number: (.*)', line)
            if match and scn1 == self.scn:
                my_sink = int(match.group(1))
                sink = max(sink, my_sink)
            match = re.search(r'.*Max Latency .*:(.*)', line)
            if match and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                max_lat = float(match.group(1))
            match = re.search(r' Skew\s+: (.*)', line)
            if match and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                global_skew = float(match.group(1))
            match = re.search(r' AvgSkew\s+: (.*)', line)
            if match and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                avg_skew = float(match.group(1))
            match = re.search(r'.*Average Latency:.*max = (.*)', line)
            if match and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                avg_lat = float(match.group(1))
            match = re.search(r'.*Average Transition.*:(.*)', line)
            if match  and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                slew_mean = float(match.group(1))
            match = re.search(r'.*Max Transition\s+: (.*)', line)
            if match and scn1 == self.scn and my_sink == sink and sg_scan != 1:
                slew_max = float(match.group(1))
        self.tab['Max Latency'] = max_lat
        self.tab['Global Skew'] = global_skew
        self.tab['Avg Latency'] = avg_lat
        self.tab['Slew Mean'] = slew_mean
        self.tab['Slew Max'] = slew_max
        self.tab['Avg Skew'] = avg_skew
        return self.tab



class CTSCells(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'clkcells.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab

        for line in self.ffp:
            match = re.match(r'Clock Cells\s*:(.*)', line)
            if match:
                self.tab['Clock Cells'] = match.group(1).strip()
            match = re.match(r'Clock Buf+Inv\s*:(.*)', line)
            if match:
                self.tab['Clock Buf+Inv Cells'] = match.group(1).strip()

            match = re.match(r'Clock BUf+Inv Cells area\s*:(.*)', line)
            if match:
                self.tab['Clock Buf+Inv Area'] = round(float(match.group(1).strip()), 2)
            match = re.match(r'Clock Buffers\s*:(.*)', line)
            if match:
                self.tab['Clock Buffers'] = match.group(1).strip()
            match = re.match(r'Clock Inverters\s*:(.*)', line)
            if match:
                self.tab['Clock Inverters'] = match.group(1).strip()
            match = re.match(r'Clock ICG\s*:(.*)', line)
            if match:
                self.tab['Clock ICG'] = match.group(1).strip()
                break
            match = re.match(r'Clock Logic\s*:(.*)', line)
            if match:
                self.tab['Clock Logic'] = match.group(1).strip()

            match = re.match(r'Percentage of hold area\s*:(.*)', line)
            if match:
                self.tab['Hold Fix PCT'] = match.group(1).strip()

        return self.tab

class HOLDCells(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'hldcells.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab

        for line in self.ffp:
            match = re.match(r'Percentage of hold area\s*:(.*)', line)
            if match:
                self.tab['Hold Fix PCT'] = match.group(1).strip()
		break
        return self.tab


class  ScanParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'scan.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.match(r'.*Total length(.*)half', line)
            if match:
                bbx = line.split(' ')
                self.tab['Scan WireLength'] = round(float(bbx[3]), 2)
        return self.tab


class PowerParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage, scn):
        '''

        has no test
        '''
        self.scn = scn
        self.stage = stage

        ReportParser.__init__(self, run_name, stage, 'power.rpt')


    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab

        for line in self.ffp:
            match = re.search(r'.*Scenario\s+: (\w.*)', line)
            if match:
                my_scn = match.group(1)
            match1 = re.search(r'.*Sum.*', line)
            if match1 and my_scn == self.scn:
                bbx = line.split()
                self.tab['Leakage'] = bbx[2]
        return self.tab

class OpenShortParser(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'verify_la.sig.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.search(r'(\d+)\s*:\s*short.*', line)
            if match:
                self.tab['sig_la_shorts'] = int(match.group(1))
            match = re.search(r'nets with open\s*:\s*(\d+)', line)
            if match:
                self.tab['Sig Opens'] = int(match.group(1))
        return self.tab

class PGOpenShortParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'verify_la.pg.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.search(r'(\d+)\s*:\s*short.*', line)
            if match:
                self.tab['PG shorts'] = int(match.group(1))
            match = re.search(r'nets with open\s*:\s*(\d+)', line)
            if match:
                self.tab['PG Opens'] = int(match.group(1))
        return self.tab


class FillerGapParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'filler_gap.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        for line in self.ffp:
            match = re.match(r'.*void_gap:(.*)', line)
            if match:
                bbx = match.group(1).split()
                self.tab['Filler Gaps'] = bbx[0]
        return self.tab

class ResParser(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'supply_res.rpt')
	
    def parse(self):
        '''

        has no test
        '''
        if self.ffp == None:
            return self.tab
        vios = 0
        for line in self.ffp:
            match = re.search(r'#Vio\s*=+ *(\d+)', line)
            if match:
                vios = vios + int(match.group(1))
                self.tab['Resistance Vios'] = vios
        return self.tab

class DFMviaParser(ReportParser):
    '''

    has no test
    '''
    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'via.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        hirc = float()
        lorc = float()
        for line in self.ffp:
            match = re.match(r'Metal-(\d+) wire length\s+(\d*\.\d+?)\s+(\d*\.\d+?) ', line)
            if match:
                idx = int(match.group(1))
                if idx < 5:
                    hirc += float(match.group(3))
                else:
                    lorc += float(match.group(3))
            match = re.match(r'.*Total wire length(.*)', line)
            if match:
                bbx = match.group(1).split()
                self.tab['WL'] = round(float(bbx[1]), 2)

            match = re.search(r'(\d+)\s*:\s*short', line)
            if match:
                self.tab['Sig Shorts'] = int(match.group(1))
            match = re.search(r'^\s*(\d+)\s*:\s*Total DRC violations', line)
            if match:
                self.tab['DRC'] = int(match.group(1))
            # pylint: disable=line-too-long
            match = re.match(r'\s*\d+\.\d+%\s+\d+\.\d+%\s+\d+\.\d+%\s+\d+\.\d+%\s+\d+\.\d+%\s+(\d+\.\d+)%', line)
            # pylint: enable=line-too-long
            if match:
                self.tab['DFM Via'] = round(100 - float(match.group(1)), 2)
        self.tab['WL_high_rc'] = round(float(hirc), 2)
        self.tab['WL_low_rc'] = round(float(lorc), 2)
        return self.tab

class RuntimeLogParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        self.stage = stage
        ReportParser.__init__(self, run_name, stage, 'log')

        self.runtime = 0
        self.cputime = 0
        self.cputime_8cores = 0
        self.walltime_8cores = 0

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        reported_ss = 0
        ss_tt2 = 0
        peak_memory = 0.0
        ccx = ''
        eex = ''
        lne1 = ''
        start_en = 1
        start_time = None
        end_time = None
        for line in self.ffp:
            if len(line) < 1000:
            	match = re.search (r'QC-INFO:\s+{(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)} ',line)
            	if match :
                	if start_en==1 :  
                    		start_time = datetime.datetime(int(match.group(1)),int(match.group(2)),int(match.group(3)),int(match.group(4)),int(match.group(5)),int(match.group(6)))
                    		start_en = 0
                	else :
                    		end_time = datetime.datetime(int(match.group(1)),int(match.group(2)),int(match.group(3)),int(match.group(4)),int(match.group(5)),int(match.group(6)))

            	if re.match(r'init', self.stage):
                	match = re.search(r'.*INIT.*Elapsed = (.*?);.* CPU =(.*?);', line)
                	if match:
                    		tt2 = match.group(2).split(':')
                    		tt1 = match.group(1).split(':')
                    		reported_ss += int(tt1[2]) + 60 * int(tt1[1]) + 3600 * int(tt1[0])
                    		ss_tt2 += int(tt2[2]) + 60 * int(tt2[1]) + 3600 * int(tt2[0])
            	if re.match(r'place', self.stage):
                	match = re.search(r'.*Place_opti.*Finish.*Elapsed = (.*?);.*CPU =(.*?);', line)
                	if match:
                    		tt2 = match.group(2).split(':')
                    		tt1 = match.group(1).split(':')
                    		reported_ss += int(tt1[2]) + 60 * int(tt1[1]) + 3600 * int(tt1[0])
                    		ss_tt2 += int(tt2[2]) + 60 * int(tt2[1]) + 3600 * int(tt2[0])
            	if  re.match(r'^cts', self.stage):
                	match = re.search(r'.*Synthesize_skew_group Finish.*Elapsed = (.*?);.*CPU =(.*?);', line)
                	if match:
                    		tt2 = match.group(2).split(':')
                    		tt1 = match.group(1).split(':')
                    		reported_ss += int(tt1[2]) + 60 * int(tt1[1]) + 3600 * int(tt1[0])
                    		ss_tt2 += int(tt2[2]) + 60 * int(tt2[1]) + 3600 * int(tt2[0])
            	if re.match(r'post_cts', self.stage):
                	match = re.search(r'.*Post_cts_opt.*Finish.*Elapsed = (.*?);.*CPU =(.*?);', line)
                	if match:
                    		tt2 = match.group(2).split(':')
                    		tt1 = match.group(1).split(':')
                    		reported_ss += int(tt1[2]) + 60 * int(tt1[1]) + 3600 * int(tt1[0])
                    		ss_tt2 += int(tt2[2]) + 60 * int(tt2[1]) + 3600 * int(tt2[0])
            	if re.match(r'route', self.stage):
                	match = re.search(r'.*Droute_opt.*Finish.*Elapsed = (.*?);.*CPU =(.*?);', line)
                	if match:
                    		tt2 = match.group(2).split(':')
                    		tt1 = match.group(1).split(':')
                    		reported_ss += int(tt1[2]) + 60 * int(tt1[1]) + 3600 * int(tt1[0])
                    		ss_tt2 += int(tt2[2]) + 60 * int(tt2[1]) + 3600 * int(tt2[0])
            	match = re.search(r'.*Elapsed.*VM =(.*?)M', line)
            	if match:
                	mem = float(match.group(1))
                	peak_memory = max(peak_memory, mem)
            	match = re.search(r'(.*)Warnings.*', line)
            	if match:
                	bbx = match.group(1).strip()
                	self.tab['Warnings'] = bbx[0]
            	match = re.search(r'.*&(.*) Errors at.*', line)
            	if match:
                	bbx = match.group(1).split()
                	self.tab['Errors'] = bbx[0]

                match = re.search (r'.*Aprisa Version: (\d+\.*\d*).*:(.*).(\d+).(\d\d)(\d\d).(\d\d)',line)
                if match :
                    self.tab['AP Version'] = match.group(1)+'/'+str(match.group(4))+'.'+str(match.group(5))+'.'+str(match.group(6))

            	#match = re.search(r'.*AP [(]+version:(.*)[)]+', line)
            	#if match:
                #	bbx = match.group(1).split()
                #	self.tab['AP Version'] = bbx[0]
            	match = re.search(r'Number of phyCore Used = (\d+)', line)
            	if match:
                	bbx = int(match.group(1))
                	self.tab['Num of Threads'] = bbx
                	self.tab['Licenses'] = math.ceil(int(bbx)/8.0)
            	match = re.match(r'.*finished.*load_proj.*Time(.*?)>', line)
            	if match:
                	bbx = match.group(1).split()
                	self.tab['design_load_time'] = bbx[0]
            	match = re.search(r'.*Machine.*', line)
            	if match:
                	self.tab['License_checkedout'] = match.group()
            	match = re.search(r'.*Combined.*Hor.*total =(.*) in(.*?%)', line)
            	if match:
                	ccx = match.group(2).split()
                	ddx = match.group(1).split()
                	self.tab['Horz Cong'] = ccx[0]
                	self.tab['Horz Tot Overflow'] = ddx[0]
                	lne1 = line
                	match = re.search(r'.*Combined.*Hor.*max.*', lne1)
                	if match:
                    		eex = match.group().split()
                    		self.tab['Horz Cong'] = eex[11]
                    		self.tab['Horz Max Overflow'] = eex[6]
                    		self.tab['Horz Tot Overflow'] = eex[9]
            	match = re.search(r'.*Combined.*Ver.*total =(.*) in(.*?%)', line)
            	if match:
                	bbx = match.group(2).split()
                	ccx = match.group(1).split()
                	self.tab['Vert Cong'] = bbx[0]
                	self.tab['Vert Tot Overflow'] = ccx[0]
                	lne2 = line
                	match = re.search(r'.*Combined.*Ver.*max.*', lne2)
                	if match:
                    		eex = match.group().split()
                    		self.tab['Vert Cong'] = eex[11]
                    		self.tab['Vert Max Overflow'] = eex[6]
                    		self.tab['Vert Tot Overflow'] = eex[9]

        self.runtime = reported_ss
        self.cputime = ss_tt2
        ss_tt3 = int(ss_tt2/8)
        ss_tt4 = int(reported_ss/8)
        self.cputime_8cores = ss_tt3
        self.walltime_8cores = ss_tt4
        reported_mm, reported_ss = divmod(reported_ss, 60)
        reported_hh, reported_mm = divmod(reported_mm, 60)
        self.tab['runtime'] = '{:d}:{:02d}:{:02d}'.format(reported_hh, reported_mm, reported_ss)
        self.tab['Runtime'] = self.tab['runtime']
        #if start_time != None and end_time != None:
        #        runtime = str(end_time-start_time)
        #        match1 = re.search (r'(\d+) days, (\d+):(\d+:\d+)',runtime)
        #        if match1 :
        #                hours = int(int(match1.group(1))*24)+ int(match1.group(2))
        #                runtime = str(hours) + ':' + match1.group(3)
        #        self.tab['Runtime'] = runtime
        #else :
        #        self.tab['Runtime'] = "-"
        mm_tt2, ss_tt2 = divmod(ss_tt2, 60)
        hh_tt2, mm_tt2 = divmod(mm_tt2, 60)
        self.tab['CPUtime'] = '{:d}:{:02d}:{:02d}'.format(hh_tt2, mm_tt2, ss_tt2)
        mm_tt3, ss_tt3 = divmod(ss_tt3, 60)
        hh_tt3, mm_tt3 = divmod(mm_tt3, 60)
        self.tab['cputime_8cores'] = '{:d}:{:02d}:{:02d}'.format(hh_tt3, mm_tt3, ss_tt3)
        mm_tt4, ss_tt4 = divmod(ss_tt4, 60)
        hh_tt4, mm_tt4 = divmod(mm_tt4, 60)
        self.tab['walltime_8cores'] = '{:d}:{:02d}:{:02d}'.format(hh_tt4, mm_tt4, ss_tt4)
        peak_memory = round(peak_memory/1000, 2)
        self.tab['Peak Memory'] = str(peak_memory)+'GB'
        os.system('rm -rf ./.tmplog')
        return self.tab


class ViewsParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'mcmm.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab
        aax = 'no_corner_found_in_ffp' # initialize aax to deal with empty or unexpected file content
        bbx = []
        ccx = []
        for line in self.ffp:
            aax = line.split()
            for each in aax:
                match = re.search(r'.*setup.*', each)
                if match:
                    bbx.append(each)
                match = re.search(r'.*hold.*', each)
                if match:
                    ccx.append(each)
        self.tab['views'] = aax
        self.tab['Setup Views'] = len(bbx)
        self.tab['Hold Views'] = len(ccx)
        return self.tab

class VTDetailsParser(ReportParser):
    '''

    has no test
    '''

    def __init__(self, run_name, stage):
        '''

        has no test
        '''
        ReportParser.__init__(self, run_name, stage, 'vt_detail.rpt')

    def parse(self):
        '''

        has no test
        '''
        if not self.ffp:
            return self.tab

        for line in self.ffp:
            match = re.search(r'[0-9]+[.]+', line)
            match1 = re.search(r'Working Scenario', line)
            if match and  not match1 :
                vt_val = line.split('|')[1].strip()
                percent = line.split('|')[4].strip()
                self.tab[vt_val+'_PCT'] = percent
        return self.tab



def main(argc, argv):
    '''

    has test_021_pkg/test_5010_dump_report_excel.py : very minimal test
    '''

    result = dict()
    vt_res = dict()
    result['build_db'] = dict()
    # TODO convert all global vars to explicity passed vars or add them to a class
    global main_dir
    global stages
    global log_file 
    srcdir = os.getcwd()
    dir_list = list(srcdir.split('/'))
    main_dir = "/".join(dir_list)
    run_name = argv[1]
    my_stage = argv[2]
    csv_stages = list() 
    stages = list()
    scn = ''
    my_scn = ''
    # global en_val
    global inp_file_path
    global csv_file_path
    global txt_file_path
    # global header_all
    # header_all = []
    inp_file_path = ''
    # out_file_path = ''
    vt_keys = list()

    # my_en = 1
    print('INFO: dump_report_excel.py argv  : {:}'.format(argv))
    if my_stage == 'build_db' or my_stage == 'init':
        my_scn = argv[3]
    else:
        my_prev_stage = argv[3]
        log_file = argv[4]
        my_scn = argv[5]
        rpt_path = main_dir + '/' + run_name + '/rpts/'
        print('INFO: dump_report_excel.py reports : {:}'.format(rpt_path))

    #my_prev_stage = argv[3]
    #rpt_path = main_dir + '/' + run_name +'/'+ '/rpts/'
    #print('INFO: dump_report_excel.py reports : {:}'.format(rpt_path))

    result[my_stage] = dict()
    result[my_stage]['Stage Name'] = my_stage
    vt_res[my_stage] = dict()
    stages.append(my_stage)
    csv_file_path = main_dir + '/' +run_name + '/rpts/' + my_stage + '.csv'
    txt_file_path = main_dir + '/' + run_name + '/rpts/' + my_stage + '.txt'

    inp_file_path = main_dir + '/' + run_name + '/rpts/' + my_prev_stage + '.csv'
    print('INFO: dump_report_excel.py inp   : {:}'.format(inp_file_path))
    if os.path.exists(inp_file_path):
        # my_en = 0
        #TODO use with open on bare open with no close
        fhin = open(inp_file_path, 'r')
        for line in fhin:
            match = re.search(r'^Dominant Scenario,', line)
            if match:
                line1 = line.strip()
                scn_list = line1.split(',')
                scn = scn_list[-1]
                match1 = re.search(r'(.*)_(postcts|prects)', scn)
                my_scn = scn
                if match1:
                    if re.search(r'^(build_db|mcmm_setup|place|update_library)', my_stage):
                        my_scn = match1.group(1) + '_prects'
                    else:
                        my_scn = match1.group(1) + '_postcts'
                else:
                    my_scn = scn
            match = re.search(r'others,Total', line)
            if match:
                break

            match = re.search(r'^Metrics', line)
            if match:
                my_line = line.strip()
                csv_stages = my_line.split(',')
                csv_stages.remove('Metrics')
                stages = csv_stages
                stages.append(my_stage)
                # data_en = 1


            else:
                my_line = line.strip()
                details = my_line.split(',')
                idx = 1
                for stage in csv_stages:
                    if stage not in result.keys():
                        result[stage] = dict()
                        vt_res[stage] = dict()
                    if idx < len(details):
                        result[stage][details[0]] = details[idx]
                        match_vt = re.search(r'_PCT$', details[0])
                        if match_vt:
                            vt_keys.append(details[0])
                    idx = idx + 1

    # else:
        # my_en = 1


    if argc > 4:
	match =  re.search(r'setup', my_scn)
	if match :
        	result[my_stage]['Dominant Scenario'] = my_scn
	else :
        	result[my_stage]['Dominant Scenario'] = argv[4]


    #    for stage in ('build_db', 'mcmm_setup', 'place', 'cts', 'post_cts', 'route', 'filler', 'export_db',
    #                  'pm_fix'):
    #    vt_res[stage] = dict()
    #
    obj = FlowVariableParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    rpt_path = main_dir + run_name + '/' + '/rpts/'
    summary_exists = len(glob.glob(rpt_path+my_stage+'.timing.summary'))
    if summary_exists == 1:
    	obj = TimingParser(run_name,my_stage)
    	result[my_stage].update(obj.parse())
    else :
    	obj = TimingParserNew(run_name, my_stage)
    	result[my_stage].update(obj.parse())

    #obj = TimingParser(run_name, my_stage)
    #result[my_stage].update(obj.parse())
    #
    obj = PlaceCheckParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = PowerParser(run_name, my_stage, my_scn)
    result[my_stage].update(obj.parse())
    #
    #obj = LicenseParser(my_stage)
    #result[my_stage].update(obj.parse())
    #
    obj = ResParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = DRVParser2(run_name, my_stage, my_scn)
    result[my_stage].update(obj.parse())
    #
    obj = SetupParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    match =  re.search(r'(cts|route)', my_stage)
    if match:
        obj = HoldParser(run_name, my_stage)
        result[my_stage].update(obj.parse())
    #
    #obj = ViewsParser(run_name, my_stage)
    #result[my_stage].update(obj.parse())
    #
    obj = UtilizationParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = MVTParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = VTDetailsParser(run_name, my_stage)
    vt_res[my_stage].update(obj.parse())
    result[my_stage].update(obj.parse())
    #
    obj = ScanParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = RuntimeLogParser(run_name, my_stage)
    result[my_stage].update(obj.parse())

    #
    # CTS
    #if  re.search(r'^(cts|post_cts|route|filler|export_db|pm_fix)', my_stage):
    obj = CTSParser3(run_name, my_stage, my_scn)
    result[my_stage].update(obj.parse())
    #
    obj = CTSCells(run_name, my_stage)
    result[my_stage].update(obj.parse())
    obj = HOLDCells(run_name, my_stage)
    result[my_stage].update(obj.parse())


    #
    #DRC DR MVT
    #if re.search(r'(route|filler|export_db|pm_fix)', my_stage):
    obj = OpenShortParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = PGOpenShortParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = FillerGapParser(run_name, my_stage)
    result[my_stage].update(obj.parse())
    #
    obj = DFMviaParser(run_name, my_stage)
    result[my_stage].update(obj.parse())


    result[my_stage]['Dominant Scenario'] = my_scn

    metrics = ['Design',
               'Dominant Scenario',
               'Floorplan Area',
               'Macro Area',
               'Row Area',
               'Std Cell Area',
               'Std Cell Area Jump',
               'Floorplan Util',
               'Std Cell Count',
               'Std Cell Util',
               'Std Cell Util Jump',
               'Hold Fix PCT',
               'Place Violations',
               'Scan WireLength',
               'Filler Gaps',
               'Leakage',
               'WL',
               'WL_high_rc',
               'WL_low_rc',
               'Horz Cong',
               'Vert Cong',
               'Horz Max Overflow',
               'Vert Max Overflow',
               'Horz Tot Overflow',
               'Vert Tot Overflow',
               'DFM Via',
               'DRC',
               'Sig Shorts',
               'Sig Opens',
               'PG shorts',
               'PG Opens',
               'Hold R2R WNS',
               'Hold R2R TNS',
               'Hold R2R NFE',
               'Setup R2R WNS',
               'Setup R2R TNS',
               'Setup R2R NFE',
               'Setup R2ICG WNS',
               'Setup R2ICG TNS',
               'Setup R2ICG NFE',
               'ULVT',
               'LVT',
               'SVT',
               'Un-Classified VT',
               'Max Trans WNS',
               'Max Trans TNS',
               'Max Trans NFE',
               'Max Cap NFE',
               'Max Fanout NFE',
               'Global Skew',
               'Avg Skew',
               'Max Latency',
               'Avg Latency',
               'Slew Mean',
               'Slew Max',
               'Clock Cells',
               'Clock Buf+Inv Cells',
               'Clock Buf+Inv Area',
               'Clock Buffers',
               'Clock Inverters',
               'Clock Logic',
               'Clock ICG',
               'Setup Views',
               'Hold Views',
               'Errors',
               'Warnings',
               'AP Version',
               'Num of Threads',
               'Licenses',
               'Runtime',
               'CPUtime',
               'Peak Memory']
    metrics_txt = ['Floorplan Area',
                   'Macro Area',
                   'Row Area',
                   'Std Cell Area',
                   'Std Cell Area Jump',
                   'Floorplan Util',
                   'Std Cell Count',
                   'Std Cell Util',
                   'Std Cell Util Jump',
                   'Hold Fix PCT',
                   'Place Violations',
                   'Scan WireLength',
                   'Filler Gaps',
                   'Leakage',
                   'WL',
                   'WL_high_rc',
                   'WL_low_rc',
                   'Horz Cong',
                   'Vert Cong',
                   'Horz Max Overflow',
                   'Vert Max Overflow',
                   'Horz Tot Overflow',
                   'Vert Tot Overflow',
                   'DFM Via',
                   'DRC',
                   'Sig Shorts',
                   'Sig Opens',
                   'PG shorts',
                   'PG Opens',
                   'Hold R2R WNS',
                   'Hold R2R TNS',
                   'Hold R2R NFE',
                   'Setup R2R WNS',
                   'Setup R2R TNS',
                   'Setup R2R NFE',
                   'Setup R2ICG WNS',
                   'Setup R2ICG TNS',
                   'Setup R2ICG NFE',
                   'ULVT',
                   'LVT',
                   'SVT',
                   'Un-Classified VT',
                   'Max Trans WNS',
                   'Max Trans TNS',
                   'Max Trans NFE',
                   'Max Cap NFE',
                   'Max Fanout NFE',
                   'Global Skew',
                   'Avg Skew',
                   'Max Latency',
                   'Avg Latency',
                   'Slew Mean',
                   'Slew Max',
                   'Clock Cells',
                   'Clock Buf+Inv Cells',
                   'Clock Buf+Inv Area',
                   'Clock Buffers',
                   'Clock Inverters',
                   'Clock Logic',
                   'Clock ICG',
                   'Setup Views',
                   'Hold Views',
                   'Errors',
                   'Warnings',
                   'AP Version',
                   'Num of Threads',
                   'Licenses',
                   'Runtime',
                   'CPUtime',
                   'Peak Memory']


    if 'Design' in result[my_stage]:
        design = result[my_stage]['Design']
    else:
        design = "NA"

    if vt_keys or vt_res[my_stage]:
        if vt_res[my_stage]:
            vt_keys = sorted(vt_res[my_stage].keys())
        if 'others_PCT' in vt_res[my_stage].keys():
            vt_keys.remove('others_PCT')
            vt_keys.remove('Total_PCT')
            vt_keys.append('others_PCT')
            vt_keys.append('Total_PCT')
    if vt_keys:
        metrics.extend(vt_keys)
        metrics_txt.extend(vt_keys)

    data_all = list()
    data = list()
    txt_str = 'Design: ' + str(design) + '\n'
    txt_str = txt_str+'Dominant Scenario: ' + str(my_scn)+'\n'


    if my_stage != 'build_db':
        if 'Std Cell Util' in result['build_db'].keys() and 'Std Cell Util' in result[my_stage].keys():
            result[my_stage]['Std Cell Util Jump'] = \
                float(result[my_stage]['Std Cell Util']) - float(result['build_db']['Std Cell Util'])

            result[my_stage]['Std Cell Util Jump'] = \
                round(float(result[my_stage]['Std Cell Util Jump']),2)
            result[my_stage]['Std Cell Util Jump'] = \
                str(result[my_stage]['Std Cell Util Jump']) + '%'


    if my_stage != 'build_db':
        if 'Std Cell Area' in result['build_db'].keys() and 'Std Cell Area' in result[my_stage].keys():
            prev_std_area = float(result['build_db']['Std Cell Area'])
            current_std_area = float(result[my_stage]['Std Cell Area'])
            result[my_stage]['Std Cell Area Jump'] = \
                (current_std_area - prev_std_area)/prev_std_area * 100
            result[my_stage]['Std Cell Area Jump'] = \
                str(round(result[my_stage]['Std Cell Area Jump'], 2)) + '%'

    if re.search(r'(build_db|mcmm_setup|place|cts|update_cons|update_library|post_cts)', my_stage):
        for key in['WL', 'WL_high_rc', 'WL_low_rc', 'DFM Via',
                   'DRC', 'Sig Shorts', 'Sig Opens', 'PG Opens',
                   'PG shorts']:
            result[my_stage][key] = 0

    header = len(stages)+2
    i = 0
    while i < header:
        if i == 0:
            txt_str = txt_str +'+'+'{:20s}'.format(' --------------------- ')
        else:
            txt_str = txt_str +'+'+'{:10s}'.format(' ------------- ')
        i = i+1


    txt_str = txt_str+'+\n'
    data.append('Metrics')
    txt_str = txt_str+'{:20s}'.format('|Metrics')+'\t|'
    for stage in stages:
        data.append(stage)
        txt_str = txt_str +'{:10s}'.format(stage)+'\t|'
    txt_str = txt_str+'{:10s}'.format('Total')+'\t|\n'
    data_all.append(data)
    header = len(stages)+2
    i = 0
    while i < header:
        if i == 0:
            txt_str = txt_str +'+'+'{:20s}'.format(' --------------------- ')
        else:
            txt_str = txt_str +'+'+'{:10s}'.format(' ------------- ')
        i = i+1
    txt_str = txt_str+'+\n'

    reported_rt = 0
    for key in metrics:
        data = list()
        data.append(key)
        for stage in stages:
            if key in result[stage].keys():
                data.append(result[stage][key])
            else:
                data.append('-')
            if key == 'Runtime':
                match = re.search(r'([0-9]+):([0-9]+):([0-9]+)', result[stage]['Runtime'])
                if match:
                    reported_rt += int(match.group(3)) + 60 * int(match.group(2)) + 3600 * int(match.group(1))
        if key == 'Runtime':
            reported_mm, reported_ss = divmod(reported_rt, 60)
            reported_hh, reported_mm = divmod(reported_mm, 60)
            tot_runtime = '{:d}:{:02d}:{:02d}'.format(reported_hh, reported_mm, reported_ss)
            data.append(tot_runtime)
        data_all.append(data)



    for key in metrics_txt:
        txt_str = txt_str +'|'+ '{:20s}'.format(key)
        for stage in stages:
            if key in result[stage].keys():
                txt_str = txt_str + '\t|'+'{:10s}'.format(str(result[stage][key]))
                # if key == 'Runtime':
                #     match = re.search(r'([0-9]+):([0-9]+):([0-9]+)', result[stage]['Runtime'])
                #     if match:
                #         reported_rt += int(match.group(3)) + \
                #                        60 * int(match.group(2)) + \
                #                        3600 * int(match.group(1))
            else:
                txt_str = txt_str + '\t|'+'{:10s}'.format('-')
        if key == 'Runtime':
            reported_mm, reported_ss = divmod(reported_rt, 60)
            reported_hh, reported_mm = divmod(reported_mm, 60)
            tot_runtime = '{:d}:{:02d}:{:02d}'.format(reported_hh, reported_mm, reported_ss)
            txt_str = txt_str +'\t|'+'{:10s}'.format(tot_runtime)+'\t|'
        else:
            txt_str = txt_str + '\t|'+'{:10s}'.format(' ') +'\t|'


        txt_str = txt_str + '\n'


    header = len(stages)+2
    idx = 0
    while idx < header:
        if idx == 0:
            txt_str = txt_str + '+' + '{:20s}'.format(' --------------------- ')
        else:
            txt_str = txt_str + '+' + '{:10s}'.format(' ------------- ')
        idx = idx + 1
    txt_str = txt_str + '+\n'

    print('INFO: dump_report_excel.py writing csv to file : {:}'.format(csv_file_path))
    with open(csv_file_path, 'w') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(data_all)
        csvfile.close()

    print('INFO: dump_report_excel.py writing txt to file : {:}'.format(txt_file_path))
    text_file = open(txt_file_path, 'w')
    text_file.write(txt_str)
    text_file.close()

if __name__ == "__main__":
    try:
        main(len(sys.argv), sys.argv)
    except KeyboardInterrupt:
        print('')
