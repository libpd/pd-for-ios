
This is a simple sample Universal iPad/iPhone app using Libpd to load and run a PD patch file.

The Libpd source and documentation is available at
https://github.com/libpd/libpd

*** Note: These docs are out of date, from an early version of libpd's obj-c layer.
Please visit the following wiki for updated info:
https://github.com/libpd/pd-for-ios/wiki/ios

The iOS sample project is currently set up to use the latest iOS SDK. 
But this feature only works automatically with iOS SDK 4.2 and later. 
The project settings use “Latest iOS” as the “Base SDK” and iOS 3.0 as its “iOS Deployment Target”. 
That means the app will run on any device with iOS 3.0 or later. 
(These can be changed in the project’s GetInfo panels.)

If you are having problems with XCode recognizing the project’s base SDK, 
you can manually select the SDK in the project’s and build target’s GetInfo panels.
Libpd is currently directly compiled into the app project. (See the libpd folder)

It may make more sense to compile Libpd as a static library. Then link that into the app project.

One thing that is very important to get Libpd to compile is setting the correct compiler DEFINES. 
These can be done in the project build "Other C Flags" setting. 
   -DPD
   -DUSEAPI_DUMMY
   -DHAVE_LIBDL
   -DHAVE_UNISTD_H
ALternatively you could just add #define's to the project precompiled header file. e.g. PdTest01_Prefix.pch

The PdAudio and PdBase classes provide the Objective C glue to Libpd. 

PdAudio initializes the iOS Audio Session.

A PdAudio object needs to created by your app. 
e.g.
   	pdAudio = [[PdAudio alloc] initWithSampleRate:44100.0 andTicksPerBuffer:64 andNumberOfInputChannels:2 andNumberOfOutputChannels:2];

PdBase provides an interface to Libpd through + class methods. 
These methods are analogous the Libpd Java API http://gitorious.org/Pdlib/pages/Libpd

PdBase shouldn't be explicitly instantiated as an object. 
Just make sure you add the class to your app project by adding the source files.
Then call the class methods like C functions.
e.g.
	[PdBase openPatch: documentsPatchFilePath];
	[PdBase computeAudio:YES];

You then you also need to play [pdAudio play];

Tested systems:
- iPad (iOS 4.2.1)
- iPhone 3GS (iOS 4.0)
- iPod touch 2nd gen (iOS 4.1) - not working
- iPod touch 1st gen (iOS 3.0) - audio problems
- iPhone EDGE (iOS 3.0) - audio problmes.

Known problems:
- Audio playback problems with iOS SDK Simulator

- Audio playback problems with iPod touch 1st gen, iPhone EDGE, iPhone 3G.
- No audio playback on iPod touch 2nd gen.

Note: this sample app uses the CoreAudio PlayAndRecord Audio Session type.
Currently Libpd doesn't work properly with older iDevices with armv6 CPUs when using
the PlayAndRecord Audio Session type. The PdTest02 app demonstrates an output-only 
application of Libpd that works on most older iDevices. i.e. PdTest02 does not use 
the microphone input.

--------------- License ------------

This software is copyrighted by Miller Puckette, Reality Jockey, Peter Brinkmann 
and others.  
The following terms (the "Standard Improved BSD License") apply to all files 
associated with the software unless explicitly disclaimed in individual files:

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above  
   copyright notice, this list of conditions and the following 
   disclaimer in the documentation and/or other materials provided
   with the distribution.
3. The name of the author may not be used to endorse or promote
   products derived from this software without specific prior 
   written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
