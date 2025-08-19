#!/etc/bin/python

import sys
import re
import csv
import time
import glob

class RepParser:
	def __init__ (self, rootdir, srcdir, stage, report_name):
		try:	
			self.fn = rootdir + '/' + srcdir + '/' + stage + '.' + report_name
			self.fp = open (self.fn, 'r')
			self.tab = dict ()
			self.stage = stage
		except IOError:
			print ('Error opening ' + self.fn)
			exit ()
	
class TimingParser (RepParser):
	def __init__ (self, rootdir, stage):
		RepParser.__init__ (self, rootdir, 'rpts', stage, 'timing.summary')

	def parse (self) :
		if not self.parseAll ():
			self.parseSingle ()

	def parseAll (self):
		flag1 = False
		flag2 = False
		for line in self.fp:
			match = re.match ('.*ALL.*', line)
			if not match : continue
			match = re.search (r'.*WNS\[(.*?) :(.*?) \] .* TNS\[(.*?) :(.*?) \]', line)
			if match:
				self.tab ['wns'] = match.group (1).strip ()
				self.tab ['tns'] = match.group (3).strip ()
				self.tab ['hwns'] = match.group (2).strip ()
				self.tab ['htns'] = match.group (4).strip ()
				flag1 = True
			else:
				match1 = re.search (r'.* RRWNS\[(.*?) :(.*?) \] .* RRTNS\[(.*?) :(.*?) \] .* RRFEP\[(.*?) :', line)
				if match1:
					self.tab ['rrwns'] = match1.group (1).strip ()
					self.tab ['rrtns'] = match1.group (3).strip ()
					self.tab ['rrhwns'] = match1.group (2).strip ()
					self.tab ['rrhtns'] = match1.group (4).strip ()
					self.tab ['rrfep'] = match1.group (5).strip ()
					flag2 = True
				else:
					continue
			if flag1 and flag2: return True
		return False

	def parseSingle (self):
		self.fp.seek (0)
		for line in self.fp:
			match = re.search (r'.*WNS\[(.*?) :(.*?) \]. * TNS\[(.*?) :(.*?) \]', line)
			if match :
				self.tab ['wns'] = match.group (1).strip ()
				self.tab ['tns'] = match.group (3).strip ()
				self.tab ['hwns'] = match.group (2).strip ()
				self.tab ['htns'] = match.group (4).strip ()
			else :
				match1 = re.search (r'.* RRWNS\[(.*?) :(.*?) \] .* RRTNS\[(.*?) :(.*?) \]' , line)
				if match1:
					self.tab ['rrwns'] = match1.group (1).strip ()
					self.tab ['rrtns'] = match1.group (3).strip ()
					self.tab ['rrhwns'] = match1.group (2).strip ()
					self.tab ['rrhtns'] = match1.group (4).strip ()
				else:
					continue

	
class PowerParser (RepParser):
	def __init__ (self , rootdir, stage) :
		RepParser.__init__ (self , rootdir, 'rpts', stage , 'power.rpt')

	def parse (self) :
		leakage = 0
		for line in self.fp:
			match = re.match (r' .*Sum.*',line)
			if match :
				b = line.split()
				b = float (b[2])
				leakage = max (leakage,b)	
				self.tab ['leakage'] = leakage

class UtilizationParser (RepParser) :
	def __init__ (self , rootdir, stage) :
		RepParser.__init__ (self , rootdir , 'rpts' , stage , 'placement.rpt')

	def parse (self) :
		for line in self.fp:
			match = re.match (r'.*core utilization.*=(.*?)%',line)
			if match :
				self.tab ['util'] = match.group(1).strip ()
				break
				
				
				
class CTSParser (RepParser):
    def __init__ (self , rootdir, stage) :
        RepParser.__init__ (self , rootdir, 'rpts', stage, 'designrules.rpt')

    def parse (self) :
        sink = 0
        my_scn = ''
        sg_scan = 0
        max_lat = 0
        global_skew = 0
        slew_mean = ''
        skew_group = ''
        tot_skew = 0
        for line in self.fp:
            match = re.search(r'.*Skew Group\s*:\s*(.*)', line)
            if match:
                skew_group = match.group(1)
            match2 = re.search(r'.*(SCAN|scan).*', skew_group)
            if match2:
                sg_scan = 1
            match = re.search(r'.*Sink Number: (.*)', line)
            if match :
                my_sink = int(match.group(1))
                sink = max(sink, my_sink)
            match = re.search(r'.*Max Latency .*:(.*)', line)
            if match and my_sink == sink and sg_scan != 1:
                max_lat = max(max_lat,float(match.group(1)))
            match = re.search(r'^\s*Skew\s+: (.*)', line)
            if match and my_sink == sink and sg_scan != 1:
                global_skew = max(global_skew,float(match.group(1)))
            match = re.search(r' Total Skew\s+: (.*)', line)
            if match and my_sink == sink and sg_scan != 1:
                tot_skew = max(tot_skew,float(match.group(1)))
                #print(skew_group,my_sink,global_skew,tot_skew)
        self.tab['max-latency'] = max_lat
        self.tab['skew'] = global_skew
        self.tab['tot-skew'] = tot_skew

		
class CTSCells (RepParser):
	def __init__ (self , rootdir , stage) :
		RepParser.__init__ (self, rootdir, 'rpts', stage , 'clkcells.rpt')

	def parse (self) :
		for line in self.fp :
                    match = re.match (r'Clock Buffers.*:(.*)' , line)
                    if match :
                        self.tab ['clk-buf'] = match.group(1)
                    match = re.match (r'Clock Inverters.*:(.*)' , line)
                    if match :
                        self.tab ['clk-inv'] = match.group(1)
		
class RuntimeLogParser (RepParser):
	def __init__ (self, rootdir, stage):
                log_exists = len(glob.glob(rootdir + '/' + 'logs' + '/' + stage + '.log'))
                if log_exists == 1:
                    RepParser.__init__ (self, rootdir, 'logs', stage, 'log')
                else:
                    RepParser.__init__ (self, rootdir, 'log', stage, 'log')


	def parse (self) :
		ss = 0
		peakmem = float ()
	#cc#	drc = 0
		for line in self.fp :
			match = re.search (r'(Place_opti|Synthesize_skew_group|Post_cts_opt|Droute_opt).*Finish.*Elapsed = (.*?);', line)
			if match :
				t = match.group (2).split (':')
				ss += int (t[2]) + 60 * int (t[1]) + 3600 * int (t[0])
	#cc# self.stage =='route' :
	#cc#match1 = re.search (r':Total DRC violations \((.*?)\) :',line)
	#cc#			if match1 :
	#cc#				drc = match1.group(1)

			match = re.search (r'.*Elapsed.*; VM =(.*?)M', line)
			if match:
				mem = float (match.group(1))
				peakmem = max (peakmem, mem)

		self.runtime = ss
		mm, ss = divmod (ss, 60)
		hh, mm = divmod (mm, 60)
		self.tab ['runtime'] = '{:d}:{:02d}:{:02d}'.format (hh, mm, ss)
	#cc#self.tab ['drc'] = int (drc)
		self.tab ['peakmem'] = peakmem
			
class DRCParser (RepParser) :
	def __init__ (self, rootdir, stage) :
		RepParser.__init__ (self, rootdir, 'rpts' ,'route', 'drc.rpt')

	def parse (self) :
		shorts = 0
		drc = 0
		for line in self.fp :
                    match = re.search (r'.*short\s*:\s*(\d+)\s+',line)
                    if match :
			#b = line.split (':')
                        shorts = match.group(1)
                        #print(line)
                    match = re.search (r'.*Total violations\s*:\s*(\d+)\s+' , line)
                    if match :
			#b = match.group ().split (':')
                        drc = match.group(1)
                        #print(line)
                    match = re.search(r'(\d+)\s*:\s*short', line)
                    if match:
                        shorts = int(match.group(1))
                    match = re.search(r'^\s*(\d+)\s*:\s*Total DRC violations', line)
                    if match:
                        drc = int(match.group(1))

		self.tab ['drc'] = int (drc)
		self.tab ['shorts'] = int (shorts)


if __name__ == "__main__" :
	if len(sys.argv) < 2:
		print ("check usage")
		exit ()
	print(sys.argv)
	src_dirs = str (sys.argv[1:])

	tab = dict ()
	for src_dir in sys.argv[1:]:
		print(src_dir)
		tab [src_dir] = dict ()

		# TIMING , POWER & UTIL
		for stage in ('place', 'cts_opt', 'route'):
			obj = TimingParser (src_dir, stage)
			obj.parse()
			tab [src_dir][stage] = obj.tab
			obj = PowerParser (src_dir , stage)
			obj.parse()
			tab [src_dir][stage].update (obj.tab)
			obj = UtilizationParser (src_dir , stage)
			obj.parse()
			tab [src_dir][stage].update (obj.tab)
	
		# CTS MATRIX 
		obj = CTSParser (src_dir , 'cts')
		obj.parse()
		tab [src_dir]['cts'] = obj.tab

		# CTS MATRIX
		obj = CTSCells (src_dir , 'cts')
		obj.parse()
		tab [src_dir]['cts'].update (obj.tab)

		#DRC
		obj = DRCParser (src_dir , 'route')
		obj.parse()
		tab [src_dir]['route'].update (obj.tab)


		rt = 0
		for stage in ('place', 'cts', 'cts_opt', 'route') :
			p = RuntimeLogParser (src_dir, stage)
			p.parse()
			tab [src_dir][stage].update (p.tab)
			rt += p.runtime
		mm, ss = divmod (rt, 60)
		hh, mm = divmod (mm, 60)
		tab [src_dir]['total-runtime'] = '{:d}:{:02d}:{:02d}'.format (hh, mm, ss)
		#print (tab [src_dir]['total-runtime'])


	# PREPARE DATA FOR WRITING
	full_data = list()
	for src_dir in sys.argv[1:]:
		data = list()

		data.append (src_dir)
		for key in ('wns', 'tns', 'rrwns', 'rrtns', 'leakage', 'util', 'runtime', 'peakmem'):
			data.append (tab [src_dir]['place'][key])
		for key in ('max-latency', 'skew', 'tot-skew','clk-buf', 'clk-inv', 'runtime', 'peakmem'):
			data.append (tab [src_dir]['cts'][key])
		for key in ('wns', 'tns', 'rrwns', 'rrtns', 'hwns', 'htns', 'rrhwns', 'rrhtns', 'leakage', 'util', 'runtime', 'peakmem'):
			data.append (tab [src_dir]['cts_opt'][key])
		for key in ('wns', 'tns', 'rrwns', 'rrtns', 'hwns', 'htns', 'rrhwns', 'rrhtns', 'leakage', 'util', 'runtime', 'peakmem', 'drc', 'shorts'):
			data.append (tab [src_dir]['route'][key])
		data.append (tab [src_dir]['total-runtime'])
		full_data.append(data)

	header = []
	header += ['Run-dir']
	header += ['p-wns', 'p-tns', 'p-rrwns', 'p-rrtns', 'p-leakage', 'p-util', 'p-runtime', 'p-mem']
	header += ['c-maxlat', 'c-skew','c-totskew', 'c-clkbuf', 'c-clkinv', 'c-runtime', 'c-mem']
	header += ['co-wns', 'co-tns', 'co-rrwns', 'co-rrtns']
	header += ['co-hwns', 'co-htns', 'co-hrrns', 'co-hrrtns', 'co-leakage', 'co-util', 'co-runtime', 'co-mem']
	header += ['r-wns', 'r-tns', 'r-rrwns', 'r-rrtns']
	header += ['r-hwns', 'r-htns', 'r-hrrwns' ,'r-hrrtns', 'r-leakage', 'r-util', 'r-runtime', 'r-mem', 'drc', 'shorts']
	header += ['total-runtime']

	# total runtime

	#for ii in range (0, len (header)):
		#print ('  ' + header [ii] + ' = ' + str (data [ii]))

	with open ('summary_res.csv' ,'w') as csvfile:
		writer = csv.writer(csvfile)
		writer.writerow (header)
		writer.writerows (full_data)
		print ('Exported to summary_res.csv')
