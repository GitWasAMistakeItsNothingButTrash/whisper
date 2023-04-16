from sys import argv
from docx import Document

outputfile = str(argv[1])+str(argv[2])+".vtt"
timestampfile = str(argv[1])+"timestamps.docx"
translationfile = str(argv[1])+"translation.docx"


# Open translationfile and create outputfile
output = open(outputfile,"w")
timestamps = Document(timestampfile)
translation = Document(translationfile)

# Write format header and empty line to output
output.write("WEBVTT")
output.write("\n")


# Merge timestamps and translation, including empty lines
for line in range(len(timestamps)):
	output.write(str(timestamps.paragraphs[line].text))
	output.write(str(translation.paragraphs[line].text))
	output.write("\n")

# Save and close output file
output.close()
