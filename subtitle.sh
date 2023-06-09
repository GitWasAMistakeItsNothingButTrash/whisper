#!/bin/bash

# Install requisites
echo "Installing/Updating required packages"
sudo apt update
sudo apt install git ffmpeg python3-pip gawk
pip install git+https://github.com/openai/whisper.git

# Define variables
read -r -p "Please enter the absolute path to the directory (include a slash at the end): " path2dir
read -r -p "Please specify the name of the input file (without .mp4): " inputfile
read -p "What language is the input file in? (Two letter abbreviation): " language
read -r -p "Please specify a name for the output files (without file-extensions): " outputfile
read -p "How many CPU threads can Whisper use? (Do not exceed total threads):" threadnumber

while true; do
read -p "Did you enter all of the above correctly? (Enter y/n) " yn
case $yn in 
	[yY] ) break;;
	[nN] ) clear;
		read -r -p "Please enter the absolute path to the directory (include a slash at the end): " path2dir ;
		read -r -p "Please specify the name of the input file (without .mp4): " inputfile ;
		read -p "What language is the input file in? (Two letter abbreviation): " language ;
		read -r -p "Please specify a name for the output files (without file-extensions): " outputfile ;
		read -p "How many CPU threads can Whisper use? (Do not exceed total threads):" threadnumber ;;
	* ) echo "Please enter y/n";;
esac
done

# Speech-to-text transcription
echo "Transcribing speech to text"
~/.local/bin/whisper --model large-v2 --output_dir "$path2dir" --output_format vtt --task transcribe --language $language --threads $threadnumber "$path2dir$inputfile.mp4"

# Remove header
gawk -i inplace 'NR > 2' "$path2dir$inputfile.vtt"

# Split timestamps and transcription
awk 'NR % 3 == 1' "$path2dir$inputfile.vtt" > "$path2dir"timestamps.tmp
awk 'NR % 3 == 2' "$path2dir$inputfile.vtt" > "$path2dir"transcription.tmp

# Translate "$path2dir"transcription.tmp into "$path2dir"translation.tmp
# Stop-gap measure until I figure out how to call Google Translate from the commandline
echo "Please paste the contents of transcription.tmp into https://translate.google.com"
echo "Save the translation as translation.tmp under $path2dir"
read -n 1 -s -r -p "Then press any key to continue"

# Merge timestamps and translation
paste -d \\n "$path2dir"timestamps.tmp "$path2dir"translation.tmp > "$path2dir$outputfile.vtt" 

# Clean up temporary files
rm -f "$path2dir"timestamps.tmp
rm -f "$path2dir"transcription.tmp
rm -f "$path2dir"translation.tmp

# Insert empty line every third line:
gawk -i inplace ' {print;} NR % 2 == 0 { print ""; }' "$path2dir$outputfile.vtt"

# Restore header
gawk -i inplace 'NR == 1 {$0="WEBVTT"RS$0}7' "$path2dir$outputfile.vtt"
gawk -i inplace 'NR == 2 {$0=""RS$0}7' "$path2dir$outputfile.vtt"

# Burn subtitles into video
echo "Creating subtitles"
ffmpeg -i "$path2dir$inputfile.mp4" -vf subtitles="$path2dir$outputfile.vtt" "$path2dir$outputfile.mp4"
