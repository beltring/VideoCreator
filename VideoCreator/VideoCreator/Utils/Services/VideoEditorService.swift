//
//  VideoEditorService.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit
import AVFoundation

final class VideoEditorService: NSObject {

    public typealias CompletedCombineBlock = (_ success: Bool, _ videoURL: URL?) -> Void

    private var images: [UIImage?] = []
    private var transition: Effect = .none

    private let size = CGSize(width: 1000, height: 1000)
    private var videoDuration: Int?
    private var frameDuration: Int = 2
    private let transitionDuration: Int = 1
    private var transitionFrameCount = 60
    private var framesToWaitBeforeTransition = 30

    private var videoWriter: AVAssetWriter?
    private var timescale = 10000000
    private var transitionRate: Double = 1
    private let mediaInputQueue = DispatchQueue(label: "mediaInputQueue")
    private let flags = CVPixelBufferLockFlags(rawValue: 0)

    private var rotate: CGFloat = 0.06

    public override init() {
        super.init()
    }

    public convenience init(images: [UIImage?], effect: Effect) {
        self.init()

        self.images = images
        self.transition = effect
    }

    public func buildVideo(completed: @escaping CompletedCombineBlock) {
        guard !images.isEmpty else {
            completed(false, nil)
            return
        }

        calculateTime()

        // video path
        let videoPath = Constants.LibraryURL.appendingPathComponent("\(transition).mov")
        print(videoPath)
        self.deletePreviousTmpVideo(url: videoPath)

        // writer
        self.videoWriter = try? AVAssetWriter(outputURL: videoPath, fileType: .mov)

        guard let videoWriter = self.videoWriter else {
            print("Create video writer failed")
            completed(false, nil)
            return
        }

        // input
        let videoSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: self.size.width,
            AVVideoHeightKey: self.size.height
        ] as [String : Any]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriter.add(writerInput)

        // adapter
        let bufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)
        ]
        let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: bufferAttributes)


        self.startWriting(
            videoWriter: videoWriter,
            writerInput: writerInput,
            bufferAdapter: bufferAdapter,
            completed: { (success, _) in
                if success {
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath.path, self, nil, nil)
                    completed(success, videoPath)
                } else {
                    completed(false, nil)
                }
        })
    }

    fileprivate func calculateTime() {
        guard self.images.isEmpty == false else { return }

        let hasSetDuration = self.videoDuration != nil
        self.timescale = hasSetDuration ? 100000 : 1
        let average = hasSetDuration ? Int(self.videoDuration! * self.timescale / self.images.count) : 2

        self.frameDuration = hasSetDuration ? average : 2

        let frame = 60
        self.transitionFrameCount = Int(frame * self.transitionDuration / self.timescale)
        self.framesToWaitBeforeTransition = self.transitionFrameCount / 2

        self.transitionRate = 1 / (Double(self.transitionDuration) / Double(self.timescale))
        self.transitionRate = self.transitionRate == 0 ? 1 : self.transitionRate

        if hasSetDuration == false {
            self.videoDuration = self.frameDuration * self.timescale * self.images.count
        }
    }

    fileprivate func startWriting(videoWriter: AVAssetWriter,
               writerInput: AVAssetWriterInput,
               bufferAdapter: AVAssetWriterInputPixelBufferAdaptor,
               completed: CompletedCombineBlock?)
    {

        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: CMTime.zero)

        var presentTime = CMTime(seconds: 0, preferredTimescale: Int32(self.timescale))
        var i = 0

        writerInput.requestMediaDataWhenReady(on: self.mediaInputQueue) {
            while true {
                if i >= self.images.count {
                    break
                }

                let duration = self.frameDuration
                presentTime = CMTimeMake(value: Int64(i * duration), timescale: Int32(self.timescale))

                let presentImage = self.images[i]
                let nextImage: UIImage? = self.images.count > 1 && i != self.images.count - 1 ? self.images[i + 1] : nil


                presentTime = self.appendTransitionBuffer(
                    at: i,
                    presentImage: presentImage,
                    nextImage: nextImage,
                    time: presentTime,
                    writerInput: writerInput,
                    bufferAdapter: bufferAdapter
                )

                self.images[i] = nil
                i += 1
            }

            writerInput.markAsFinished()
            videoWriter.finishWriting {
                DispatchQueue.main.async {
                    print("\n MYLOG: writing finished")
                    if let error = videoWriter.error {
                        print("\n MYLOG: error writing: \(error.localizedDescription)")
                        completed?(false, nil)
                    }
                    completed?(true, nil)
                }
            }
        }
    }

    fileprivate func appendTransitionBuffer(at position: Int,
                                  presentImage: UIImage?,
                                  nextImage: UIImage?,
                                  time: CMTime,
                                  writerInput: AVAssetWriterInput,
                                  bufferAdapter: AVAssetWriterInputPixelBufferAdaptor) -> CMTime
    {

        var presentTime = time

        if let cgImage = presentImage?.cgImage {
            if let buffer = self.transitionPixelBuffer(fromImage: cgImage, toImage: nextImage?.cgImage, with: .none, rate: 0) {

                while !writerInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.1)
                }

                bufferAdapter.append(buffer, withPresentationTime: presentTime)

                let transitionTime = CMTimeMake(value: Int64(self.transitionDuration), timescale: Int32(self.transitionFrameCount * self.timescale))

                presentTime = CMTimeAdd(presentTime, CMTimeMake(value: Int64(self.frameDuration - self.transitionDuration), timescale: Int32(self.timescale)))

                if position + 1 < self.images.count {
                    if self.transition != .none {
                        let framesToTransitionCount = self.transitionFrameCount - self.framesToWaitBeforeTransition
                        for j in 1...framesToTransitionCount {

                            let rate: CGFloat = CGFloat(Double(j) / Double(framesToTransitionCount))

                            if let transitionBuffer = self.transitionPixelBuffer(fromImage: cgImage, toImage: nextImage?.cgImage, with: self.transition, rate: rate) {

                                while !writerInput.isReadyForMoreMediaData {
                                    Thread.sleep(forTimeInterval: 0.1)
                                }

                                bufferAdapter.append(transitionBuffer, withPresentationTime: presentTime)
                                presentTime = CMTimeAdd(presentTime, transitionTime)
                            }
                        }
                    }
                }
            }
        }
        return presentTime
    }

    fileprivate func transitionPixelBuffer( fromImage: CGImage, toImage: CGImage?, with transition: Effect, rate: CGFloat) -> CVPixelBuffer? {
        let transitionBuffer = autoreleasepool { () -> CVPixelBuffer? in
            guard let buffer = self.createBuffer() else { return nil }

            CVPixelBufferLockBaseAddress(buffer, self.flags)

            let pxdata = CVPixelBufferGetBaseAddress(buffer)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

            let context = CGContext(
                data: pxdata,
                width: Int(self.size.width),
                height: Int(self.size.height),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: rgbColorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )
            context?.interpolationQuality = .low

            self.performTransitionDrawing(cxt: context, from: fromImage, to: toImage, with: transition, rate: rate)

            CVPixelBufferUnlockBaseAddress(buffer, self.flags)

            return buffer
        }
        return transitionBuffer
    }

    // Transition
    fileprivate func performTransitionDrawing(cxt: CGContext?, from: CGImage, to: CGImage?, with transition: Effect, rate: CGFloat) {
        let fromFitSize = self.size
        let toFitSize = self.size

        if to == nil {
            let rect = CGRect(x: 0, y: 0, width: fromFitSize.width, height: fromFitSize.height)
            cxt?.concatenate(.identity)
            cxt?.draw(from, in: rect)
            return
        }

        switch transition {

        // MARK: - none
        case .none:
            let rect = CGRect(x: 0, y: 0, width: fromFitSize.width, height: fromFitSize.height)
            cxt?.concatenate(.identity)
            cxt?.draw(from, in: rect)

        // MARK: - pushRight
        case .pushRight:
            let fromRect = CGRect(
                x: rate * self.size.width,
                y: 0,
                width: fromFitSize.width,
                height: fromFitSize.height
            )

            let toRect = CGRect(
                x: -(1 - rate) * self.size.width,
                y: 0,
                width: toFitSize.width,
                height: toFitSize.height
            )

            cxt?.draw(from, in: fromRect)
            cxt?.draw(to!, in: toRect)

        // MARK: - pushLeft
        case .pushLeft:
            let fromRect = CGRect(
                x: -rate * self.size.width,
                y: 0,
                width: fromFitSize.width,
                height: fromFitSize.height
            )
            let toRect = CGRect(
                x: (1 - rate) * self.size.width,
                y: 0,
                width: toFitSize.width,
                height: toFitSize.height
            )

            cxt?.draw(from, in: fromRect)
            cxt?.draw(to!, in: toRect)

        // MARK: - pushUp
        case .pushUp:
            let fromRect = CGRect(
                x: 0,
                y: rate * self.size.height,
                width: fromFitSize.width,
                height: fromFitSize.height
            )

            let toRect = CGRect(
                x: 0,
                y: -(1 - rate) * self.size.height,
                width: toFitSize.width,
                height: toFitSize.height
            )

            cxt?.draw(from, in: fromRect)
            cxt?.draw(to!, in: toRect)

        // MARK: - pushDown
        case .pushDown:
            let fromRect = CGRect(
                x: 0,
                y: -rate * self.size.height,
                width: fromFitSize.width,
                height: fromFitSize.height
            )

            let toRect = CGRect(
                x: 0,
                y: (1 - rate) * self.size.height,
                width: toFitSize.width,
                height: toFitSize.height
            )

            cxt?.draw(from, in: fromRect)
            cxt?.draw(to!, in: toRect)

        case .screwing:
            let fromRect = CGRect(origin: .zero, size: fromFitSize)
            let toRect = CGRect(origin: .zero, size: toFitSize)
            let center = CGPoint(x: fromRect.midX, y: fromRect.midY)
            cxt?.draw(from, in: fromRect)
            cxt?.translateBy(x: center.x, y: center.y)
            cxt?.rotate(by: -(.pi * rotate))
            cxt?.draw(to!, in: toRect)
            rotate += 0.06
        }
    }

    fileprivate func createBuffer() -> CVPixelBuffer? {

        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]

        var pxBuffer: CVPixelBuffer?

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            options as CFDictionary?,
            &pxBuffer
        )

        let success = status == kCVReturnSuccess && pxBuffer != nil
        return success ? pxBuffer : nil
    }

    fileprivate func deletePreviousTmpVideo(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
