//
//  GPKGGeoPackageTile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTile.h"

@implementation GPKGGeoPackageTile

-(instancetype) initWithWidth: (int) width andHeight: (int) height andData: (NSData *) tileData{
    self = [super init];
    if(self != nil){
        self.width = width;
        self.height = height;
        self.data = tileData;
    }
    return self;
}

@end
