PdSettings iOS app (part of pd-for-ios, example apps for libpd in iOS)
Nov 21, 2011

This sample app demonstrates the various audio settings and how to change
them at runtime.  There are two classes in use. PdAudioUnit, a class built
around an AudioUnit, is the core of the audio processing. It asks PdBase
to process the audio. PdAudioController is a high level (convenience, if
you will) class, which tries to govern PdAudioUnit and the app's Audio
Session at the same time, deciding whether the settings are OK, need adjustment,
or if there is an unrecoverable error.

------ Notes on using PdAudioController in your project -------------------

In order to use PdAudioController, you need to add the AVAudioSession
framework to your project's "Link Binary With Libraries" section under
"Build Phases".  You can also then interact with the shared instance of
the AVAudioSession (there is only one per app) to get or set specific properties.

------ Notes on configuring PdAudioController -----------------------------

Many of the settings won't be in effect until you
reconfigure the Audio Session / Audio Unit, tap on the 'Reload Settings'
button in order to update the audio components, while others are settable
on the fly (an important one is the ticksPerBuffer size).  As such, there
are multiple configure methods that each return a PdAudioStatus code, each
documented with it's purpose at a high level in PdAudioController.h.

------ Notes on background audio: -----------------------------------------

In order for the audio callbacks to continue producing audio in the
background, you need to add an array entry to your app's info.plist file
called "UIBackgroundModes" and set one of it's values to "audio" (Xcode 4
automatically show's the human readable name for this, "Required background
modes" for the key and "App plays audio" for the value within the created 
array).  The PdSettings example app will always give provide mixing enabled,
but this is setable in PdAudioController's configure method.

------ License ------------------------------------------------------------

This software is copyrighted by Miller Puckette, Reality Jockey,
Peter Brinkmann, Richard Eakin and others.  
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
