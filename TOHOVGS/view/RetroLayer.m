/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "RetroLayer.h"
#import "../vgs/compat/vge.h"

#define VRAM_WIDTH 240
#define VRAM_HEIGHT 320

unsigned short display[VRAM_WIDTH * VRAM_HEIGHT];

@interface RetroLayer ()
@property (atomic) CGContextRef img;
@property (atomic) BOOL destroyed;
@end

@implementation RetroLayer

+ (id)defaultActionForKey:(NSString*)key
{
    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        _destroyed = NO;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _img = CGBitmapContextCreate(display,
                                     VRAM_WIDTH,
                                     VRAM_HEIGHT,
                                     5,
                                     VRAM_WIDTH * 2,
                                     colorSpace,
                                     kCGImageAlphaNoneSkipFirst |
                                     kCGBitmapByteOrder16Little);
        CFRelease(colorSpace);
    }
    return self;
}

- (void)drawFrame
{
    if (_destroyed) {
        return;
    }
    memset(_vram.sp, 0, sizeof(_vram.sp));
    vge_tick();
    for (int i = 0; i < XSIZE * YSIZE; i++) {
        display[i] = _vram.pal[_vram.sp[i]];
    }
    CGImageRef cgImage = CGBitmapContextCreateImage(_img);
    self.contents = (__bridge id)cgImage;
    CFRelease(cgImage);
}

- (void)destroy
{
    if (!_destroyed) {
        _destroyed = YES;
        CGContextRelease(_img);
        _img = nil;
    }
}

- (void)dealloc
{
    [self destroy];
}

@end
