from sys import argv
from docx import Document


inputfile = str(argv[1])+str(argv[2])+".vtt"
timestampfile = str(argv[1])+"timestamps.docx"
transcriptionfile = str(argv[1])+"transcription.docx"


# Open inputfile and create transcriptionfile
inputf = open(inputfile,"r")
timestamps = Document()
transcription = Document()


# Sort the lines from the inputfile into a list of timestamps and file with speech-to-text transcriptions
linecount = 1
for line in inputf:
	if linecount%3==0:
		timestamps.add_para(line)
	elif (linecount-1)%3==0:
		if linecount != 1: # Skip the first line "WEBVTT"
			transcription.add_para(line)
	linecount += 1


# Close inputfile and save transcriptionfile
inputf.close()
timestamps.save(timestampfile)
transcription.save(transcriptionfile)	
