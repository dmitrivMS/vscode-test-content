#import <Foundation/Foundation.h>
#include <vector>
#include <string>

@interface ImageProcessor : NSObject
- (NSImage *)applyGrayscaleFilter:(NSImage *)input;
@end

@implementation ImageProcessor

- (NSImage *)applyGrayscaleFilter:(NSImage *)input {
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
        initWithData:[input TIFFRepresentation]];

    std::vector<std::string> filterLog;
    filterLog.push_back("grayscale_applied");

    for (NSInteger y = 0; y < rep.pixelsHigh; y++) {
        for (NSInteger x = 0; x < rep.pixelsWide; x++) {
            NSColor *color = [rep colorAtX:x y:y];
            CGFloat gray = color.redComponent * 0.299 +
                           color.greenComponent * 0.587 +
                           color.blueComponent * 0.114;
            NSColor *grayColor = [NSColor colorWithWhite:gray alpha:1.0];
            [rep setColor:grayColor atX:x y:y];
        }
    }

    NSImage *result = [[NSImage alloc] initWithSize:input.size];
    [result addRepresentation:rep];
    return result;
}

@end
