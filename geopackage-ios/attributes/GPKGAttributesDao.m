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

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGAttributesTable *) attributesTable{
    return (GPKGAttributesTable *) self.table;
}

-(GPKGAttributesRow *) attributesRow: (GPKGResultSet *) results{
    return (GPKGAttributesRow *) [super row:results];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGAttributesRow alloc] initWithAttributesTable:[self attributesTable] andColumns:(GPKGAttributesColumns *) columns andValues:values];
}

-(GPKGAttributesRow *) newRow{
    return [[GPKGAttributesRow alloc] initWithAttributesTable:(GPKGAttributesTable *)self.table];
}

-(GPKGBoundingBox *) boundingBox{
    [NSException raise:@"Not Supported" format:@"Bounding Box not supported for Attributes"];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    [NSException raise:@"Not Supported" format:@"Bounding Box not supported for Attributes"];
    return nil;
}

@end
