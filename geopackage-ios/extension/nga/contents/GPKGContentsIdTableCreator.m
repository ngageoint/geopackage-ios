//
//  GPKGContentsIdTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGContentsIdTableCreator.h"

@implementation GPKGContentsIdTableCreator

-(int) createContentsId{
    return [self createTable:GPKG_CI_TABLE_NAME];
}

@end
