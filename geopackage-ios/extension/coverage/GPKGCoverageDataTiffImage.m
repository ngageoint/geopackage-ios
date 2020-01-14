//
//  GPKGCoverageDataTiffImage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGCoverageDataTiffImage.h"
#import "GPKGCoverageDataTiff.h"
#import "TIFFRasters.h"
#import "TIFFReader.h"
#import "TIFFWriter.h"

@interface GPKGCoverageDataTiffImage ()

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) TIFFImage * image;
@property (nonatomic, strong) TIFFFileDirectory * directory;
@property (nonatomic, strong) TIFFRasters * rasters;

@end

@implementation GPKGCoverageDataTiffImage

-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow{
    self = [super init];
    if(self != nil){
        self.imageData = [tileRow tileData];
        self.image = [TIFFReader readTiffFromData:self.imageData];
        self.directory = [self.image fileDirectory];
        [GPKGCoverageDataTiff validateImageType:self.directory];
        self.width = [[self.directory imageWidth] intValue];
        self.height = [[self.directory imageHeight] intValue];
    }
    return self;
}

-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) directory{
    self = [super init];
    if(self != nil){
        self.directory = directory;
        self.rasters = [directory writeRasters];
        [GPKGCoverageDataTiff validateImageType:self.directory];
        self.width = [[directory imageWidth] intValue];
        self.height = [[directory imageHeight] intValue];
    }
    return self;
}

-(NSData *) imageData{
    if(_imageData == nil){
        [self writeTiff];
    }
    return _imageData;
}

-(TIFFFileDirectory *) directory{
    return _directory;
}

-(TIFFRasters *) rasters{
    if(_rasters == nil){
        [self readPixels];
    }
    return _rasters;
}

-(int) width{
    return _width;
}

-(int) height{
    return _height;
}

-(void) writeTiff{
    if ([self.directory writeRasters] != nil) {
        TIFFImage * tiffImage = [[TIFFImage alloc] init];
        [tiffImage addFileDirectory:self.directory];
        self.imageData = [TIFFWriter writeTiffToDataWithImage:tiffImage];
    }
}

-(float) pixelAtX: (int) x andY: (int) y{
    float pixel = -1;
    if (self.rasters == nil) {
        [self readPixels];
    }
    if (self.rasters != nil) {
        pixel = [[self.rasters firstPixelSampleAtX:x andY:y] floatValue];
    } else {
        [NSException raise:@"Pixel Value" format:@"Could not retrieve pixel value"];
    }
    return pixel;
}

-(void) readPixels{
    if (self.directory != nil) {
        self.rasters = [self.directory readRasters];
    }
}

@end
