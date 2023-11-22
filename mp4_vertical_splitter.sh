#!/bin/bash
path_to_bolt_icon=/usr/share/icons/flash_ffmpeg/bolt.png
# Check if at least one input file is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 input1.mp4 [input2.mp4 ...]"
    exit 1
fi

# Prompt the user for the number of slices
user_input=$(yad --form --title="Specify Number of Slices" --separator=","  --field="Enter the number of slices:" "2")

# Check if the user canceled
if [ $? -ne 0 ] || [ -z "$user_input" ]; then
    notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Canceled."
    exit 1
fi

# Extract reduction factors from user input
IFS=',' read -r num_slices <<< "$user_input"


# Iterate through each input file provided
for input_file in "$@"; do
    # Get video width and height
    width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$input_file")
    height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$input_file")

    # Calculate slice width
    slice_width=$((width / num_slices))

    # Create output folder name based on input file name
    output_folder="${input_file%.*}_splits"

    # Create a folder to store the sliced frames
    mkdir -p "$output_folder"

    # Iterate through slices and extract each one
    for (( i = 0; i < num_slices; i++ )); do
        start_pixel=$((i * slice_width))
        ffmpeg -i "$input_file" -vf "crop=$slice_width:$height:$start_pixel:0" -c:v libx264 -crf 23 -preset veryfast -an "$output_folder/slice_$i.mp4"
    done
    
    # Check if the slicing process was successful and send a notification
    if [ $? -eq 0 ]; then
        notify-send -i $path_to_bolt_icon "Flash FFMPEG" "Slicing for $input_file completed successfully."
    else
        notify-send -i $path_to_bolt_icon "Flash FFMPEG" "Failed to slice $input_file."
    fi
    
done

