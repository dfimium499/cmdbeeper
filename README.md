# cmdbeeper

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)

PulseAudio/PipeWire terminal beeper that notifies you when your commands are done running.

**cmdbeeper** is a tiny bash script that plays an audio file on loop until Enter is pressed or SIGINT/SIGTERM is received. Chaining it with `;` after a shell command 
sets an alarm that will notify you when a long foreground process returns:

```bash
make; cmdbeeper
```

Chaining it after `sleep` results in a makeshift timer:

```bash
sleep 15; cmdbeeper
```

## Features

**cmdbeeper** can play custom sound files (uncompressed and .oga files for most desktop distros), take a timeout parameter in seconds, and pause n seconds each 
time the audio file loops. For instance, to play `freedesktop`'s `bell.oga` tune with a 10-second timeout and a 1-second silent interval between each loop, simply 
run

```bash
cmdbeeper -s /usr/share/sounds/freedesktop/stereo/bell.oga -t 10 -i 1
```

**cmdbeeper** can also be configured via environment variables, so default parameters can be defined by exporting them from your `bashrc`. In any case, 
explicit flag arguments will always override environment settings.

For more information on flag usage and environment variable configuration, see [the man page](./man/cmdbeeper.1).

## Requirements

A `PulseAudio` or `PipeWire` audio server must be enabled. If `PipeWire` is the target backend, make sure the `pipewire-pulse` compatibility layer is present. 
The `libpulse` and `sound-theme-freedesktop` packages are also required to play audio from the terminal and to provide a default tune respectively.

## Installation

### Arch Linux/Arch-related distros

The **cmdbeeper** package is available through the [AUR](https://aur.archlinux.org). You can install it with an AUR helper such as [yay](https://github.com/Jguer/yay):

```bash
yay -S cmdbeeper
```

Once the installation is complete, you'll be able to run the `cmdbeeper` command and access the manual by running `man cmdbeeper`.

### Manual installation

**cmdbeeper** is a simple monolithic bash script, so appending `alias cmdbeeper="bash /global/path/to/cmdbeeper"` to your `bashrc` should be enough.

If you wish to install it globally instead, install it into your global `/usr/bin` directory as `cmdbeeper` with 755 permissions, although this method 
is not recommended. Try [the AUR package](#arch-linuxarch-related-distros) if you're running Arch Linux or an Arch-related distro.

## License

Copyright (C) 2026 Diego Fernández

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Author
Diego Fernández - [dfimium499+cmdbeeper@proton.me](mailto:dfimium499+cmdbeeper@proton.me)

