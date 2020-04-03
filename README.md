# tf-dll-build

### Introduction
Simple batch file to help build TensorFlow 64-bit DLL (CPU-only) versions 1.14-1.15 using Visual Studio 2017 
Community on Windows 10. This worked for me so hope you find it useful. Similar projects are available, such as 
https://github.com/sitting-duck/stuff/tree/master/ai/tensorflow/build_tensorflow_1.14_source_for_Windows
(obviously a duck thing!).

Building TensorFlow as a DLL is not straight forward and there are issues with the [bazel](https://bazel.build/)
build as provided in the TensorFlow project; such as missing DLL export names. These steps should provide you with
a way to patch the DLL to get it to work with at least one of the example applications
provided by TensorFlow.

### Pre-requisites
You need to install a number of pieces of software

1. Install latest Python 3.x from https://www.python.org/downloads/
2. Use pip to install the following packages
   ```
   pip3 install six numpy wheel protobuf future
   pip3 install keras_applications==1.0.6 --no-deps
   pip3 install keras_preprocessing==1.0.5 --no-deps
   ```
3. Install the latest Microsoft Visual Studio 2017 Community version
    * For TensorFlow build 1.14 builds also select addition of the Microsoft Visual C++ 2015 MSVC 14.0 compiler during installation
4. Install msys2 from https://www.msys2.org
5. Add c:\msys64\usr\bin to your Windows PATH environment variable
    * Note: If you are Cygwin user ensure that the MSYS path appears before any Cygwin directories
6.  Open an MSYS terminal window and type ```pacman -S git patch unzip```
7. From https://docs.bazel.build/versions/master/install-windows.html get version 0.24.1 of bazel
    * This version works for both 1.14 and 1.15 - don't use latest versions
8. Copy the Baxel executable to your PC e.g c:\Bazel and rename bazel.exe
9. Add c:\Bazel to your Windows PATH environment variable
10. Add the following Windows environment variables to build TensorFlow version 1.14 (exact directory structures may differ)
    ```
    BAZEL_SH=c:\msys64\usr\bin\bash.exe
    BAZEL_VC=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
    ```
11. Or to build TensorFlow version 1.15 with the 14.1 MSVC compiler (exact directory structures may differ)
    ```
    BAZEL_SH=c:\msys64\usr\bin\bash.exe
    BAZEL_VC=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC
    ```
12. Get a tagged version of TensorFlow source from https://github.com/tensorflow/tensorflow
13. Open a Windows Command Prompt and change directory to the TensorFlow source code root directory
14. From the command line for TensorFlow 1.14
    ```
    C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64\vcvars64.bat
    ```
15. Or for TensorFlow 1.15
    ```
    "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
    ```

### To build TensorFlow (CPU-only variant)
To build TensorFlow simply copy ```tensorflow-build-cpu.bat``` and ```export-patches.def``` 
from this project into the TensorFlow source code root directory. Then run
```
python .\configure.py
```
and accepting all the defaults provided they are correct. Then
```
call tensorflow-build-cpu.bat
```
Alternatively you can execute the steps in the batch file by hand. The build may take several hours to complete and consume significant amounts of memory.

If successful the build will be found in the ```tensorflow-release``` subdirectory.

### Using the build
To test the build you can copy the main.cc from ```tensorflow\tensorflow\examples\label_image```
in the TensorFow source tree into an empty Microsoft Visual Studio 2017 64-bit command line project.

To compile add the following to main.cc before including the TensorFlow header files
```
#ifndef NOMINMAX
#define NOMINMAX
#endif
#define COMPILER_MSVC
```

Add to project includes the directory ```tensorflow-release\include``` and library
directory ```tensorflow-release\lib```. Link your project with ```tensorflow_cc.lib```.
To run the compiled executable you will need to copy ```tensorflow-release\bin\tensorflow_cc.dll```
into your test project directory.

A modified version of main.cc from 1.14 is included in this repository.

### Issues
The TensorFlow bazel built DLL does not contain all necessary exports for many applications.
The batch file patches and re-links the DLL with a number of useful functions, enough for
most inference engines. If you use functions not defined in ```exported-patches.def```
you may get link errors in your test application. To resolve add any unresolved functions
to ```exported-patches.def``` and rebuild.

### Versions
Both 1.14 and 1.15 successfully built on
* Core i5-2500K CPU @ 3.3GHz
* 8.00GB RAM
* Windows 10 Pro
* 500GB disk
* Microsoft Visual Studio Community 2017 Version 15.9.19
* Bazel: 0.24.1
* Python 3.8.1
* Python packages
   * future: 0.18.2
   * Keras-Applications: 1.0.6
   * Keras-Preprocessing: 1.0.5
   * numpy: 1.18.2
   * pip: 20.0.2
   * protobuf: 3.11.3
   * setuptools: 41.2.0
   * six: 1.14.0
   * wheel: 0.34.2
