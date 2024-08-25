# SoundMantra
A collection of etudes composed for looptober 2023.

## Building
Sound Mantras are written in mnolth, which needs
to be built with x264 support and the experimental
mnolth audio nodes (mnodes). x264, ffmpeg, and
SoX are required as external dependencies.

Clone mnolth, and mnodes, and then symlink mnodes
in the mnolth folder.

```
$ git clone https://git.sr.ht/~pbatch/mnolth
$ git clone https://git.sr.ht/~pbatch/mnodes
$ cd mnolth
$ ln -s ../mnodes mnodes
```

If samurai/lua is not installed on your system.
Run the bootstrap script to make a local
version of samu/lua, which will generate binaries
in the "tools fold"

```
$ sh bootstrap.sh
```

Generate the ninja building script, enabling x264
support and mnodes.

```
$ lua generate_ninja.lua mnodes x264
```

Next, generate intermediate files and build:

```
$ samu tangle && samu
```

When build, mnolth can be installed with:

```
$ sudo sh install.sh
```

Inside this SoundMantra repo, all files can be
generated using the render script:

```
$ sh render.sh
```

An individual mantra can be rendered in the following
way:


```
$ mnolth lua mantras/day01.lua
```
