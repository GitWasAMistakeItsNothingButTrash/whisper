from googletrans import Translator


# Definitions
print("Please enter the absolute path to Whisper's speech-to-text transcription: ")
inputfile = raw_input("")

print("What language is it in? ")
inputlanguage = raw_input("")

print("And what language do you want to translate it to? ")
outputlanguage = raw_input("")

print("Please enter the absolute path at which to save the raw transcription (untranslated and without timestamps): ")
transcriptionfile = raw_input("")

print("Please enter the absolute path at which to save the raw translation (without timestamps): ")
translationtionfile = raw_input("")

print ("Please enter the absolute path at which to save the final product (translated subtitles including timestamps): ")
outputfile = raw_input("")


# Open inputfile and create transcriptionfile
inputf = open(inputfile,"r")
transcription = open(transcriptionfile,"w")

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
if len(timestamps) == len(transcription):
	print("Pre-translation check passed: Number of timestamps and number of lines match")
elif len(timestamps) > len(transcription):
	print("WARNING! Pre-translation check failed: Number of timestamps exceeds number of lines")
elif len(timestamps) < len(transcription):
	print("WARNING! Pre-translation check failed: Number of lines exceeds number of timestamps")	

# Close inputfile and save transcriptionfile
inputf.close()
transcription.close()	


# Open transcriptionfile and create translationfile
transcription = open(transcriptionfile,"r")
translation = open(translationfile,"w")

# The blackbox where all the magic happens
translation.write(Translator().translate(transcription, src=inputlanguage, dest=outputlanguage))

# Close transcriptionfile and save translationfile
transcription.close()
translation.close()


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
