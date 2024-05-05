#!/usr/bin/env fish

# Temporary directory for the installation files
set tide_tmp_dir (mktemp -d)

echo "Downloading Tide from your repository..."
curl -L https://codeload.github.com/BGoodatit/tide/tar.gz/HEAD | tar -xzC $tide_tmp_dir

echo "Installing Tide..."
cp -R $tide_tmp_dir/tide-HEAD/{completions,conf.d,functions} $__fish_config_dir

echo "Applying default configurations..."
# Set style to lean and choose the first option
tide configure style=lean

# Set prompt colors to true color
tide configure prompt_colors=true_color

# Show current time in 12-hour format
tide configure time_format=12_hour

# Set prompt height to two lines
tide configure prompt_height=two_lines

# Set prompt connection to disconnected
tide configure prompt_connection=disconnected

# Set prompt spacing to sparse
tide configure prompt_spacing=sparse

# Set icons to use few icons
tide configure icons=few_icons

# Optionally initialize the tide configuration or refresh the shell
source $__fish_config_dir/conf.d/_tide_init.fish
exec fish --init-command "set -g fish_greeting; emit _tide_init_install"

echo "Installation completed. Please restart your Fish shell."

# Cleanup
command rm -r $tide_tmp_dir
