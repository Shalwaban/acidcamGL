// code is modified from github:

#include"screen.h"
#ifdef __APPLE__

NSImage *CaptureScreenRect(int x, int y, int w, int h) {
//    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSRect screenRect;
    screenRect.size.height=h;
    screenRect.size.width =w;
    screenRect.origin.x = x;
    screenRect.origin.y = y;
    CGImageRef cgImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:rep];
    return image;
}

NSImage *CaptureScreen() {
     NSRect screenRect = [[NSScreen mainScreen] frame];
    CGImageRef cgImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:rep];
    return image;
}

@implementation NSImage (NSImage_OpenCV)

-(CGImageRef)CGImage
{
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    return cgImage;
}


-(cv::Mat)CVMat
{
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return cvMat;
}

@end


void ScreenGrab(cv::Mat &frame) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImage *cap = CaptureScreen();
    frame = [cap CVMat];
    [cap release];
    [pool drain];
}

void ScreenGrabRect(int x, int y, int w, int h,
                    cv::Mat &frame) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImage *cap = CaptureScreenRect(x,y,w,h);
    frame = [cap CVMat];
    [cap release];
    [pool drain];
}

void convertTo(NSImage *image, cv::Mat &frame) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    frame = [image CVMat];
    
    [pool drain];
}

#endif

