# abl_link~ for Android

**This solution is not yet packaged for easy consumption. Don't try this unless you're prepared to tinker with build configs and C++ code. Also, expect this to change as I figure out better ways to do this.**

Note: While this solution is about using the abl_link~ external with Pd for Android, it should contain enough information to allow developers to integrate Link into Android apps that don't use Pd.

## How to build abl_link~ for Android

* Set up a libpd-based Android project that builds libpd from source: https://github.com/libpd/pd-for-android#using-android-studio (For the first prototype, I simply tweaked the PdTest sample app that comes with Pd for Android.)
* Add `<uses-permission android:name="android.permission.INTERNET" />` to your manifest. Without it, there won't be any obvious failures, but abl_link~ will not connect to other Link instances.
* Copy all of `abl_link/external` to the `jni` directory of your project.
* Add `Android.mk` and `Application.mk` to your `jni` directory.
* Depending on the location of your project, you'll probably need to adjust the relative path to `PdCore` in `Android.mk`.
* Once the build system is set up correctly, you'll probably see compiler errors. Those are easy to fix, but you'll need to modify the Link source code to do this.
* Replace `std::llround` by `llround` in `link/include/ableton/link/Beats.hpp` and `link/include/ableton/link/Tempo.hpp`.
* Delete the invocation of `to_string` in `include/ableton/discovery/Payload.hpp`.
* Now the external _should_ build, and if your app uses libpd by way of PdService, it should be able to find and use the external.

## What's going on here?

* The main challenge was to find an Android toolchain that works with Link. I tried many combinations, but the only one that worked for me was GNU 4.9 with the gnustl_static library. `Application.mk` includes the necessary settings. 
* So far, I've only been able to make this work with android-21 (Android 5.0 Lollipop) or later.
* Link uses ifaddrs, which is not part of the stable Android APIs. So, I looked around and decided to borrow the implementation of ifaddrs that comes with the Android version of Chromium, which is BSD-licensed and IPv6 aware. It's included here, in `external/android-ifaddrs`.
* Other than that, I just took a few straightforward compiler flags to make this work. They're in `Android.mk`.
* For purposes other than libpd, `Application.mk` should work as is, and `Android.mk` should be straightforward to adjust. Good luck!

