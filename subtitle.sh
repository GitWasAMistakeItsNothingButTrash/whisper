#!/bin/bash

# Install requisites
sudo apt update
sudo apt install git ffmpeg python3-pip gawk
pip install git+https://github.com/openai/whisper.git

# Define variables
read -p "Please enter the absolute path to the directory (include a slash at the end): " path2dir
read -p "Please specify the name of the input file (without .mp4): " inputfile
read -p "What language is the input file in? (Two letter abbreviation): " language
read -p "Please specify a name for the output files (without file-extensions): " outputfile
read -p "How many CPU threads can Whisper use? (Do not exceed total threads):" threadnumber

# Speech-to-text transcription
~/.local/bin/whisper --model large-v2 --output_dir "$path2dir" --output_format vtt --task transcribe --language $language --threads $threadnumber "$path2dir$inputfile.mp4"

# Remove header
gawk -i inplace 'NR > 2' "$path2dir$inputfile.vtt"

# Split timestamps and transcription
awk 'NR % 3 == 1' "$path2dir$inputfile.vtt" > "$path2dir"timestamps.tmp
awk 'NR % 3 == 2' "$path2dir$inputfile.vtt" > "$path2dir"transcription.tmp

# Translate "$path2dir"transcription.tmp into "$path2dir"translation.tmp

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
ffmpeg -i "$path2dir$inputfile.mp4" -vf subtitles="$path2dir$outputfile.vtt" "$path2dir$outputfile.mp4"
