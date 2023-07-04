```
--disable-static ：// 不构建静态库[默认：关闭]
--enable-shared ：// 构建共享库
--enable-gpl ：  // 允许使用GPL代码。
--enable-nonfree ：// 允许使用非免费代码。
--disable-doc ：  // 不构造文档
--disable-avfilter  ：// 禁止视频过滤器支持
--enable-small  ：   // 启用优化文件尺寸大小（牺牲速度）
--cross-compile  ： // 使用交叉编译
--disable-hwaccels  ：// 禁用所有硬件加速(本机不存在硬件加速器，所有不需要)
--disable-network  ：//  禁用网络

--disable-ffmpeg  --disable-ffplay  --disable-ffprobe  --disable-ffserver
// 禁止ffmpeg、ffplay、ffprobe、ffserver

--disable-avdevice --disable-avcodec --disable-avcore
// 禁止libavdevice、libavcodec、libavcore

--list-decoders ： // 显示所有可用的解码器
--list-encoders ： // 显示所有可用的编码器
--list-hwaccels ： // 显示所有可用的硬件加速器
--list-protocols ： // 显示所有可用的协议
--list-indevs ：   // 显示所有可用的输入设备
--list-outdevs ： // 显示所有可用的输出设备
--list-filters ：// 显示所有可用的过滤器
--list-parsers ：// 显示所有的解析器
--list-bsfs ：  // 显示所有可用的数据过滤器

--disable-encoder=NAME ： // 禁用XX编码器 | disables encoder NAME
--enable-encoder=NAME ： // 用XX编码器 | enables encoder NAME
--disable-decoders ：   // 禁用所有解码器 | disables all decoders

--disable-decoder=NAME ： // 禁用XX解码器 | disables decoder NAME
--enable-decoder=NAME ： // 启用XX解码器 | enables decoder NAME
--disable-encoders ：   // 禁用所有编码器 | disables all encoders

--disable-muxer=NAME ： // 禁用XX混音器 | disables muxer NAME
--enable-muxer=NAME ： // 启用XX混音器 | enables muxer NAME
--disable-muxers ：   // 禁用所有混音器 | disables all muxers

--disable-demuxer=NAME ： // 禁用XX解轨器 | disables demuxer NAME
--enable-demuxer=NAME ： // 启用XX解轨器 | enables demuxer NAME
--disable-demuxers ：   // 禁用所有解轨器 | disables all demuxers

--enable-parser=NAME ：  // 启用XX剖析器 | enables parser NAME
--disable-parser=NAME ： // 禁用XX剖析器 | disables parser NAME
--disable-parsers ：    // 禁用所有剖析器 | disa

```
