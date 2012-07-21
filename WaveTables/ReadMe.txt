WaveTables iOS app
author: Rich Eakin (reakinator@gmail.com)

Sample app for libpd for iphone/ipad that demonstrates how to interact
with arrays in pd.  We lookup the array based on its name in pd (in the
case of this example, the name is prepended with the $0 arg), and then
create and maintain a shadowed array from which we can copy back and forth
to.  For drawing and manipulating by touch, we mainly write to the local
shadowed array, and then update pd's array via PdBase.  To manage the local
array and stay synchronized with pd's, we use the PdArray class.

The example uses two of the example patches included in the pd tutorials:
- B01.wavetables.pd (or very close to it): wavetable lookup synthesis
- I03.resynthesis.pd (copy & pasted): fourier resynthesis

In both examples, you can modify the array by dragging your finger accross
the graphical representatio on your iDevice.

Hope this gives some people some good ideas for new and neat synthesizers!

Note also that helper patches are in a subfolder, which helps you to keep
your abstractions organized.  If you want to do this in your own projects,
It is explained in further detail on the pd-for-ios wiki at:

https://github.com/libpd/pd-for-ios/wiki/ios

The Libpd source and documentation is available at
https://github.com/libpd/libpd

Documentation specific to the array api is at:
https://github.com/libpd/libpd/wiki/libpd

TODO: multi-touch array editing

--------------- License ------------

This software is copyrighted by Miller Puckette, Reality Jockey, Peter Brinkmann, 
Richard Eakin and others.  
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
