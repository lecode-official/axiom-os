# Axiom

![Axiom OS Logo](https://github.com/lecode-official/axiom-os/blob/master/Documentation/Images/Banner.png "Axiom OS Logo")

## Introduction

Axiom is a personal experimental project, which explores the inner workings of operating systems as well as the intricacies of the IA-32 architecture
and possibly even the AMD64 architecture.

## Open Source

Although being a personal project I decided to host the source code publicly on GitHub, so that other people who are interested in the subject can
benefit from it. One goal of the project is to have a high quality documentation. Currently the source code documentation is very good in my opinion
and details every step that is taken and reasons behind it. I plan to add more documentation to the source code in the near future, which will
contain hardware details and references to further information.

The project is licensed under the MIT license, which pretty much means you can do what ever you want with the source code (although I do encourage
you to read the license text, because there are still some rules you have to abide to). I am very open about feedback or even pull requests, so if
you have ideas to improve on my work, then you are more than welcome to contribute. But still, this is a personal project, therefore I will decide
what is being added to it and what is not.

## Current Status

I am more or less actively developing this project in my spare time. This potentially means that from time to time I won't have any time to spare
and will not be able to work on the project. Currently the project is &ndash; *I can not stress this enough* &ndash; in a **very early** stage. I am
still working on a very simple boot loader and haven't even started writing a simple kernel.

## Acknowledgements

As I stated above, this is a personal project, because I am interested in the subject. As I am writing the code for this operating system I am also
going through a learning process. This would not be possible without the great work of others, that I do not want to let go unmentioned.

The boot sector and the boot loader code are based on the great work of Mike from [BrokenThorn Entertainment](http://www.brokenthorn.com/) who has
written a lot of great articles on [operating system development](http://www.brokenthorn.com/Resources/OSDevIndex.html). Most of the boot sector
and boot loader code was originally written by him and I greatly appreciate, that he has so kindly shared his knowledge with the world.

## Setup

If you want to try this project out, even though it momentarily does nothing more than render a success message after booting, then feel free to do so.

First make sure, that you have successfully checked out the Axiom repository. In order to compile the source code, you'll have to install the
Netwide Assembly (nasm). Also you'll need to have qemu installed for emulating the operating system. Under Debian or Ubuntu you can install both of
them like so:

```bash
sudo apt-get install nasm
sudo apt-get install qemu-system-x86
```

Then compile Axiom using its Makefile (unfortunately the Makefile currently needs elevated root rights, because it uses loopback devices, this will
hopefully change in the future):

```bash
sudo make All
```

The Makefile generates a FAT12 formatted floppy disk image in the Build folder. The custom boot sector has been installed on it. Now you can use
qemu to test the "operating system":

```bash
qemu-system-x86_64 Build/Axiom-0.0.1-Pre-Alpha-1.img
```

## Contributions

Currently I am not accepting any contributors, but if you want to help, I would greatly appreciate feedback and bug reports. To file a bug, please use GitHub's
issue system. Alternatively, you can clone the repository and send us a pull request.