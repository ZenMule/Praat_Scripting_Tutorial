# 1. Cuts up large sound files in a directory into smaller chunks using an existing tier on an associated 
#	TextGrid file.

# 2. This script runs through all sound files in a directory and put the chunked files into a new sub-
#	directoryThe Renamed file prefix is a string that the user can define as they wish.

# 3. The tier number reflects the tier containing the intervals which will be extracted. 
# 	The name of the intervals will be used for the main file name when saving the chunked files. The intervals
#	should only contain ascii characters.

# 4. If there is already a folder with the same name in the directory, the script won't run.

# 5. Copyright Miao Zhang, SUNY Buffalo, 7/8/2021.

############################################################

form Extract smaller files from large file
   sentence Directory_name: /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L2
   sentence Renamed_file_prefix: prac2_
   positive Tier_number: 1
endform

############################################################

# Clear the info window
clearinfo

# Create a file list for all the recordings in the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"

# Select the file list and get how many files there are in the directory
select Strings fileList
num_file = Get number of strings

for i_file from 1 to num_file

	# Make sure the file list is selected before reading in sound files
	select Strings fileList
	current_file$ = Get string: i_file

	# Read in the sound file
	Read from file: directory_name$ + "/" + current_file$
	sound_file = selected ("Sound")

	# Get the name of the sound file
	sound_name$ = selected$ ("Sound")

	# Create a subdirectory to save the chunked recordings later
	new_dir$ = directory_name$ + "/" + sound_name$
	runSystem: "mkdir ", new_dir$
	printline New directory "'new_dir$'" created.

	# Read the textgrid file
	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
	textgrid_file = selected("TextGrid")

	# Get the total number of intervals from the target tier
	select 'textgrid_file'
	num_intvl = Get number of intervals: tier_number
	printline 'num_intvl' intervals in total in tier 'tier_number'.

	for i from 1 to num_intvl
		# Make sure the textgrid file is selected before running the codes below
		select 'textgrid_file'

		# Get the label of the current interval
		lab$ = Get label of interval: tier_number, i

		# If the label is not empty, then
		if lab$ <> ""
			# Report the current progress
			printline Start working on interval No.'i', "'lab$'".
		
			# Get the start and end time of the current labeled interval
			start = Get start time of interval: tier_number, i
			end = Get end time of interval: tier_number, i

			# extract the current labeled interval
			select 'textgrid_file'
			textgrid_chunk = Extract part: start, end, "no"

			# extract the current labeled sound
			select 'sound_file'
			Extract part: start, end, "rectangular", 1, "no"

			# Save the sound file with the prefix specified in the form and the current name of the label
			Write to WAV file: new_dir$ + "/" + renamed_file_prefix$ + lab$ + ".wav"
		
			# Save the textgrid file in the same way
			select 'textgrid_chunk'
			Save as text file: new_dir$ + "/" + renamed_file_prefix$ + lab$ + ".TextGrid"
	
		# If the label is empty, then do nothing
		else
			#do nothing
		endif
	endfor
endfor
select all
Remove
printline Done!