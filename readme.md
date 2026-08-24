# Introduction
(TLDR: Go to the releases page and follow the simplified instructions there.)

Want to try running Quake in Linux? Curious?
It's easy! Ciscon prepared this Linux Quake bootable image, which includes Chromium web browser, Discord and mostly everything you need to use when playing Quake, without missing anything. Everything works immediately.
Readme credited to mushi.

# Instructions on how to "burn" this img file to a disk
The main use case for quake-bootable is to save the image to a USB flash drive. But you can also "burn" it to an empty disk on your system, and have dual boot (with Windows too). In this chapter, we will describe how to do it.

## Prerequisites
- Know how to use a linux terminal (console)
- Know how to use the nano text editor (follow instructions within the text editor for saving etc), or better yet, the most important shortcuts of vim (quit, save and quit, insert...).  Replace all vim references with nano if you choose this more user friendly text editor.

## Available commands in Quake-bootable (printed in terminal on boot)
- General
  - browser - starts chromium web browser
  - filebrowser
  - discord
  - shutdown-system
  - razer commands (if a razer device exists)
  - flatpak install/search apps from Flathub, or use the GNOME Software GUI (search "Software" in the app menu)
- Quake related commands
  - quake - runs the game with the selected preset
  - quakepreset - changes the qw folder
  - update-quake
  - quake-afterquake


## Step 1 - Burn the image
In Windows, to write image to a USB drive use win32 disk imager.  To write to an HDD (or USB) you may also use balenaEtcher to write the .img file to the target drive.

In Linux just use dd to write the image file:

`dd if=quake_bootable.img of=/dev/sdX bs=8M`

Replace sdX with your usb or harddrive.  For a usb drive this can be obtained by plugging in the drive and look at the tail end of the output from running dmesg.

## Step 2 - Boot into Quake-bootable
When booting, press the key to open boot options (usually F8), and choose the disk to boot from.
Alternatively, go to BIOS and do it from there.
Note: If a red warning is displayed when you select the Quake-bootable disk, about secure boot, you have to disable "Secure Boot" on the BIOS. It is required to boot from non-Windows OSes.

## Step 3 - Recommended optional steps
### change password from user (quakeuser)
The Quake-bootable user is quakeuser. The default password is quakeuser (you will need it)
You can change it with

`$ passwd`

### update packages
`$ sudo apt update`

## Step 4 - choosing X11 or Wayland (optional)
Quake-bootable auto-logs into the X11/Xfce desktop by default, same as
before. If you want the Wayland session instead, log in manually (or reboot
and pick a session at the LightDM greeter before the autologin kicks in) and
choose:
- **Quake-bootable (Xfce)** - the default X11/Xfce desktop, unchanged from before.
- **Quake-bootable (Wayland)** - a Wayland session using labwc, a lightweight
  Openbox-like compositor. ezQuake and other X11-only apps still work under
  this session via XWayland.

If you'd rather install a different window manager for the X11 session instead,
you still can: `$ sudo apt install xfce4` (or any other WM), then edit
`~/.xinitrc.real` to `exec` it instead of `startxfce4`.

## Step 5 - fix boot options (optional)
- If you want to keep Windows, you'll need to dual-boot. Let's ensure it will work.
Upon your first boot an entry should have been added to your grub boot menu if another operating system was detected.

## Step 6 - reboot
$ shutdown-system now -r
You can let it boot normally, and see to which OS it goes.
If you want to boot into other OS, press F8 on the startup process and select the disk to boot from.
Note: If you installed xfce and it doesn't look right, reboot again.
All your disks should be visible and accessible.

## Step 7 - Hardware tests
- Let's see if everything is right. visit https://devicetests.com/
- Check your monitor refresh rate: `$ lxrandr`
It should be correct. If it isn't, see "Other info" below.

## Step 8 - run Quake
$ quake
It should run smooth as butter!
You can change the selected "Quake install" to use: `$ quakepreset`

## Step 9 - use your own Quake! (optional)
This is the best thing - you can use Quake-bootable with your Quake folder: your config, your graphics, everything.
- create a folder in quakeuser homedirectory/quake, (where the existing qw.* folders are). something like
`$ mkdir /home/quakeuser/quake/qw.mushi`
- copy your Quake's qw/ folder into this qw.mushi folder
- copy your config file to the /home/quakeuser/quake/ezquake/configs folder
- copy id1.pak to /home/quakeuser/quake/id1
change the selected qw folder to use to your own (qw.mushi):
`$ quakepreset`
And that's it. You can run the game and have it exactly your way:
`$ quake`

# Other info:
- the `quake` command automatically runs the game under GameMode (via
  `gamemoderun`) when available, on top of the always-on performance CPU
  governor set at boot
- configuration of your gpu can be found in `/etc/rc.local`
- see what runs in the startup `$ vim ~/.xinitrc` 
- if your Quake isn't as smooth as it should, go to the ezQuake menu, and change the resolution there. Play around with settings, and apply them. Once its ok, cfg_save
- if your Quake still isn't smooth, your monitor detailed resolution might need to be updated. You'll use xrandr command for this. Ask for help.


## Building your own image:
```
create:
 ./create_image.sh

create in docker:
 docker run --rm --privileged -v $(pwd):/build debian bash -c "apt update;apt -qqy install git e2fsprogs dosfstools lvm2 uuid-runtime kpartx fdisk debootstrap pigz && cd /build && git config --global --add safe.directory /build && BUILDTYPE=full-oldnvidia ./create_image.sh || (echo 'something broke, reattach to container and investigate, docker rm -f containerid when complete';sleep inf)"

test:
 quake_bootable=$(ls -t quake_bootable-*.img| head -1)
 truncate -s 8G $quake_bootable `#simulate writing to 8GB media, warning: this will resize the image, zip file will remain unmodified`
 qemu-system-x86_64 -cpu Nehalem-v2 -m 4096 -smp 4 -drive format=raw,file=$quake_bootable -audio driver=pa,model=hda,id=foo -device virtio-vga-gl -display gtk,gl=on -device virtio-tablet-pci -device virtio-keyboard-pci -machine q35,vmport=off$([ -e /dev/kvm ] && echo ",accel=kvm") -device virtio-rng-pci

package (not after truncate):
 quake_bootable=$(ls -t quake_bootable-*.img| head -1)
 pigz --zip -9 $quake_bootable
```
