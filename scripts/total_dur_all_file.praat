# This script open all sound files that are formatted as .wav in a directory

directory$ = "/Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data"

# Create a string variable that have all the file names in a directory�
string = Create Strings as file list: "fileList", directory$ + "/*.wav"

# Get number of files
n_string = Get number of strings

total_dur = 0

for ifile to n_string
  # Read in the sound file
  select string
  file_name$ = Get string: ifile
  Read from file: directory$ + "/" + file_name$
	
  # Get the name of the sound file and its duration
  sound_name$ = selected$("Sound")
  selectObject: "Sound 'sound_name$'"
  dur = Get duration
  total_dur = total_dur + dur
endfor

# Print the results
printline The total duration of all sound file is 'total_dur:4's.

select all
Remove
