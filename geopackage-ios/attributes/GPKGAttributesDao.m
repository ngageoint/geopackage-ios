//
//  GPKGAttributesDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesDao.h"

@implementation GPKGAttributesDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGAttributesTable *) table{
    self = [super initWithDatabase:database andTable:table];
    if(self != nil){
        if (table.contents == nil) {
            [NSException raise:@"Not Supported" format:@"Attributes Table %@ has null Contents", table.tableName];
        }
    }
    return self;
}

-(GPKGAttributesRow *) newRow{
    return [[GPKGAttributesRow alloc] initWithAttributesTable:(GPKGAttributesTable *)self.table];
}

-(GPKGBoundingBox *) getBoundingBox{
    [NSException raise:@"Not Supported" format:@"Bounding Box not supported for Attributes"];
    return nil;
}

@end
