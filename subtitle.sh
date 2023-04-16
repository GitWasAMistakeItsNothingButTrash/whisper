#!/bin/bash

# Install requisites
sudo apt update
sudo apt install git ffmpeg python3-pip
pip install git+https://github.com/openai/whisper.git
pip install python-docx

# Define variables
read -p "Please enter the absolute path to the directory (include a slash at the end): " path2dir
read -p "Please specify the name of the input file (without .mp4): " inputfile
read -p "What language is the input file in? (Two letter abbreviation): " language
read -p "Please specify a name for the output files (without file-extensions): " outputfile
read -p "How many CPU threads can Whisper use? (Do not exceed total threads):" threadnumber

# Speech-to-text transcription
~/.local/bin/whisper --model large-v2 --output_dir "$path2dir" --output_format vtt --task transcribe --language $language --threads $threadnumber "$path2dir$inputfile.mp4"

# Split timestamps and transcription
python3 $( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/split.py "$path2dir" "$inputfile"

# Translate transcription

# Merge timestamps and translation
python3 $( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/merge.py "$path2dir" "$outputfile"

# Clean up temporary files
rm -f "$path2dir$timestamps.docx"
rm -f "$path2dir$transcription.docx"
rm -f "$path2dir$translation.docx"

# Burn subtitles into video
ffmpeg -i "$path2dir$inputfile.mp4" -vf subtitles="$path2dir$outputfile.vtt" "$path2dir$outputfile.mp4"
