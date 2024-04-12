#!/bin/bash

path_to_bolt_icon=/usr/share/icons/flash_ffmpeg/bolt.png

# Process each selected file
for selected_file in "$@"
do
	# Check if the file exists
	if [ -f "$selected_file" ]; then
		# Directory to store converted GIF files
		input_path="$selected_file"
		input_dir=$(dirname "$input_path")
		input_filename=$(basename "$input_path")
		input_filename_no_ext="${input_filename%.*}"

		# output_dir="$HOME/Desktop/quick_ffmpeg/output/${input_filename_no_ext}_frames"  # Set output relative to script's location
		output_dir="${input_dir}/${input_filename_no_ext}_frames"
		mkdir -p "$output_dir"  # Create the directory if it doesn't exist
		
		# Run FFmpeg to extract frames
		ffmpeg -i "$input_path" "$output_dir/%04d.png" # if you have more than 9999 frames, you may want to increase the # significant figures
		
		# Check if conversion was successful (exit code 0)
		if [ $? -eq 0 ]; then
			# Get the number of frames in the input video
			frame_count=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "$input_path")
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Frame extraction completed successfully.\nVideo: $input_filename\nNum frames extracted: $frame_count" 
		else
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Frame extraction failed\nVideo: $input_filename"
		fi
	else
		notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "The selected file '$selected_file' does not exist."
    	fi
done

