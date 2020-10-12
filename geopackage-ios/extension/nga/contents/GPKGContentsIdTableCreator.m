//
//  GPKGContentsIdTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGContentsIdTableCreator.h"
#import "GPKGContentsId.h"

@implementation GPKGContentsIdTableCreator

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    return self;
}

-(int) createContentsId{
    return [self createTable:GPKG_CI_TABLE_NAME];
}

@end
