#__author__ = "	Javier Alejandro ATADIA Florencia ALVAREZ Paulina ALVAREZ Andrei-Florin BENCSIK"
#__copyright__ = "Copyright 2017, IMT Atlantique"
#__version__ = "0.0.5"
#__status__ = "Test"
import os
import sys
import argparse

#################################################################################################

#################################################################################################
def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--file", help=".java class file")
	parser.add_argument("--mode", help="""unit test mode:
									one of the values: 
									file, 
									class, 
									method,
									statement, 
									expression""")

	parser.add_argument("-v","--verbosity", action="store_true", help="increase output verbosity")

	args = parser.parse_args()

	verbosity = ""
	if args.verbosity:
		verbosity =" -vervose"

	if args.file and args.mode:
 		file_name = args.file
		os.system("./build/main " + args.mode + " " + file_name + verbosity)
 		
 	elif args.file:
 		file_name = args.file
		os.system("./build/main " + "file" + " " + file_name + verbosity)

	else:
		os.system("python " + sys.argv[0] + " --help")
  		exit()

#################################################################################################
#  MAIN  #
#################################################################################################
if __name__ == "__main__":
	main()