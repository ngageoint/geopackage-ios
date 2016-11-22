//
//  GPKGElevationImage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationImage.h"

@interface GPKGElevationImage ()

@property (nonatomic) UIImage * image;

@end

@implementation GPKGElevationImage

-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow{
    self = [super init];
    if(self != nil){
        self.image = tileRow.getTileDataImage;
    }
    return self;
}

-(UIImage *) image{
    return _image;
}

-(int) width{
    return self.image.size.width;
}

-(int) height{
    return self.image.size.height;
}

@end
