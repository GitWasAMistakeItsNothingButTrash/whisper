#!/bin/bash

# Install requisites
sudo apt update
sudo apt install git ffmpeg python3-pip
pip install git+https://github.com/openai/whisper.git
pip install googletrans

# Define variables
read -p "Please enter the absolute path to the directory: " path2dir
read -p "Please specify the name of the input file (without .mp4): " inputfile
read -p "What language is the input file in? " transcriptionlanguage
read -p "Please specify a name for the output files (without file-extensions): " outputfile
read -p "How many CPU threads can Whisper use? " threadnumber

# Speech-to-text transcription
~/.local/bin/whisper --model large-v2 --output_dir $path2dir --output_format vtt --task transcribe --language $transcriptionlanguage --threads $threadnumber $path2dir/$inputfile.mp4

# Translate subtitles
python3 generate_english_subtitles.py $path2dir $inputfile $outputfile $transcriptionlanguage
rm -f $path2dir/$transcription.tmp
rm -f $path2dir/$translation.tmp

# Burn subtitles into video
ffmpeg -i $path2dir/$inputfile.mp4 -vf subtitles=$path2dir/$outputfile.vtt $path2dir/$outputfile.mp4
