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


class ViewController: UIViewController {
    let imageView = UIImageView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
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
        
        imageView.frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 160)
        self.view.addSubview(imageView)
        imageView.backgroundColor = .black
        if let filePath = Bundle.main.path(forResource: "bbb_sunflower_1080p_30fps_normal_10s", ofType: "mp4") {
            DispatchQueue.global().async {
                av_log_set_level(AV_LOG_DEBUG)
                avformat_network_init()
                print("Video file path: \(filePath)")
                self.open(file: filePath)
            }

        } else {
            print("Video file not found")
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
                    
                    let width = Int(pFrame?.pointee.width ?? 0)
                    let height = Int(pFrame?.pointee.height ?? 0)
                    // 行跨度 就是视频的宽度
                    let stride = Int(pFrame?.pointee.linesize.0 ?? 0)
                    
                    
                    
                    
                    // 声明了一个可选的CVPixelBuffer变量。这个变量将被用于存储创建的CVPixelBuffer
                    var pixelBuffer: CVPixelBuffer?
                    
                    let attrs = [
                        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, //这个键值对表示创建的CVPixelBuffer应该与CGImage兼容。CGImage是Core Graphics框架中的一个数据类型，用于表示位图图像。如果设置了这个属性，你可以将CVPixelBuffer直接转换为CGImage，或者从CGImage创建CVPixelBuffer
                        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue //这个键值对表示创建的CVPixelBuffer应该与CGBitmapContext兼容。CGBitmapContext是Core Graphics框架中的一个数据类型，用于处理位图图像的上下文。如果设置了这个属性，你可以将CVPixelBuffer直接用于CGBitmapContext，或者从CGBitmapContext创建CVPixelBuffer。
                    ]
                    
                    let status = CVPixelBufferCreateWithBytes(
                        nil, // 分配像素缓冲区内存的回调，这里我们让系统自动分配，所以传递nil
                        width, // 像素缓冲区的宽度，对应于视频帧的宽度
                        height, // 像素缓冲区的高度，对应于视频帧的高度
                        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, // 像素缓冲区的像素格式，这里我们使用YUV420P格式，对应于我们从FFmpeg解码的视频帧的格式
                        pFrame!.pointee.data.0!, // 像素数据的指针，这个数据来自于我们从FFmpeg解码的视频帧
                        stride, // 像素缓冲区的行跨度，对应于视频帧的行跨度
                        nil, // 释放像素缓冲区内存的回调，这里我们让系统自动释放，所以传递nil
                        nil, // 额外的像素缓冲区属性，这里我们不需要额外的属性，所以传递nil
                        attrs as CFDictionary, // 像素缓冲区的属性，我们之前创建了这个字典，以确保像素缓冲区与CGImage和CGBitmapContext兼容
                        &pixelBuffer // 这是一个指向CVPixelBuffer变量的指针，CVPixelBufferCreateWithBytes函数将创建的CVPixelBuffer存储在这个变量中
                    )
                    
                    
                    if status != kCVReturnSuccess {
                        print("创建像素缓冲区错误")
                        return
                    }
                    
                    let uiImage =  UIImage(pixelBuffer: pixelBuffer!)!
                    let image = convertYUV420ToRGB8888(yuvImage: uiImage)
                    DispatchQueue.main.async { [self] in
                        self.imageView.image = image//UIImage(named: "output.jpg")
                    }
    
                    
//                   let uiImage =  pixelBufferToImage(pixelBuffer: pixelBuffer!)
                    
//                    let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
                    
//                    let uiImage = UIImage(ciImage: ciImage)
//                    DispatchQueue.main.async {
//                        self.imageView.image = uiImage
//                    }
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
