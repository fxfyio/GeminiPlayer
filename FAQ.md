# 报错 GNU assembler not found, install/update gas-preprocessor

1、安装 gas-preprocessor

```
curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl -o gas-preprocessor.pl
chmod +x gas-preprocessor.pl
sudo mv gas-preprocessor.pl /usr/local/bin/
```

2、运行 ./gas-preprocessor.pl 报错

> Unescaped left brace in regex is deprecated here (and will be fatal in Perl 5.32), passed through in regex; marked by <-- HERE in m/(?:ld|st)\d\s+({ <-- HERE \s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/ at /usr/local/bin/gas-preprocessor.pl line 1066.
> Unrecognized input filetype at /usr/local/bin/gas-preprocessor.pl line 100.

解决方法:

这个错误提示出现是由于 gas-preprocessor.pl 脚本与您系统上安装的 Perl 版本有兼容性问题。从 Perl 5.26 开始，正则表达式中的左大括号 "{" 必须要转义。

打开文件找到 1066 行,修改为

```
if ($line =~ /(?:ld|st)\d\s+(\{\s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/) {
```

3、报错

```
ld: Undefined symbols:
  _BZ2_bzDecompress, referenced from:
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
  _BZ2_bzDecompressEnd, referenced from:
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
  _BZ2_bzDecompressInit, referenced from:
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
  _CMBlockBufferCopyDataBytes, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _OUTLINED_FUNCTION_6 in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMBlockBufferCreateWithMemoryBlock, referenced from:
      _ff_videotoolbox_common_end_frame in libavcodec.a[arm64][872](videotoolbox.o)
  _CMBlockBufferGetDataLength, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMFormatDescriptionGetExtension, referenced from:
      _set_extradata in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferCreate, referenced from:
      _ff_videotoolbox_common_end_frame in libavcodec.a[arm64][872](videotoolbox.o)
  _CMSampleBufferGetDataBuffer, referenced from:
      _OUTLINED_FUNCTION_4 in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferGetDecodeTimeStamp, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferGetFormatDescription, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _set_extradata in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferGetPresentationTimeStamp, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferGetSampleAttachmentsArray, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMSampleBufferGetTotalSampleSize, referenced from:
      _OUTLINED_FUNCTION_5 in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMTimeMake, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _CMVideoFormatDescriptionCreate, referenced from:
      _videotoolbox_start in libavcodec.a[arm64][872](videotoolbox.o)
  _CMVideoFormatDescriptionGetH264ParameterSetAtIndex, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTCompressionSessionCompleteFrames, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_close in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTCompressionSessionCreate, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTCompressionSessionEncodeFrame, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTCompressionSessionGetPixelBufferPool, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTCompressionSessionPrepareToEncodeFrames, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTDecompressionSessionCreate, referenced from:
      _videotoolbox_start in libavcodec.a[arm64][872](videotoolbox.o)
  _VTDecompressionSessionDecodeFrame, referenced from:
      _ff_videotoolbox_common_end_frame in libavcodec.a[arm64][872](videotoolbox.o)
  _VTDecompressionSessionInvalidate, referenced from:
      _ff_videotoolbox_uninit in libavcodec.a[arm64][872](videotoolbox.o)
      _ff_videotoolbox_common_end_frame in libavcodec.a[arm64][872](videotoolbox.o)
      _av_videotoolbox_default_free in libavcodec.a[arm64][872](videotoolbox.o)
  _VTDecompressionSessionWaitForAsynchronousFrames, referenced from:
      _ff_videotoolbox_common_end_frame in libavcodec.a[arm64][872](videotoolbox.o)
  _VTSessionCopyProperty, referenced from:
      _vtenc_init in libavcodec.a[arm64][874](videotoolboxenc.o)
  _VTSessionSetProperty, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
      ...
  _compress, referenced from:
      _encode_frame in libavcodec.a[arm64][325](exrenc.o)
      _encode_strip in libavcodec.a[arm64][819](tiffenc.o)
  _compress2, referenced from:
      _flashsv_encode_frame in libavcodec.a[arm64][353](flashsvenc.o)
      _flashsv_encode_frame in libavcodec.a[arm64][353](flashsvenc.o)
  _deflate, referenced from:
      _flashsv2_encode_frame in libavcodec.a[arm64][352](flashsv2enc.o)
      _flashsv2_encode_frame in libavcodec.a[arm64][352](flashsv2enc.o)
      _flashsv2_encode_frame in libavcodec.a[arm64][352](flashsv2enc.o)
      _encode_frame in libavcodec.a[arm64][514](lclenc.o)
      _encode_frame in libavcodec.a[arm64][514](lclenc.o)
      _encode_headers in libavcodec.a[arm64][683](pngenc.o)
      _encode_frame in libavcodec.a[arm64][683](pngenc.o)
      _encode_frame in libavcodec.a[arm64][683](pngenc.o)
      _encode_frame in libavcodec.a[arm64][683](pngenc.o)
      ...
  _deflateBound, referenced from:
      _encode_frame in libavcodec.a[arm64][514](lclenc.o)
      _encode_png in libavcodec.a[arm64][683](pngenc.o)
      _encode_png in libavcodec.a[arm64][683](pngenc.o)
      _encode_apng in libavcodec.a[arm64][683](pngenc.o)
      _encode_apng in libavcodec.a[arm64][683](pngenc.o)
  _deflateEnd, referenced from:
      _ff_deflate_end in libavcodec.a[arm64][969](zlib_wrapper.o)
  _deflateInit_, referenced from:
      _ff_deflate_init in libavcodec.a[arm64][969](zlib_wrapper.o)
  _deflateReset, referenced from:
      _flashsv2_encode_frame in libavcodec.a[arm64][352](flashsv2enc.o)
      _flashsv2_encode_frame in libavcodec.a[arm64][352](flashsv2enc.o)
      _encode_frame in libavcodec.a[arm64][514](lclenc.o)
      _encode_headers in libavcodec.a[arm64][683](pngenc.o)
      _encode_frame in libavcodec.a[arm64][683](pngenc.o)
      _encode_frame in libavcodec.a[arm64][971](zmbvenc.o)
  _iconv, referenced from:
      _avcodec_decode_subtitle2 in libavcodec.a[arm64][253](decode.o)
      _avcodec_decode_subtitle2 in libavcodec.a[arm64][253](decode.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
  _iconv_close, referenced from:
      _avcodec_decode_subtitle2 in libavcodec.a[arm64][253](decode.o)
      _avcodec_decode_subtitle2 in libavcodec.a[arm64][253](decode.o)
      _ff_decode_preinit in libavcodec.a[arm64][253](decode.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
  _iconv_open, referenced from:
      _avcodec_decode_subtitle2 in libavcodec.a[arm64][253](decode.o)
      _ff_decode_preinit in libavcodec.a[arm64][253](decode.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
      _getstr8 in libavformat.a[arm64][252](mpegts.o)
  _inflate, referenced from:
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _decode_frame in libavcodec.a[arm64][513](lcldec.o)
      _decode_frame in libavcodec.a[arm64][513](lcldec.o)
      ...
  _inflateEnd, referenced from:
      _decode_frame in libavcodec.a[arm64][817](tiff.o)
      _ff_inflate_end in libavcodec.a[arm64][969](zlib_wrapper.o)
      _http_close in libavformat.a[arm64][168](http.o)
      _parse_content_encoding in libavformat.a[arm64][168](http.o)
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
      _rtmp_open in libavformat.a[arm64][340](rtmpproto.o)
      _rtmp_open in libavformat.a[arm64][340](rtmpproto.o)
      ...
  _inflateInit2_, referenced from:
      _parse_content_encoding in libavformat.a[arm64][168](http.o)
  _inflateInit_, referenced from:
      _decode_frame in libavcodec.a[arm64][817](tiff.o)
      _ff_inflate_init in libavcodec.a[arm64][969](zlib_wrapper.o)
      _matroska_decode_buffer in libavformat.a[arm64][219](matroskadec.o)
      _rtmp_open in libavformat.a[arm64][340](rtmpproto.o)
      _swf_read_header in libavformat.a[arm64][440](swfdec.o)
  _inflateReset, referenced from:
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
      _decode_frame in libavcodec.a[arm64][513](lcldec.o)
      _decode_frame in libavcodec.a[arm64][513](lcldec.o)
      _zlib_decomp in libavcodec.a[arm64][513](lcldec.o)
      _decode_frame_lscr in libavcodec.a[arm64][521](lscrdec.o)
      _decode_frame in libavcodec.a[arm64][610](mscc.o)
      ...
  _inflateSync, referenced from:
      _flashsv_decode_frame in libavcodec.a[arm64][351](flashsv.o)
  _kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms, referenced from:
      _videotoolbox_start in libavcodec.a[arm64][872](videotoolbox.o)
      _videotoolbox_start in libavcodec.a[arm64][872](videotoolbox.o)
  _kCMFormatDescriptionExtension_VerbatimSampleDescription, referenced from:
      _set_extradata in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kCMSampleAttachmentKey_NotSync, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kCMTimeIndefinite, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_close in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kCMTimeInvalid, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_AllowFrameReordering, referenced from:
      _vtenc_init in libavcodec.a[arm64][874](videotoolboxenc.o)
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_AverageBitRate, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_ColorPrimaries, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_DataRateLimits, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_MaxKeyFrameInterval, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_MoreFramesAfterEnd, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_MoreFramesBeforeStart, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_PixelAspectRatio, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_ProfileLevel, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_TransferFunction, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTCompressionPropertyKey_YCbCrMatrix, referenced from:
      _vtenc_create_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTEncodeFrameOptionKey_ForceKeyFrame, referenced from:
      _vtenc_frame in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Baseline_1_3, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Baseline_3_0, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Baseline_3_1, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Baseline_3_2, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Baseline_4_1, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_High_5_0, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_3_0, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_3_1, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_3_2, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_4_0, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_4_1, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _kVTProfileLevel_H264_Main_5_0, referenced from:
      _vtenc_configure_encoder in libavcodec.a[arm64][874](videotoolboxenc.o)
  _uncompress, referenced from:
      _decode_frame in libavcodec.a[arm64][231](cscd.o)
      _decode_frame in libavcodec.a[arm64][301](dxa.o)
      _zip_uncompress in libavcodec.a[arm64][323](exr.o)
      _pxr24_uncompress in libavcodec.a[arm64][323](exr.o)
      _dwa_uncompress in libavcodec.a[arm64][323](exr.o)
      _dwa_uncompress in libavcodec.a[arm64][323](exr.o)
      _dwa_uncompress in libavcodec.a[arm64][323](exr.o)
      ...
  _zlibCompileFlags, referenced from:
      _parse_content_encoding in libavformat.a[arm64][168](http.o)
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

解决

```
打开你的项目在Xcode中：双击你的 .xcodeproj 或 .xcworkspace 文件来打开你的项目。

导航到你的目标设置：在Xcode的导航栏上，选择 "Project navigator" (就是那个文件夹图标), 然后选择你的项目名称，接着在主窗口中选择你的目标。最后，点击 "Build Phases" 标签。

链接库：在 "Build Phases" 中，找到 "Link Binary With Libraries" 区域。点击 "+" 按钮来添加新的库。在弹出的窗口中，你可以搜索你想链接的库（如 libbz2.tbd, libz.tbd, libiconv.tbd, CoreMedia.framework, VideoToolbox.framework）。选择库，然后点击 "Add" 按钮。
```
