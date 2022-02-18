clearinfo

form Extract Formant Values
	comment Basic Settings
	sentence dir_rec /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L6
	sentence dir_ref /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L6
	sentence dir_sp_log /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L6
	sentence speaker_log sp_log.csv
	sentence form_ref_file chn_formants_ref.csv
	positive labeled_tier 1
	positive number_of_chunks 30
	comment Formant setttings

endform

# Get all the folders in the directory
Create Strings as folder list: "folderList", dir_rec$
selectObject: "Strings folderList"

num_folder = Get number of strings
for i_folder from 1 to num_folder
	speaker_id$ = Get string: 1
	writeInfoLine: "The currrent speaker ID is 'speaker_id$'."

	# Get the gender of each speaker from speaker log file
	table_sp = Read Table from comma-separated file: dir_sp_log$ + "/" + speaker_log$
	selectObject: table_sp

	sp_col$ = Get column label: 1
	gender_col$ = Get column label: 2
	gender_row = Search column: sp_col$, speaker_id$
	gender$ = Get value: gender_row, gender_col$

	appendInfoLine: "The gender of the current participant is 'gender$'."

	Create Strings as file list: "fileList", dir_rec$ + "/" + speaker_id$ + "*.wav"
	selectObject: "Strings fileList"
	num_file = Get number of strings

	for i_file from 1 to num_file
		file_name$ = Get string: i_file
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + file_name$

		sound_file = selected("Sound")
		sound_name$ = selected$("Sound")

		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + sound_name$ + ".TextGrid"
		textgrid_file = selected("TextGrid")

		num_label = Get number of intervals: labeled_tier

		for i_label from 1 to num_label
			label$ = Get label of interval: labeled_tier, i_label

			if label$ <> ""
				appendInfoLine: "Extracting formants from..."
      	appendInfoLine: "  Sound file < 'i_file' of 'num_file'>: < 'sound_name$' > of 'speaker_id$'."
      	appendInfoLine: "    Interval ['i_label']: <'label$'>."

				# Get the reference value of the labeled vowel
				table_ref = Read Table from comma-separated file: dir_ref$ + "/" + form_ref_file$
				selectObject: table_ref

				table_vowel = Extract rows where: "self$[""Gender""]=""'gender$'"" and self$[""Vowel""]=""'vowel$'"""
				selectObject: table_vowel

				f1_ref_med = Get value: 1, "F1_ref_med"
				f2_ref_med = Get value: 1, "F2_ref_med"
				f3_ref_med = Get value: 1, "F3_ref_med"

				f1_ref_init = Get value: 1, "F1_ref_init"
				if f1_ref_init = 0
					f1_ref_init = f1_ref_med
				endif
				f2_ref_init = Get value: 1, "F2_ref_init"
				if f2_ref_init = 0
					f2_ref_init = f2_ref_med
				endif
				f3_ref_init = Get value: 1, "F3_ref_init"
				if f3_ref_init = 0
					f3_ref_init = f3_ref_med
				endif


				f1_ref_fin = Get value: 1, "F1_ref_fin"
				if f1_ref_fin = 0
					f1_ref_fin = f1_ref_med
				endif
				f2_ref_fin = Get value: 1, "F2_ref_fin"
				if f1_ref_fin = 0
					f1_ref_fin = f1_ref_med
				endif
				f3_ref_fin = Get value: 1, "F3_ref_fin"
				if f1_ref_fin = 0
					f1_ref_fin = f1_ref_med
				endif

				appendInfoLine: "      Initial tertile F1: 'f1_ref_init', F2: 'f2_ref_init', and F3: 'f3_ref_init'."
				appendInfoLine: "      Medial tertile F1: 'f1_ref_med', F2: 'f2_ref_med', and F3: 'f3_ref_med'."
				appendInfoLine: "      Final tertile F1: 'f1_ref_fin', F2: 'f2_ref_fin', and F3: 'f3_ref_fin'."

			endif



		endfor


	endfor






	selectObject: "Strings fileList"
	Remove
endfor

select all
Remove






#################################################################################




table_ref = Read Table from comma-separated file: dir_ref$ + "/" + form_ref_file$
selectObject: table_ref

table_vowel = Extract rows where: "self$[""Gender""]=""'gender$'"" and self$[""Vowel""]=""'vowel$'"""
selectObject: table_vowel
List: "yes"

f1_ref_init = Get value: 1, "F1_ref_init"
f2_ref_init = Get value: 1, "F2_ref_init"
f3_ref_init = Get value: 1, "F3_ref_init"

f1_ref_med = Get value: 1, "F1_ref_med"
f2_ref_med = Get value: 1, "F2_ref_med"
f3_ref_med = Get value: 1, "F3_ref_med"

f1_ref_fin = Get value: 1, "F1_ref_fin"
f2_ref_fin = Get value: 1, "F2_ref_fin"
f3_ref_fin = Get value: 1, "F3_ref_fin"

appendInfoLine: "Initial tertile F1: 'f1_ref_init', F2: 'f2_ref_init', and F3: 'f3_ref_init'."
appendInfoLine: "Medial tertile F1: 'f1_ref_med', F2: 'f2_ref_med', and F3: 'f3_ref_med'."
appendInfoLine: "Final tertile F1: 'f1_ref_fin', F2: 'f2_ref_fin', and F3: 'f3_ref_fin'."
