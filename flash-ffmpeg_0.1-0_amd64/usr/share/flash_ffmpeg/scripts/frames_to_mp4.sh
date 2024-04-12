#!/bin/bash
path_to_bolt_icon=/usr/share/icons/flash_ffmpeg/bolt.png

# Function to extract resolution from the first frame of a video
get_resolution() {
    local folder="$1"
    local resolution

    # Get the first image in the folder
    first_image=$(find "$folder" -maxdepth 1 -type f -print -quit)

    # Extract resolution using ffprobe
    resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$first_image")

    echo "$resolution"
}

# Function to convert frames to MP4 for a given folder
convert_frames_to_mp4() {
    local folder="$1"
    local max_height="$2"
    local input_format="$3"

    # Get the folder name where frames are stored
    frames_folder=$(basename "$folder")
    output_dir=$(dirname "$folder")

    # Create the output filename based on the folder name
    output_filename="${frames_folder}.mp4"

    # Determine width and height based on the resolution of the first image
    resolution=$(get_resolution "$folder")
    IFS="x" read -r width height <<< "$resolution"

    # Set scale filter based on orientation
    scale_filter="scale=$width:$height"

    # Limit height to 1080 if specified and the resolution exceeds 1080p
    if [ "$max_height" = true ] && [ "$height" -gt 1080 ]; then
        width=$((width * 1080 / height))
        height=1080
        scale_filter="scale=$width:$height"
    fi

    # Convert frames to MP4 using ffmpeg
    ffmpeg -framerate "$framerate" -start_number 1 -i "$folder/$input_format" -vf "$scale_filter" -c:v libx264 -crf 23 -pix_fmt yuv420p "$output_dir/$output_filename"

    # Check if the conversion was successful
    if [ $? -eq 0 ]; then
        notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Conversion to MP4 completed: $output_dir/$output_filename"
    else
        notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Failed to convert frames to MP4 for $folder."
    fi
}

# Prompt for framerate, naming convention, and limit height using yad in a single window
user_input=$(yad --title="Specify Conversion Options" --width=300 --height=200 \
    --form --separator="," \
    --field="Framerate:" \
    --field="Naming Convention (e.g., %04d.png):" \
    --field="Limit height to 1080?:CHK" "24" "%04d.png" " ")
    
# Check if user clicked "Cancel" or closed the YAD window
if [ -z "$user_input" ]; then
    notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "Cancelled the operation."
    exit 0
fi

# Extract values from user input
IFS="," read -r framerate input_format max_height <<< "$user_input"

# Use default framerate (24) if no input provided or input is not a number
if ! [[ "$framerate" =~ ^[0-9]+$ ]]; then
    framerate=24
fi

# Convert boolean value for max_height from yad (TRUE/FALSE) to true or false
if [ "$max_height" = TRUE ]; then
    max_height=true
else
    max_height=false
fi

# Iterate over each folder provided as input argument
for folder in "$@"
do
    # Check if the argument is a directory
    if [ -d "$folder" ]; then
        # Call function to convert frames to MP4 for each folder
        convert_frames_to_mp4 "$folder" "$max_height" "$input_format"
    else
        notify-send -i $path_to_bolt_icon 'Flash FFMPEG' "$folder is not a directory."
    fi
done

