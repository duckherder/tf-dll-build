
REM Use the -s switch to build to see full commands produced by bazel
echo Using bazel to build tensorflow...
bazel --output_base=_bazel_build build --config=opt //tensorflow:tensorflow_cc.dll
bazel shutdown
echo off

REM Check for DLL
if exist bazel-bin/tensorflow/tensorflow_cc.dll (
    echo Found TensorFlow DLL...
) else (
    echo Unable to find TensorFlow DLL!
    pause
    exit /b 3
)

REM Delete the DLLs that bazel built as they do not contain exported C++ API
echo Delete bazel built dll and library files...
mv -f bazel-bin/tensorflow/tensorflow_cc.dll bazel-bin/tensorflow/tensorflow_cc_orig.dll
mv -f bazel-bin/tensorflow/tensorflow_cc.dll.if.exp bazel-bin/tensorflow/tensorflow_cc_orig.dll.if.exp
mv -f bazel-bin/tensorflow/tensorflow_cc.dll.if.lib bazel-bin/tensorflow/tensorflow_cc_orig.dll.if.lib
if exist bazel-genfiles/tensorflow/tensorflow_filtered_def_file_orig.def (
    echo Copy of original .def file exists...
) else (
    cp bazel-genfiles/tensorflow/tensorflow_filtered_def_file.def bazel-genfiles/tensorflow/tensorflow_filtered_def_file_orig.def
)

REM Patch the DEF file with C++ exports
REM Add to here to patches file as required
echo Patch the automatically built .def file...
chmod 666 bazel-genfiles/tensorflow/tensorflow_filtered_def_file.def
cat bazel-genfiles/tensorflow/tensorflow_filtered_def_file_orig.def > bazel-genfiles/tensorflow/tensorflow_filtered_def_file.def
cat export-patches.def >> bazel-genfiles/tensorflow/tensorflow_filtered_def_file.def

REM This is the command from tensorflow
REM It may need updating in future. Use -s switch in build and copy last link stage in bazel build below
echo Re-linking with the modified def file...
link.exe /nologo /DLL /SUBSYSTEM:CONSOLE -defaultlib:advapi32.lib -DEFAULTLIB:advapi32.lib -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 -ignore:4221 /MACHINE:X64 @bazel-out/x64_windows-opt/bin/tensorflow/tensorflow_cc.dll-2.params /OPT:ICF /OPT:REF /DEF:bazel-out/x64_windows-opt/genfiles/tensorflow/tensorflow_filtered_def_file.def /ignore:4070

REM Create the output release directory
if exist tensorflow-release (
    echo Release directory aleady exists...
    pause
    exit /b 5
)

echo Create release directory structure...
mkdir tensorflow-release
mkdir tensorflow-release\bin
mkdir tensorflow-release\include
mkdir tensorflow-release\include\google
mkdir tensorflow-release\include\unsupported
mkdir tensorflow-release\lib

REM Copying files as required by Tensorflow
echo Copying files...
cp bazel-bin/tensorflow/tensorflow_cc.dll tensorflow-release/bin
cp bazel-bin/tensorflow/tensorflow_cc.dll.if.lib tensorflow-release/lib/tensorflow_cc.lib
cp -r bazel-genfiles/tensorflow tensorflow-release/include
cp -r bazel-tensorflow/third_party tensorflow-release/include
cp -r bazel-tensorflow/external/com_google_absl/absl tensorflow-release/include
if exist bazel-tensorflow/external/protobuf_archive (
    cp -r bazel-tensorflow/external/protobuf_archive/src/google/protobuf tensorflow-release/include/google
) else (
    cp -r bazel-tensorflow/external/com_google_protobuf/src/google/protobuf tensorflow-release/include/google
)
cp -r bazel-tensorflow/external/eigen_archive/unsupported/Eigen tensorflow-release/include/unsupported
cp -r bazel-tensorflow/external/eigen_archive/Eigen tensorflow-release/include
cp -r tensorflow/* tensorflow-release/include/tensorflow

echo Completed!
pause