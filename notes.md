用于显示视频帧的详细信息：

```
ffprobe -show_frames -print_format json -i input.mp4
```

查看视频像素格式

```
ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=noprint_wrappers=1:nokey=1 video.mp4
```
