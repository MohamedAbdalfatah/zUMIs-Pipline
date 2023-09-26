#!/usr/bin/env python

"""
@authors: Juan L. Trincado
@email: juanluis.trincado@upf.edu
copy_lims_files.py: this script takes an input file of the info in the lims and copies all the files in the output_dir

usage:  python copy_lims_files.py lims_info.txt  output_dir
"""



import os, sys, logging


# create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# create console handler and set level to info/scratch/groups/singlecell/projects/SERPENTINE/SERPENTINE_01/scripts/copy_lims_files.py
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)


def main(ids_path, output_path):
	try:	

		logger.info("Starting execution")

		path="/scratch/project/production/fastq"
		
		#1. Load the file with the info of lims files
		with open(ids_path, 'r') as f:
			for line in f:
				tokens = line.rstrip().split("\t")
				sample_name = tokens[3]
				logger.info("Processing "+sample_name+"...")
				flowcell = tokens[9]
				lane = tokens[10]
				id = tokens[11]
				status = tokens[13]
				#print(status)
				#print(flowcell)
				#print(lane)
				if(status=="pass" or status=="waiting"):
				
					#Get the link
					whole_path_rep1 = path + "/" + flowcell + "/" + lane + "/fastq/" + flowcell + "_" + lane + "_" + id + "_1.fastq.gz"
					whole_path_rep2 = path + "/" + flowcell + "/" + lane + "/fastq/" + flowcell + "_" + lane + "_" + id + "_2.fastq.gz"
					logger.info(whole_path_rep1)
					logger.info(whole_path_rep2)
					logger.info("Reading symbolic links")
					link1 = os.readlink(whole_path_rep1)
					link2 = os.readlink(whole_path_rep2)
					
					#Process the link information
					logger.info("Process the link information")
					real_path1 = "_".join(link1.split("/")[-1].split("_")[3:])
					real_path2 = "_".join(link2.split("/")[-1].split("_")[3:])
					
					if not os.path.exists(output_path):
						os.makedirs(output_path)
					
					#Copy the file into the output directory
					if not os.path.islink(output_path+"/"+sample_name+"_"+real_path1):
						logger.info("Creating symlink "+output_path+"/"+sample_name+"_"+real_path1+"...")
						os.symlink(whole_path_rep1, output_path+"/"+sample_name+"_"+real_path1)
					
					if not os.path.islink(output_path+"/"+sample_name+"_"+real_path2):
						logger.info("Creating symlink "+output_path+"/"+sample_name+"_"+real_path2+"...")
						os.symlink(whole_path_rep2, output_path+"/"+sample_name+"_"+real_path2)


		logger.info("Done. Exiting program.")

		exit(0)

	except Exception as error:
		logger.error('ERROR: ' + repr(error))
		logger.error("Aborting execution")
		sys.exit(1)


if __name__ == '__main__':
	main(sys.argv[1],sys.argv[2])
