from sys import argv
from googletrans import Translator



def split(inputfile,transcriptionfile):
	
	# Open inputfile and create transcriptionfile
	inputf = open(inputfile,"r")
	transcription = open(transcriptionfile,"w+")
	
	# Sort the lines from the inputfile into a list of timestamps and file with speech-to-text transcriptions
	timestamps = []
	linecount = 1
	for line in inputf:
		if linecount%3==0:
			timestamps.append(str(line))
		elif (linecount-1)%3==0:
			if linecount != 0: # Skip the first line "WEBVTT"
				transcription.write(str(line))
		linecount += 1
	
	# Check that the number of timestamps matches the number of lines pre-translation
	if len(timestamps) == len(transcription.read()):
		print("Pre-translation check passed: Number of timestamps and number of lines match")
	elif len(timestamps) > len(transcription.read()):
		print("WARNING! Pre-translation check failed: Number of timestamps exceeds number of lines")
	elif len(timestamps) < len(transcription.read()):
		print("WARNING! Pre-translation check failed: Number of lines exceeds number of timestamps")	
	
	# Close inputfile and save transcriptionfile
	inputf.close()
	transcription.close()
	
	return timestamps



def translate(language,transcriptionfile,translationfile):
	
	# Open transcriptionfile and create translationfile
	transcription = open(transcriptionfile,"r")
	translation = open(translationfile,"w")
	
	# The blackbox where all the magic happens
	translation.write(Translator().translate(transcription.read(), src=language, dest=en).text)
	
	# Close transcriptionfile and save translationfile
	transcription.close()
	translation.close()
	
	return None



def merge(timestamps,translationfile,outputfile):
	
	# Open translationfile and create outputfile
	translation = open(translationfile,"r")
	output = open(outputfile,"w")
	
	# Write format header and empty line to output
	output.write("WEBVTT")
	output.write("\n")
	
	# Check that the number of timestamps matches the number of lines post-translation
	if len(timestamps) == len(translation):
		print("Post-translation check passed: Number of timestamps and number of lines match")
	elif len(timestamps) > len(translation):
		print("WARNING! Post-translation check failed: Number of timestamps exceeds number of lines")
	elif len(timestamps) < len(translation):
		print("WARNING! Post-translation check failed: Number of lines exceeds number of timestamps")
	
	# Merge timestamps and translation, including empty lines
	for line in range(len(timestamps)):
		output.write(str(timestamps[line]))
		output.write(str(translation[line]))
		output.write("\n")
	
	# Close translationfile and save outputfile
	translation.close()
	output.close()
	
	return None



inputfile = str(argv[1])+str(argv[2])+".vtt"
transcriptionfile = str(argv[1])+"transcription.tmp"
translationfile = str(argv[1])+"translation.tmp"
outputfile = str(argv[1])+str(argv[3])+".vtt"
language = str(argv[4])

timestamps = split(inputfile,transcriptionfile)
translate(language,transcriptionfile,translationfile)
merge(timestamps,translationfile,outputfile)
