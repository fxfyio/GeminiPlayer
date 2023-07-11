//
//  ViewController.swift
//  GeminiPlayer
//
//  Created by zc on 5/21/23.
//

import UIKit
import Accelerate
//import MetalKit
import CoreGraphics
import AVFoundation


class ViewController: UIViewController {
    let playerView = UIView()

    let videoLayer = AVSampleBufferDisplayLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        videoLayer.videoGravity = .resizeAspect
        videoLayer.backgroundColor = UIColor.red.cgColor
        playerView.layer.addSublayer(videoLayer)

        videoLayer.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        videoLayer.addObserver(self, forKeyPath: "error", options: [.new], context: nil)

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
        
        playerView.frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 200)
        self.view.addSubview(playerView)
        playerView.backgroundColor = .black
        if let filePath = Bundle.main.path(forResource: "bbb_sunflower_1080p_30fps_normal", ofType: "mp4") {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else {
                    return
                }
                av_log_set_level(AV_LOG_DEBUG)
                avformat_network_init()
                print("Video file path: \(filePath)")
                self.open(file: filePath)
            }

        } else {
            print("Video file not found")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let status = change?[.newKey] as? Int {
                switch status {
                case 0:
                    print("The status of the player item is unknown.")
                case 1:
                    print("The player item is ready to play.")
                case 2:
                    print("The player item failed. See the error property for more information.")
                default:
                    break
                }
            }
        } else if keyPath == "error" {
            print("xxx")
        }
    }

    
    func open(file path: String?) {
        guard path != nil else {
            return
        }
        // 分配一个AVFormatContext
        var avFormatContext = avformat_alloc_context()
        
        ///1、上下文
        ///2、视频URL
        ///3、文件格式。如果为空自动探测格式
        ///4、特定选项字典 🌱
        if avformat_open_input(&avFormatContext, path, nil, nil) != 0 {
            print("无法打开文件")
            return
        }
        
        // 获取流信息
        if avformat_find_stream_info(avFormatContext, nil) < 0 {
            print("无法找到流信息")
            return
        }
        
        // 找到第一个视频流
        var videoStream = -1
        for i in 0..<(avFormatContext?.pointee.nb_streams ?? 0) {
            if avFormatContext?.pointee.streams[Int(i)]?.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_VIDEO {
                videoStream = Int(i)
                break
            }
        }
        
        if videoStream == -1 {
            print("没有找到视频流")
            return
        }
        
        // 获取视频流的编解码器参数
        let pCodecPar = avFormatContext?.pointee.streams[videoStream]?.pointee.codecpar
        
        // 根据编码器找到视频流的解码器
        let pCodec = avcodec_find_decoder(pCodecPar?.pointee.codec_id ?? AV_CODEC_ID_NONE)
        
        if pCodec == nil {
            print("不支持的编解码器！")
            return
        }
        
        // 为与特定编解码器相关联的 AVCodecContext 分配内存
        var pCodecCtx = avcodec_alloc_context3(pCodec)
        if pCodecCtx == nil {
            print("无法分配编解码器上下文")
            return
        }
        
        ///将AVCodecParameters结构的值复制到AVCodecContext结构。
        ///AVCodecParameters包含有关媒体流（如音频或视频）的编解码器的参数。
        ///这些参数包括编解码器类型、编解码器ID、比特率、帧率、采样率、像素格式、声道布局等等。
        if avcodec_parameters_to_context(pCodecCtx, pCodecPar) < 0 {
            print("无法复制编解码器参数")
            return
        }
        
        // 打开编解码器
        if avcodec_open2(pCodecCtx, pCodec, nil) < 0 {
            print("无法打开编解码器")
            return
        }

        // 任务是为AVPacket结构分配内存
        let packet = av_packet_alloc()
        
        
        // 为AVFrame结构分配内存
        var pFrame = av_frame_alloc()

        // 循环读取下一帧
        while av_read_frame(avFormatContext, packet) >= 0 {
            // 这个包是视频流的吗？
            if (packet?.pointee.stream_index ?? 0) == videoStream {
                // 将包含压缩数据的 AVPacket 发送到解码器进行解码
                if avcodec_send_packet(pCodecCtx, packet) < 0 {
                    print("发送包失败")
                    continue
                }
                
                // 作用是从编解码器中接收解码后的数据帧
                while avcodec_receive_frame(pCodecCtx, pFrame) == 0 {
                    
                    if let pointer = pFrame {
                        
                        // 获取 AVFrame 的像素数据和行大小
                        // 获取 AVFrame 的像素数据和行大小
                        let frameData: [UnsafePointer<UInt8>?] = [
                            UnsafePointer(pointer.pointee.data.0!),
                            UnsafePointer(pointer.pointee.data.1!),
                            UnsafePointer(pointer.pointee.data.2!)
                        ]


                        let frameLinesize = [
                            Int32(pointer.pointee.linesize.0),
                            Int32(pointer.pointee.linesize.1),
                            Int32(pointer.pointee.linesize.2)
                        ]


                        // 创建一个 SwsContext 来进行像素格式转换和缩放
                        let swsContext = sws_getContext(
                            pCodecCtx!.pointee.width,
                            pCodecCtx!.pointee.height,
                            pCodecCtx!.pointee.pix_fmt,
                            pCodecCtx!.pointee.width,
                            pCodecCtx!.pointee.height,
                            AV_PIX_FMT_RGB24,
                            SWS_BILINEAR,
                            nil, nil, nil
                        )
                        
                        // 创建一个 CVPixelBuffer 来保存解码后的像素数据
                        var pixelBuffer: CVPixelBuffer?
                        let attrs = [
                            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
                        ] as CFDictionary
                        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(pCodecCtx!.pointee.width), Int(pCodecCtx!.pointee.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
                        guard status == kCVReturnSuccess else {
                            print("Error: could not create CVPixelBuffer")
                            continue
                        }


                        // 获取 CVPixelBuffer 的像素数据和行大小
                        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
                        let pixelBufferBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer!)!.assumingMemoryBound(to: UInt8.self)
                        let pixelBufferBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer!)
                      
                        let frameDataBuffer = frameData.withUnsafeBufferPointer { UnsafePointer($0.baseAddress) }

                        // 将像素数据从 AVFrame 复制到 CVPixelBuffer
                        var dst: [UnsafeMutablePointer<UInt8>?] = [pixelBufferBaseAddress]
                        var dstStride = [Int32(pixelBufferBytesPerRow)]
                        sws_scale(
                            swsContext,
                            frameData,
                            frameLinesize,
                            0,
                            pCodecCtx!.pointee.height,
                            &dst,
                            &dstStride
                        )
                        
                        // 创建一个 CMSampleBuffer
                        var sampleBuffer: CMSampleBuffer?
                        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: CMTime.invalid, decodeTimeStamp: CMTime.invalid)
                        var formatDescription: CMVideoFormatDescription?
                        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescriptionOut: &formatDescription)
                        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: formatDescription!, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
                        
                        // 将 CMSampleBuffer 添加到 videoLayer
                        DispatchQueue.main.async {
                            if self.videoLayer.isReadyForMoreMediaData {
                                self.videoLayer.enqueue(sampleBuffer!)
                            }
                        }
                        
                    }
                    
                    
                }
            }
            
            // 释放由av_read_frame分配的包
            av_packet_unref(packet)
        }
        
        // 释放帧
        av_frame_free(&pFrame)
        
        // 关闭编解码器
        avcodec_free_context(&pCodecCtx)
        
        // 关闭视频文件
        avformat_close_input(&avFormatContext)
        
        
        
    }
    
    func saveImageToSandbox(image: UIImage, filename: String) {
        // 获取沙盒的Documents目录
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        // 将UIImage转换为PNG数据
        if let data = image.pngData() {
            // 将数据写入到文件
            do {
                try data.write(to: fileURL)
                print("Image saved to \(fileURL)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
    


}


import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}


func convertYUV420ToRGB8888(yuvImage: UIImage) -> UIImage? {
    guard let cgImage = yuvImage.cgImage else { return nil }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let context = CGContext(data: nil,
                            width: cgImage.width,
                            height: cgImage.height,
                            bitsPerComponent: 8,
                            bytesPerRow: cgImage.width * 4,
                            space: colorSpace,
                            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let bitmapData = context?.data else { return nil }
    
    let yPlane: UnsafeMutablePointer<UInt8> = bitmapData.assumingMemoryBound(to: UInt8.self)
    let uPlane: UnsafeMutablePointer<UInt8> = yPlane + (cgImage.width * cgImage.height)
    let vPlane: UnsafeMutablePointer<UInt8> = uPlane + ((cgImage.width * cgImage.height) / 4)
    
    for y in 0..<cgImage.height {
        for x in 0..<cgImage.width {
            let yPixel = yPlane[y * cgImage.width + x]
            let uPixel = uPlane[(y/2) * (cgImage.width/2) + (x/2)]
            let vPixel = vPlane[(y/2) * (cgImage.width/2) + (x/2)]
            
            let rCalc = 1.370705 * Double((Int(vPixel) - 128))
            let rPixel = max(0, min(255, Int(Double(yPixel)) + Int(rCalc)))
            
            let gCalc1 = 0.698001 * Double((Int(vPixel) - 128))
            let gCalc2 = 0.337633 * Double((Int(uPixel) - 128))
            let gPixel = max(0, min(255, Double(Int(Double(yPixel))) - gCalc1 - gCalc2))
            
            let bCalc = 1.732446 * Double((Int(uPixel) - 128))
            let bPixel = max(0, min(255, Int(Double(yPixel)) + Int(bCalc)))
            
            context?.setFillColor(red: CGFloat(rPixel)/255, green: CGFloat(gPixel)/255, blue: CGFloat(bPixel)/255, alpha: 1)
            context?.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
    }
    
    return context?.makeImage().flatMap { UIImage(cgImage: $0) }
}
