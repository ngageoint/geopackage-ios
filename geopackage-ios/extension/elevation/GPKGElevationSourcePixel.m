//
//  GPKGElevationSourcePixel.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationSourcePixel.h"

@implementation GPKGElevationSourcePixel

-(instancetype) initWithPixel: (float) pixel andMin: (int) min andMax: (int) max andOffset: (float) offset{
    self = [super init];
    if(self != nil){
        self.pixel = pixel;
        self.min = min;
        self.max = max;
        self.offset = offset;
    }
    return self;
}

@end
