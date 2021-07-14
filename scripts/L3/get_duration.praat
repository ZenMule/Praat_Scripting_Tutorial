# Extraction of durations from all textgrid files in a directory. 
# Extracts the duration of every labelled interval on a particular tier. 
# Saves the duration data as a text file with the name of both the sound file and the intervals.
# Copyright Miao Zhang, UB, 6/14/2021.

##########################################################

form Extract durations from labeled tier
   sentence Directory_name: /yourdirectory
   sentence Log_file: _vot2
   positive Labeled_tier_number: 1
endform

##########################################################

# Create the header row
fileappend 'directory_name$''log_file$'.txt label'tab$'seg'tab$'dur'newline$'

##########################################################

# Create a list of all wav files in the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"

# Get the number of files in the directory
selectObject: "Strings fileList"
num_file = Get number of strings

# Loop through the directory
for ifile from 1 to num_file
	# Read sound file
	selectObject: "Strings fileList"
	fileName$ = Get string: ifile
	Read from file: directory_name$ + "/" + fileName$

	# Select the sound file and extract its name
	sound_file = selected("Sound")
	sound_name$ = selected$("Sound")

	# Read the corresponding TextGrid files using the name of the sound file
	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
	textGridID = selected("TextGrid")

	# Get labelled intervals from the specified tier
	num_labels = Get number of intervals: labeled_tier_number

	# loop through the intervals of the labeled tier
	for i from 1 to num_labels
		select 'textGridID'
		label$ = Get label of interval... labeled_tier_number i

		# skip unlabeled intervals
		if label$ <> ""
			# put the file name in the output .txt file
			fileappend 'directory_name$''log_file$'.txt 'sound_name$''tab$'

			# get duration and label
			intvl_start = Get starting point: labeled_tier_number, i
			intvl_end = Get end point: labeled_tier_number, i
			dur = intvl_end - intvl_start

			# get the name of the tier
			seg$ = Get label of interval: labeled_tier_number, i

			# put the label and duration of the interval in the output .txt file
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''dur:3''newline$'
		
		else
			# do nothing
		endif
	endfor
endfor

select all
Remove