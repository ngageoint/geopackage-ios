//
//  GPKGFeatureTileLinkTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureTileLinkTableCreator.h"

@implementation GPKGFeatureTileLinkTableCreator

// TODO

-(int) createFeatureTileLink{
    return [self createTable:GPKG_FTL_TABLE_NAME];
}

@end
