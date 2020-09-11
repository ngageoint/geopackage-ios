//
//  GPKGTileScalingTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileScalingTableCreator.h"

@implementation GPKGTileScalingTableCreator

// TODO

-(int) createTileScaling{
    return [self createTable:GPKG_TS_TABLE_NAME];
}

@end
