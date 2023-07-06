//
//  ViewController.swift
//  GeminiPlayer
//
//  Created by zc on 5/21/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let version = String(cString: av_version_info())
        let config = String(cString: avcodec_configuration())
        let license = String(cString: avcodec_license())
        print("FFmpeg version: \(version)")
        let label = UILabel()
        label.numberOfLines = 0
        label.frame = self.view.bounds
        label.textAlignment = .center
        label.text = version + "\n" + config + "\n" + license
        self.view.addSubview(label)
        
        if let filePath = Bundle.main.path(forResource: "bbb_sunflower_1080p_30fps_normal", ofType: "mp4") {
            av_log_set_level(AV_LOG_DEBUG)
            print("Video file path: \(filePath)")
            open(file: filePath)
        } else {
            print("Video file not found")
        }
    }

    
    func open(file path: String?) {
        guard let filePath = path else {
            return
        }
        
        ///AVFormatContext 是FFmpeg库中的一个结构体，它提供了大量的视频和音频数据和元数据。
        var pFormatContext: UnsafeMutablePointer<AVFormatContext>?
        /// 1、打开文件：
        /// 使用 avformat_open_input() 函数打开媒体文件，该函数会读取文件头以判断文件格式。
        let result = avformat_open_input(&pFormatContext, filePath, nil, nil)
        guard result >= 0 else {
            print("Could not open file")
            return
        }
        
        ///2、检索媒体流信息：
        ///使用 avformat_find_stream_info() 函数检索媒体流的信息。
        guard avformat_find_stream_info(pFormatContext, nil) >= 0 else {
            print("Could not get stream info")
            return
        }
        
        ///3、寻找视频流：
        ///遍历所有的媒体流以找到视频流。
        
        ///videoStreamIndex 这个变量就是用来存储视频流的索引的。将它初始化为 -1，这是一个常见的做法，因为 -1 通常表示“未找到”或“无效”的索引。然后，你可以遍历媒体文件的所有流，当找到一个视频流时，就将它的索引赋值给 videoStreamIndex。
        var videoStreamIndex = -1
        /// 在FFmpeg中，AVFormatContext 是一个重要的结构体，它包含了与媒体文件相关的大部分信息。当你打开一个媒体文件时，FFmpeg会创建一个 AVFormatContext 结构体，并填充各种信息。其中的一项信息就是 nb_streams，它表示此媒体文件包含的流的数量。
        for i in 0..<(pFormatContext?.pointee.nb_streams ?? 0) {
            if pFormatContext?.pointee.streams[Int(i)]!.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_VIDEO {
                videoStreamIndex = Int(i)
                break
            }
        }
        guard videoStreamIndex != -1 else {
            print("Could not find a video stream")
            return
        }


        /// 4、获取解码器：
        /// 找到视频流后，找到相应的解码器并使用 avcodec_open2() 函数打开它。
        let pCodecParameters = pFormatContext?.pointee.streams[videoStreamIndex]!.pointee.codecpar
        guard let pCodec = avcodec_find_decoder(pCodecParameters!.pointee.codec_id) else {
            print("Unsupported codec")
            return
        }

        var pCodecContext = avcodec_alloc_context3(pCodec)
        guard avcodec_open2(pCodecContext, pCodec, nil) >= 0 else {
            print("Could not open codec")
            return
        }

        /// 5、读取并解码视频帧：
        /// 使用 av_read_frame() 函数读取视频帧，然后使用 avcodec_send_packet() 和 avcodec_receive_frame() 函数将其解码。
        /// 这行代码分配了一个新的AVPacket结构体。AVPacket主要用于存储编码后的数据，如音频或视频数据。
        let packet = av_packet_alloc()
        /// 这行代码分配了一个新的AVFrame结构体。AVFrame用于存储解码后的数据，可以是音频样本或者图像帧。
        var pFrame = av_frame_alloc()

        /// 这行代码在循环中读取媒体文件中的下一帧。av_read_frame函数会把读取的数据放入到packet中。
        while av_read_frame(pFormatContext, packet) >= 0 {
            /// 这行代码检查读取的数据帧是否属于我们关心的视频流。stream_index就是媒体文件中不同种类流（如音频流、视频流、字幕流等）的索引。videoStreamIndex是我们之前找到的视频流的索引。
            if packet!.pointee.stream_index == videoStreamIndex {
                ///这行代码尝试将包含编码数据的packet发送到解码器。如果发送失败，那么打印错误信息并跳过此次循环。
                guard avcodec_send_packet(pCodecContext, packet) >= 0 else {
                    print("Error sending packet for decoding")
                    continue
                }
                ///这行代码尝试从解码器接收解码后的帧，并将其存储在pFrame中。只要解码器能接收到帧，就会持续执行这个循环。
                while avcodec_receive_frame(pCodecContext, pFrame) == 0 {
                    print("Frame decoded")
                    let pixelFormat = pFrame?.pointee.format
                    
                    // 创建一个SwsContext以转换像素格式
                    let swsCtx = sws_getContext(pCodecContext?.pointee.width ?? 0,
                                                pCodecContext?.pointee.height ?? 0,
                                                AVPixelFormat(rawValue: pixelFormat ?? 0),
                                                pCodecContext?.pointee.width ?? 0,
                                                pCodecContext?.pointee.height ?? 0,
                                                AV_PIX_FMT_RGB24,
                                                SWS_BILINEAR,
                                                nil,
                                                nil,
                                                nil)
                    
                    // 创建一个新的AVFrame以保存转换后的帧
                    var pFrameRGB = av_frame_alloc()
                    
                    
                    // 获取指向输入帧数据和输出帧数据的指针的指针
                    let srcSlice: [UnsafePointer<UInt8>?] = [UnsafePointer(pFrame?.pointee.data.0)]
                    let dstSlice: [UnsafeMutablePointer<UInt8>?] = [UnsafeMutablePointer(pFrameRGB?.pointee.data.0)]
                    
                    // 获取输入帧和输出帧的行大小
                    let srcStride = [Int32(pFrame?.pointee.linesize.0 ?? 0)]
                    let dstStride = [Int32(pFrameRGB?.pointee.linesize.0 ?? 0)]
                    
                    // 使用sws_scale转换像素格式
                    sws_scale(swsCtx, srcSlice, srcStride, 0, pCodecContext?.pointee.height ?? 0, dstSlice, dstStride)
                    
                    
                    
                    // 将转换后的帧转换为CGImage
                    if let image = convertFrameToImage(frame: pFrameRGB) {
                        DispatchQueue.main.async {
                            // 在这里，imageView是你用来显示图像的UIImageView实例
//                            self.imageView.image = UIImage(cgImage: image)
                        }
                    }
                    
                    // 释放分配的帧
                    av_frame_free(&pFrameRGB)
                    sws_freeContext(swsCtx)
                }
            }
            //这行代码释放了packet所占用的所有资源，并且将其重置为新分配的状态。
            av_packet_unref(packet)
        }

        
        avformat_close_input(&pFormatContext)
        avcodec_free_context(&pCodecContext)
        av_frame_free(&pFrame)



    }

    func convertFrameToImage(frame: UnsafeMutablePointer<AVFrame>?) -> CGImage? {
        guard let frame = frame else { return nil }

        let width = Int(frame.pointee.width)
        let height = Int(frame.pointee.height)
        let bitsPerComponent = 8
        let bitsPerPixel = 24
        let bytesPerRow = 3 * width

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }

        var data = Array(repeating: UInt8(0), count: height * bytesPerRow)

        for y in 0 ..< height {
            for x in 0 ..< width {
                let src = Int(frame.pointee.linesize.0) * y + x * 3
                let dst = bytesPerRow * y + x * 3
                data[dst] = frame.pointee.data.0![src]
                data[dst + 1] = frame.pointee.data.0![src + 1]
                data[dst + 2] = frame.pointee.data.0![src + 2]
            }
        }

        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        guard let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count)) else { return nil }

        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

}

