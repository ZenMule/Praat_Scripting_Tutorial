# This script extract the total duration and F0 from equidistant intervals on a labeled tier.
# The number of labeled tier and the amount of equidistant intervals can be specified using the form below.
# The output will be saved to two different log files. One has the duration information and the other one F0 information.
# This script does not extract F0 values from labeled tier where the token is shorter than 50ms.

# Copyright@ Miao Zhang, University at Buffalo, 2021. 
# Please cite when you use it.

form Extract Pitch data from labelled intervals
   sentence Directory_name: /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L4
   sentence Log_file_t _f0t
   sentence Log_file_dyn _f0d
   positive Numintervals 5
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   comment F0 Settings:
   positive F0_minimum 70
   positive F0_maximum 350
   positive Octave_jump 0.10
   positive Voicing_threshold 0.65
   positive Pitch_window_threshold 0.05
endform

# Create header rows for both log files
fileappend 'directory_name$''log_file_t$'.txt File_name'tab$'Segment'tab$'t'tab$'t_m'tab$'F0'newline$'
fileappend 'directory_name$''log_file_dyn$'.txt File_name'tab$'Segment'tab$'Dur'newline$'

# Create a list of all files in the target directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"
selectObject: "Strings fileList"
num_file = Get number of strings

# Open the soundfile in Praat
for ifile from 1 to num_file
	selectObject: "Strings fileList"
	fileName$ = Get string: ifile
	Read from file: directory_name$ + "/" + fileName$

	sound_file = selected("Sound")
	sound_name$ = selected$("Sound")

	# Open the corresponding TextGrid file in Praat
	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
	textGridID = selected("TextGrid")

	# Work through all labeled intervals on the target tier specified in the form
	num_labels = Get number of intervals: labeled_tier_number
	
	for i_label from 1 to num_labels
		select 'textGridID'
		
		# Get the name of the label
		label$ = Get label of interval: labeled_tier_number, i_label

		if label$ <> ""
			# When the label name is not empty
			fileappend  'directory_name$''log_file_dyn$'.txt 'sound_name$''tab$'

			# Get the starting and end time point of the label, 
			# and calculate the total duration
			label_start = Get start time of interval: labeled_tier_number, i_label
			label_end = Get end time of interval: labeled_tier_number, i_label
			dur = label_end - label_start

			# Save the duration information to its log file
			fileappend 'directory_name$''log_file_dyn$'.txt 'label$''tab$''dur:3''tab$''newline$'
			
			# Work on getting pitch information
			select 'sound_file'

			# Get the boundaries of the target F0 obtaining interval
			pstart = label_start - pitch_window_threshold
			pend = label_end + pitch_window_threshold

			# Extract the sound part from the label
			Extract part: pstart, pend, "rectangular", 1, "yes"
			intv_ID = selected("Sound")

			# If the label is shorter than 50ms, output NA in 't', 't_m', and 'F0' columns
			if dur < 0.05
				select 'intv_ID'
				fileappend NA'tab$'NA'tab$'NA'newline$'
				Remove
			else
			# If not, then extract the pitch object first
				select 'intv_ID'
				To Pitch (ac): 0, f0_minimum, 15, "yes", 0.03, voicing_threshold, octave_jump, 0.35, 0.14, f0_maximum
				pitch_ID = selected("Pitch")

				for i_intv from 1 to numintervals
					select 'pitch_ID'
					size = dur/numintervals

					# Get the middle point of the interval and output it to log file
					intv_start = label_start + (i_intv-1) * size
					intv_end = label_start + i_intv * size
					intv_mid = intv_start + (intv_end - intv_start)/2 - label_start
					
					# Get the mean F0 of the interval
					f0_intv = Get mean: intv_start, intv_end, "Hertz"

					if f0_intv = undefined
						fileappend  'directory_name$''log_file_t$'.txt 'sound_name$''tab$''label$''tab$'NA'tab$'NA'tab$'NA'newline$'
					else
						fileappend  'directory_name$''log_file_t$'.txt 'sound_name$''tab$''label$''tab$''i_intv''tab$''intv_mid:3''tab$''f0_intv:2''newline$'
					endif
				endfor

				select 'pitch_ID'
				plus 'intv_ID'
				Remove
					
			endif
		endif
	endfor
endfor

select all
Remove
