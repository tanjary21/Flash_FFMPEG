#!/bin/bash

path_to_bolt_icon=/usr/share/icons/flash_ffmpeg/bolt.png

# Prompt the user for the reduction factors
user_input=$(yad --form --title="Specify Reduction Factors" --separator="," \
    --field="Reduction factor for resolution (e.g., 2 for half resolution):" \
    --field="Reduction factor for frame rate (e.g., 2 for half frame rate):" "2" "2")

# Check if user clicked "Cancel" or closed the YAD window
if [ -z "$user_input" ]; then
    notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Cancelled the operation."
    exit 0
fi

# Extract reduction factors from user input
IFS=',' read -r reduction_factor_res reduction_factor_fps <<< "$user_input"

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

		# output_dir="$HOME/Desktop/quick_ffmpeg/output"  # Set output relative to script's location
		output_filename_no_ext=$input_filename_no_ext
		output_filename="${output_filename_no_ext}_downsampled.mp4"
		output_dir="$input_dir"
		output_path="${output_dir}/${output_filename}"
		mkdir -p "$output_dir"  # Create the directory if it doesn't exist

		# Get original resolution and frame rate
		original_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$input_path")
		original_height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$input_path")
		original_fps=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=s=x:p=0 "$input_path" | cut -d '/' -f 1)

		# Calculate new resolution and frame rate
		new_width=$((original_width / reduction_factor_res))
		new_height=$((original_height / reduction_factor_res))

		# Ensure even dimensions
		if [ $((new_width % 2)) -ne 0 ]; then
		    new_width=$((new_width + 1))
		fi

		if [ $((new_height % 2)) -ne 0 ]; then
		    new_height=$((new_height + 1))
		fi
		
		new_fps=$(expr $original_fps / $reduction_factor_fps)
		echo "New Height: ${new_height}"
		echo "New Width: ${new_width}"
		
		# Calculate the desired frame rate based on the reduction factor for frame rate
		original_fps=$(ffprobe -v error -select_streams v -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$input_path")
		desired_fps=$(echo "scale=2; $original_fps / $reduction_factor_fps" | bc)
		
		# Run the conversion command with resolution and frame rate reduction, output to specified directory
		ffmpeg -i "$input_path" -vf "scale=$new_width:$new_height" -r $new_fps "$output_path"
		
		# Check if conversion was successful (exit code 0)
		if [ $? -eq 0 ]; then
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "MP4 downsampling for '$input_filename' completed successfully.\nWritten to '$output_path'\nOriginal FPS: $original_fps\nNew FPS: $new_fps" 
		else
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "MP4 downsampling for '$input_filename' failed."
		fi
	else
		notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "The selected file '$selected_file' does not exist."
    	fi
done

