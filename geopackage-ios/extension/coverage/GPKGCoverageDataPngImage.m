//
//  GPKGCoverageDataPngImage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngImage.h"
#import "GPKGCoverageDataPng.h"

@interface GPKGCoverageDataPngImage ()

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic)  BOOL pixelsRead;
@property (nonatomic) unsigned short *pixels;

@end

@implementation GPKGCoverageDataPngImage

-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow{
    self = [super init];
    if(self != nil){
        self.imageData = [tileRow tileData];
        self.image = [tileRow tileDataImage];
        [GPKGCoverageDataPng validateImageType:self.image];
        self.pixelsRead = NO;
        self.width = self.image.size.width;
        self.height = self.image.size.height;
    }
    return self;
}

-(UIImage *) image{
    return _image;
}

-(NSData *) imageData{
    return _imageData;
}

-(int) width{
    return _width;
}

-(int) height{
    return _height;
}

-(unsigned short) pixelAtX: (int) x andY: (int) y{
    unsigned short pixel = -1;
    if(!self.pixelsRead){
        [self readPixels];
    }
    if(self.pixelsRead){
        pixel = self.pixels[(y * [self width]) + x];
    }else{
        [NSException raise:@"Pixel Read" format:@"Could not retrieve pixel value"];
    }
    return pixel;
}

-(void) readPixels{
    
    CGImageRef tileImageRef = [self.image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    self.pixels = calloc(self.width * self.height, sizeof(unsigned short));
    CGContextRef context = CGBitmapContextCreate(self.pixels, self.width, self.height, 16, 2 * self.width, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrder16Host);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, self.width, self.height), tileImageRef);
    CGContextRelease(context);
    
    self.pixelsRead = YES;
}

@end
