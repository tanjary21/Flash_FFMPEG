#!/bin/bash
path_to_bolt_icon=/usr/share/icons/flash_ffmpeg/bolt.png

# Prompt the user for the reduction factors
user_input=$(yad --form --title="Specify Reduction Factors" --separator="," \
    --field="Reduction factor for resolution (e.g., 2 for half resolution):" \
    --field="Reduction factor for frame rate (e.g., 2 for half frame rate):" "2" "2")

# Check if the user provided reduction factors or canceled
if [ -z "$user_input" ]; then
	notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Cancelled the operation."
	exit 0  # Exit if the user canceled
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
		output_filename="${output_filename_no_ext}.gif"
		output_dir="$input_dir"
		output_path="${output_dir}/${output_filename}"
		mkdir -p "$output_dir"  # Create the directory if it doesn't exist

		# Check if a file was passed as an argument
		# Extract the filename from the absolute path
		#    filename=$(basename "$1")
		#    filename_no_ext="${filename%.*}"  # Extract filename without extension
		
		# Calculate the desired frame rate based on the reduction factor for frame rate
		original_fps=$(ffprobe -v error -select_streams v -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$input_path")
		desired_fps=$(echo "scale=2; $original_fps / $reduction_factor_fps" | bc)
		
		# Run the conversion command with resolution and frame rate reduction, output to specified directory
		ffmpeg -i "$input_path" -vf "fps=$desired_fps,scale='trunc(iw/$reduction_factor_res)':'trunc(ih/$reduction_factor_res)'" -c:v gif "$output_path"
		
		# Check if conversion was successful (exit code 0)
		if [ $? -eq 0 ]; then
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "MP4 to GIF conversion for '$input_filename' completed successfully." 
		else
			notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "MP4 to GIF conversion for '$input_filename' failed."
		fi
	else
		notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "The selected file '$selected_file' does not exist."
    	fi
done

