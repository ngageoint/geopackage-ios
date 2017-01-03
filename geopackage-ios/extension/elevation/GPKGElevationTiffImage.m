//
//  GPKGElevationTiffImage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGElevationTiffImage.h"
#import "GPKGElevationTilesTiff.h"

@interface GPKGElevationTiffImage ()

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic, strong) NSData * imageData;
// TODO
//@property (nonatomic, strong) TIFFFileDirectory * directory;
//@property (nonatomic, strong) TIFFRasters * rasters;

@end

@implementation GPKGElevationTiffImage

-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow{
    self = [super init];
    if(self != nil){
        self.imageData = [tileRow getTileData];
// TODO
//        TIFFImage * tiffImage = [TIFFReader readTiff:self.imageData];
//        self.directory = [tiffImage fileDirectory];
//        [GPKGElevationTilesTiff validateImageType:self.image];
//        self.width = [[directory imageWidth] intValue];
//        self.height = [[directory imageHeight] intValue];
    }
    return self;
}

// TODO
/*-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) directory{
    self = [super init];
    if(self != nil){
        self.directory = directory;
        self.rasters = [directory writeRasters];
        [GPKGElevationTilesTiff validateImageType:self.image];
        self.width = [[directory imageWidth] intValue];
        self.height = [[directory imageHeight] intValue];
    }
    return self;
}*/

-(NSData *) imageData{
    if(_imageData == nil){
        [self writeTiff];
    }
    return _imageData;
}

// TODO
/*-(TIFFFileDirectory *) directory{
    return _directory;
}*/

// TODO
/*-(TIFFRasters *) rasters{
    if(_rasters == nil){
        [self readPixels];
    }
    return rasters;
}*/

-(int) width{
    return _width;
}

-(int) height{
    return _height;
}

-(void) writeTiff{
    // TODO
}

-(float) pixelAtX: (int) x andY: (int) y{
    // TODO
    return 0;
}

-(void) readPixels{
    // TODO
}

@end
