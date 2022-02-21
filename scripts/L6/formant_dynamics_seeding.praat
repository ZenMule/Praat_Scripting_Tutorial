#######################################################################
#######################################################################

# This program extracts duration, formants (F1-F4) and spectral moments
# from labeled intervals on a tier. The number of labeled tier and the
# amount of equidistant intervals can be specified using the form below.
# The output will be saved to two different log files. One contains
# durational and contextual information and the other formant related
# information.

# This program will extract formant values depending if the labeled
# interval contains a vowel sequence or monophthong. It the labeled
# interval is a vowel sequence, the script will use three sets of
# reference formant values to track formants in the three tertiles from
# the interval. Otherwise the script will only use one set of reference
# formant values.

# The user must have three files ready before running the script.
# The first file is speaker log file, which must have the speaker id as the
# 1st column, and the speaker's gender as the 2nd column.

# The second file is the vowel reference values. The 1st column should
# be different labels of vowels, which must match with the labels you used
# in the TextGrid files to annotate your recordings. The 2nd column is the
# gender information since the vowel formants change depending on the
# gender of the speaker. The rest 9 columns are formant reference values of
# F1-F3 from the initial, medial, and final tertiles of a vowel segment.

# The third file is the formant ceiling and number of tracking formant file.
# The 1st column is gender, the 2nd column formant ceiling value, and the
# 3rd column number of formants to track.

#######################################################################

# Copyright (c) 2021-2022 Miao Zhang

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

#######################################################################
#######################################################################

clearinfo

#######################################################################
#######################################################################

form Extract Formant Values
	comment Basic Settings:
	sentence Dir_rec /Users/zenmule/Programming/Praat/Formant_extraction_seeding_method/testing_recordings/En
	sentence Dir_refs /Users/zenmule/Programming/Praat/Formant_extraction_seeding_method/testing_recordings/En
	sentence Speaker_log en_sp.csv
	sentence Form_ref_file en_refs.csv
	sentence Form_ceiling ceiling_num.csv
	sentence Log_file_t time
	sentence Log_file_c context
	integer Syllable_tier_number 0
	positive Labeled_tier_number 1
	positive Number_of_chunks 30
	comment Formant analysis setttings:
  positive Analysis_points_time_step 0.005
  #positive Record_with_precision 1
  positive Window_length 0.025
  positive Preemphasis_from 50
  positive Buffer_window_length 0.04
	positive F4_ref 3800
	positive F5_ref 4600
endform

#######################################################################
#######################################################################

fileappend 'dir_rec$''log_file_t$'.txt File_name'tab$'Speaker'tab$'Gender'tab$'Seg_num'tab$'Seg'tab$'Syll'tab$'t'tab$'t_m'tab$'F1'tab$'F2'tab$'F3'tab$'F4'tab$'COG'tab$'sdev'tab$'skew'tab$'kurt'tab$''newline$'
fileappend 'dir_rec$''log_file_c$'.txt File_name'tab$'Speaker'tab$'Gender'tab$'Seg_num'tab$'Seg'tab$'Dur'tab$'Seg_prev'tab$'Seg_subs'tab$'Syll'tab$'Syll_dur'newline$'

#######################################################################


# Read in the speaker log and vowel reference file
table_sp = Read Table from comma-separated file: dir_refs$ + "/" + speaker_log$
table_ref = Read Table from comma-separated file: dir_refs$ + "/" + form_ref_file$
table_form = Read Table from comma-separated file: dir_refs$ + "/" + form_ceiling$

# Get all the folders in the directory
Create Strings as folder list: "folderList", dir_rec$
selectObject: "Strings folderList"
num_folder = Get number of strings

# Loop through the folders
for i_folder from 1 to num_folder
  selectObject: "Strings folderList"
	speaker_id$ = Get string: i_folder
	writeInfoLine: "Current speaker: < 'speaker_id$' >."

	# Get the gender of each speaker from speaker log file
	selectObject: table_sp
	sp_col$ = Get column label: 1
	gender_col$ = Get column label: 2
	gender_row = Search column: sp_col$, speaker_id$
	gender$ = Get value: gender_row, gender_col$

	appendInfoLine: "Current gender: < 'gender$' >."

	# Get the formant ceiling and number of formants to track
	selectObject: table_form
	gender_ceiling_col$ = Get column label: 1
	ceiling_col$ = Get column label: 2
	num_form_col$ = Get column label: 3
	gender_ceiling_row = Search column: gender_ceiling_col$, gender$
	formant_ceiling = Get value: gender_ceiling_row, ceiling_col$
	number_of_formants = Get value: gender_ceiling_row, num_form_col$

  # Get all the sound files in the current folder
	Create Strings as file list: "fileList", dir_rec$ + "/" + speaker_id$ + "/*.wav"
	selectObject: "Strings fileList"
	num_file = Get number of strings

	appendInfoLine: "Number of files: < 'num_file' >."

  #######################################################################

  # Loop through all the files
	for i_file from 1 to num_file
		selectObject: "Strings fileList"
		file_name$ = Get string: i_file
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + file_name$

		sound_file = selected("Sound")
		sound_name$ = selected$("Sound")

		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + sound_name$ + ".TextGrid"
		textgrid_file = selected("TextGrid")

		num_label = Get number of intervals: labeled_tier_number

    #######################################################################

    # Loop through all the labeled intervals
		for i_label from 1 to num_label
			selectObject: textgrid_file
			label$ = Get label of interval: labeled_tier_number, i_label

      #######################################################################

			if label$ <> ""
				appendInfoLine: "Extracting formants from..."
				appendInfoLine: "  Sound file < 'i_file' of 'num_file'>: < 'sound_name$' > of 'speaker_id$'."
				appendInfoLine: "    Interval ['i_label']: <'label$'>."

				# Get the duration of the labeled interval
				label_start = Get starting point: labeled_tier_number, i_label
				label_end = Get end point: labeled_tier_number, i_label
				dur = label_end - label_start

				# Get the label of the current segment
				seg$ = Get label of interval: labeled_tier_number, i_label

				# Get the label of the previous segment if it is labeled
				seg_prev$ = Get label of interval: labeled_tier_number, (i_label-1)
				if seg_prev$ = ""
					seg_prev$ = "NA"
				endif

				# Get the label of the subsequent segment if it is labeled
				seg_subs$ = Get label of interval: labeled_tier_number, (i_label+1)
				if seg_subs$ = ""
					seg_subs$ = "NA"
				endif

				# Get the lable of the syllable from the syllable tier if there is one
				if syllable_tier_number <> 0
					# Get the index of the current syllable that the labeled segment occurred in
					syll_num = Get interval at time: syllable_tier_number, (label_start + (label_end - label_start)/2)

					# Get the duration of the syllable
					syll_start = Get starting point: syllable_tier_number, syll_num
					syll_end = Get end point: syllable_tier_number, syll_num
					syll_dur = syll_end - syll_start
					syll$ = Get label of interval: syllable_tier_number, syll_num
				else
					# If there is no syllable tier, the label of syllable is NA, and the duration is 0
					syll_dur = 0
					syll$ = "NA"
				endif

				# Write the information obtained above to log file d
				fileappend 'dir_rec$''log_file_c$'.txt 'file_name$''tab$''speaker_id$''tab$''gender$''tab$''i_label''tab$''seg$''tab$''dur:3''tab$''seg_prev$''tab$''seg_subs$''tab$''syll$''tab$''syll_dur:3''newline$'

				#######################################################################

				# Get the reference value of the labeled vowel
				selectObject: table_ref

				vowel_col$ = Get column label: 1
				gender_in_ref_col$ = Get column label: 2

				table_vowel = Extract rows where: "self$[""'gender_in_ref_col$'""]=""'gender$'"" and self$[""'vowel_col$'""]=""'label$'"""
				selectObject: table_vowel
				f1_init$ = Get column label: 3
				f2_init$ = Get column label: 4
				f3_init$ = Get column label: 5

				f1_med$ = Get column label: 6
				f2_med$ = Get column label: 7
				f3_med$ = Get column label: 8

				f1_fin$ = Get column label: 9
				f2_fin$ = Get column label: 10
				f3_fin$ = Get column label: 11

				f1_ref_med = Get value: 1, "'f1_med$'"
				f2_ref_med = Get value: 1, "'f2_med$'"
				f3_ref_med = Get value: 1, "'f3_med$'"

        # If the initial or final reference values were 0, equate them to the medial values
				f1_ref_init = Get value: 1, "'f1_init$'"
				if f1_ref_init = 0
					f1_ref_init = f1_ref_med
				endif

				f2_ref_init = Get value: 1, "'f2_init$'"
				if f2_ref_init = 0
					f2_ref_init = f2_ref_med
				endif

				f3_ref_init = Get value: 1, "'f3_init$'"
				if f3_ref_init = 0
					f3_ref_init = f3_ref_med
				endif


				f1_ref_fin = Get value: 1, "'f1_fin$'"
				if f1_ref_fin = 0
					f1_ref_fin = f1_ref_med
				endif
				f2_ref_fin = Get value: 1, "'f2_fin$'"
				if f2_ref_fin = 0
					f2_ref_fin = f2_ref_med
				endif
				f3_ref_fin = Get value: 1, "'f3_fin$'"
				if f3_ref_fin = 0
					f3_ref_fin = f3_ref_med
				endif

				appendInfoLine: "      Initial tertile F1: 'f1_ref_init', F2: 'f2_ref_init', and F3: 'f3_ref_init'."
				appendInfoLine: "      Medial tertile F1: 'f1_ref_med', F2: 'f2_ref_med', and F3: 'f3_ref_med'."
				appendInfoLine: "      Final tertile F1: 'f1_ref_fin', F2: 'f2_ref_fin', and F3: 'f3_ref_fin'."

				#######################################################################

				## Formant analysis and spectral analysis
	      # Extract the formant object first
				fstart = label_start - buffer_window_length
				fend = label_end + buffer_window_length
				selectObject: sound_file
				Extract part: fstart, fend, "rectangular", 1, "no"
				extracted = selected("Sound")

	      # Get the duration of each equidistant interval of a labeled segment
				chunk_length  = dur/number_of_chunks

	      selectObject: extracted
	      To Formant (burg): analysis_points_time_step, number_of_formants, formant_ceiling, window_length, preemphasis_from
				formant_burg = selected("Formant")
				num_form = Get minimum number of formants

	      # Set how many formants the script should track
	      if num_form = 2
	        number_tracks = 2
	      elif num_form = 3
	        number_tracks = 3
	      else
					number_tracks = 4
				endif

				for i_chunk from 1 to number_of_chunks
          if i_chunk <= number_of_chunks/3
            # Track the formants
            selectObject: formant_burg
            Track: number_tracks, 'f1_ref_init', 'f2_ref_init', 'f3_ref_init', 'f4_ref', 'f5_ref', 1, 1, 1
      			formant_tracked = selected("Formant")

            # Get the start, end, and middle point of the interval
            chunk_start = buffer_window_length + (i_chunk - 1) * chunk_length
            chunk_end = buffer_window_length + i_chunk * chunk_length
            chunk_mid = buffer_window_length + chunk_length/2 + (i_chunk - 1) * chunk_length

            # Write to the log file t
            fileappend 'dir_rec$''log_file_t$'.txt 'file_name$''tab$''speaker_id$''tab$''gender$''tab$''i_label''tab$''seg$''tab$''syll$''tab$''i_chunk''tab$''chunk_mid:3''tab$'

            selectObject: formant_tracked
            # F1
            f1 = Get mean: 1, chunk_start, chunk_end, "hertz"
            if f1 = undefined
              f1 = 0
            endif

            # F2
            f2 = Get mean: 2, chunk_start, chunk_end, "hertz"
    				if f2 = undefined
    					f2 = 0
    				endif

            # F3
            f3 = Get mean: 3, chunk_start, chunk_end, "hertz"
    				if f3 = undefined
    					f3 = 0
    				endif

            # F4
            f4 = Get mean: 4, chunk_start, chunk_end, "hertz"
    				if f4 = undefined
    					f4 = 0
    				endif

            # Write the formant values to the log file t
    				fileappend 'dir_rec$''log_file_t$'.txt 'f1:0''tab$''f2:0''tab$''f3:0''tab$''f4:0''tab$'

          elif i_chunk <= 2*number_of_chunks/3
            # Track the formants
            selectObject: formant_burg
            Track: number_tracks, 'f1_ref_med', 'f2_ref_med', 'f3_ref_med', 'f4_ref', 'f5_ref', 1, 1, 1
      			formant_tracked = selected("Formant")

            # Get the start, end, and middle point of the interval
            chunk_start = buffer_window_length + (i_chunk - 1) * chunk_length
            chunk_end = buffer_window_length + i_chunk * chunk_length
            chunk_mid = buffer_window_length + chunk_length/2 + (i_chunk - 1) * chunk_length

            # Write to the log file t
            fileappend 'dir_rec$''log_file_t$'.txt 'file_name$''tab$''speaker_id$''tab$''gender$''tab$''i_label''tab$''seg$''tab$''syll$''tab$''i_chunk''tab$''chunk_mid:3''tab$'

            selectObject: formant_tracked
            # F1
            f1 = Get mean: 1, chunk_start, chunk_end, "hertz"
            if f1 = undefined
              f1 = 0
            endif

            # F2
            f2 = Get mean: 2, chunk_start, chunk_end, "hertz"
    				if f2 = undefined
    					f2 = 0
    				endif

            # F3
            f3 = Get mean: 3, chunk_start, chunk_end, "hertz"
    				if f3 = undefined
    					f3 = 0
    				endif

            # F4
            f4 = Get mean: 4, chunk_start, chunk_end, "hertz"
    				if f4 = undefined
    					f4 = 0
    				endif

            # Write the formant values to the log file t
    				fileappend 'dir_rec$''log_file_t$'.txt 'f1:0''tab$''f2:0''tab$''f3:0''tab$''f4:0''tab$'

          else
            # Track the formants
            selectObject: formant_burg
            Track: number_tracks, 'f1_ref_fin', 'f2_ref_fin', 'f3_ref_fin', 'f4_ref', 'f5_ref', 1, 1, 1
      			formant_tracked = selected("Formant")

            # Get the start, end, and middle point of the interval
            chunk_start = buffer_window_length + (i_chunk - 1) * chunk_length
            chunk_end = buffer_window_length + i_chunk * chunk_length
            chunk_mid = buffer_window_length + chunk_length/2 + (i_chunk - 1) * chunk_length

            # Write to the log file t
            fileappend 'dir_rec$''log_file_t$'.txt 'file_name$''tab$''speaker_id$''tab$''gender$''tab$''i_label''tab$''seg$''tab$''syll$''tab$''i_chunk''tab$''chunk_mid:3''tab$'

            selectObject: formant_tracked
            # F1
            f1 = Get mean: 1, chunk_start, chunk_end, "hertz"
            if f1 = undefined
              f1 = 0
            endif

            # F2
            f2 = Get mean: 2, chunk_start, chunk_end, "hertz"
    				if f2 = undefined
    					f2 = 0
    				endif

            # F3
            f3 = Get mean: 3, chunk_start, chunk_end, "hertz"
    				if f3 = undefined
    					f3 = 0
    				endif

            # F4
            f4 = Get mean: 4, chunk_start, chunk_end, "hertz"
    				if f4 = undefined
    					f4 = 0
    				endif

            # Write the formant values to the log file t
    				fileappend 'dir_rec$''log_file_t$'.txt 'f1:0''tab$''f2:0''tab$''f3:0''tab$''f4:0''tab$'
          endif

          # Remove tracked formant object
          selectObject: formant_tracked
          Remove

          #######################################################################

  			  #Getting spectral moments
  				selectObject: sound_file
  				Extract part: (i_chunk - 1) * chunk_length, i_chunk * chunk_length, "rectangular", 1, "no"
  				chunk_part = selected("Sound")
  				spect_part = To Spectrum: "yes"
  				grav = Get centre of gravity: 2
  				sdev = Get standard deviation: 2
  				skew = Get skewness: 2
  				kurt = Get kurtosis: 2

          # Write to the log file
  				fileappend 'dir_rec$''log_file_t$'.txt 'grav:0''tab$''sdev:0''tab$''skew:0''tab$''kurt:0''newline$'

  				selectObject: chunk_part
  				plusObject: spect_part
  				Remove
  			endfor
			endif
		endfor
	endfor
	selectObject: "Strings fileList"
	Remove
endfor
select all
Remove

writeInfoLine: "All done!"

#################################################################################
