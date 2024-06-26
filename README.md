# Flash FFMPEG
## Quick-Access FFMPEG operations directly in the Context Menu on Ubuntu's Desktop GUI  

A convenient, user-friendly command set to run ffmpeg commands from the right-click menu.

Tested on:
* Ubuntu 20.04.1

---
### Sections:
* Backstory
* Installation
* Usage Examples
* Custom Functionality
* Uninstallation
* Future

---
## Backstory

The project started out during my MSc. studies. I found myself having to frequently convert my data/results into visualizations in nice video formats, or ```.gif```s to save on memory. And using ```ffmpeg``` through the terminal just wasn't becoming a reflex fast enough. Frequent errors, incompatible resolution specs, frame rates etc used to slow me down for stuff that really wasn't supposed to take more than 2 seconds. And so, like any decent engineer, I automated my work flows to save on a resource that's very precious in grad school; time.

At the time, these were mostly simple BASH scripts put into my ```.bashrc```. Since then, I've figured out how to put them into Ubuntu's Desktop UI's context menu. I'm now making this available to all as a ```.deb``` package that Ubuntu users can install.

This also serves me as a way to learn debian packaging.

---
## Installation

### Step 1
* Download the latest release for your system, e.g: `flash-ffmpeg_0.1-0_amd64.deb` file (see panel on the right of this repo)
* From your terminal, run the command `sudo dpkg -i flash-ffmpeg_0.1-0_amd64.deb`
* IMPORTANT: Run the command `nautilus -q` to restart the file explorer
* You are ready to use Flash FFMPEG from your right-click menu!

---
## Usage Examples

#### MP4 File to GIF:
https://github.com/tanjary21/Flash_FFMPEG/assets/79201814/c461e0a3-bba1-4411-80b3-7e3b3129ce9a

#### Extract Frames from MP4:
https://github.com/tanjary21/Flash_FFMPEG/assets/79201814/64907d46-5367-4ff9-a442-caed0f79d6ca

#### Compile Frames to MP4:
https://github.com/tanjary21/Flash_FFMPEG/assets/79201814/72793d96-673c-46d6-994d-96df05799907

#### Downsample MP4
https://github.com/tanjary21/Flash_FFMPEG/assets/79201814/e3193335-cc8e-4cac-ab12-8eb36608b69a

#### Batch Processing:
https://github.com/tanjary21/Flash_FFMPEG/assets/79201814/fe37d38b-c376-4b54-9496-1472294683bd

---
## Adding Custom Functionality

When you right-click on a file(s)/directory(s), the path(s) to those file(s)/directory(s) become the input arguments to the context menu operations. The context menu operations themselves are simply symlinks stored under ```$HOME/.local/share/nautilus/scripts``` which link to ```.sh``` scripts that contain the main functionality. 

Let's explain this better by explaining how you can create your own custom script. The script ```mp4_vertcal_splitter.sh``` slices a ```.mp4``` file into 2, vertically split ```.mp4``` files. 

Download the file ```mp4_vertcal_splitter.sh``` file. This script can take any number of video files as input. You can run it via the terminal with ```./mp4_vertical_splitter.sh video_1.mp4 video_2.mp4 video_3.mp4 ...``` ( make sure the script has execution permissions ). The script then launches a pop-up window using the ```yad``` package, asking you to specify how many vertical sections you want to split your videos into (default of 2). It then runs and writes the sliced video output into individual directories under the selected files' directory.

Use this file as a guide to write your own custom BASH scripts.

Next, place your custom script under ```/usr/share/flash_ffmpeg/scripts/custom_scripts/```. This is where we will store source code for all our scripts.

Next, create a symlink under ```$HOME/.local/share/nautilus/scripts/'Flash FFMPEG'/'Custom Scripts'/'Name your custom script'``` that links to ```/usr/share/flash_ffmpeg/scripts/custom_scripts/<your_custom_script>.sh```. Make sure the symlinks and the ```.sh``` scripts are executable.

Restart nautilus with the command ```nautilus -q``` ( or restart your PC, if it doesn't work).

Now, when you right-click on a file, you will see your custom command appear in the context-menu under ```Scripts --> Flash FFMPEG --> Custom Scripts```.

And that's it!

---
## Uninstallation
* Simply run the command `sudo dpkg -r flash-ffmpeg` from your terminal
* If the uninstall does not run flawlessly, run the following commands:
```
sudo mv /var/lib/dpkg/info/flash-ffmpeg.* /tmp/
sudo dpkg --remove --force-remove-reinstreq flash-ffmpeg
sudo dpkg --purge flash-ffmpeg
```
* Then, run `dpkg -l | grep flash-ffmpeg`. If nothing is returned, it means Flash FFMPEG was properly removed from your system

---
## Future
* Progress bars
* Icons/thumbnails
* Automatic video snipping/stitching in sync with an input audio's salient beat/bpm

<!---
icons...?

Personal stuff:

# to prepare install:
```
rm flash-ffmpeg_0.1-0_amd64.deb
dpkg-deb --build --root-owner-group flash-ffmpeg_0.1-0_amd64
sudo dpkg -i flash-ffmpeg_0.1-0_amd64.deb
```

# to uninstall
```
sudo dpkg -r flash-ffmpeg
sudo mv /var/lib/dpkg/info/flash-ffmpeg.* /tmp/
sudo dpkg --remove --force-remove-reinstreq flash-ffmpeg
sudo dpkg --purge flash-ffmpeg
dpkg -l | grep flash-ffmpeg
```
-->