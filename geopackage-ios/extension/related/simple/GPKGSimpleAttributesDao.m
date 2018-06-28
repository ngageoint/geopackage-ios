//
//  GPKGSimpleAttributesDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGSimpleAttributesDao.h"

@implementation GPKGSimpleAttributesDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [super initWithDao:dao andTable:[[GPKGSimpleAttributesTable alloc] initWithTable:[dao table]]];
    return self;
}

-(GPKGSimpleAttributesTable *) table{
    return (GPKGSimpleAttributesTable *)[super table];
}

-(GPKGSimpleAttributesRow *) row: (GPKGResultSet *) results{
    return (GPKGSimpleAttributesRow *) [self getRow:results];
}

-(GPKGSimpleAttributesRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGSimpleAttributesRow alloc] initWithSimpleAttributesTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGSimpleAttributesRow *) newRow{
    return [[GPKGSimpleAttributesRow alloc] initWithSimpleAttributesTable:[self table]];
}

-(GPKGSimpleAttributesRow *) rowFromUserCustomRow: (GPKGUserCustomRow *) row{
    return [[GPKGSimpleAttributesRow alloc] initWithUserCustomRow:row];
}

-(NSArray<GPKGSimpleAttributesRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids{
    NSMutableArray<GPKGSimpleAttributesRow *> *simpleAttributesRows = [[NSMutableArray alloc] init];
    for(NSNumber *id in ids){
        GPKGUserCustomRow *userCustomRow = (GPKGUserCustomRow *)[self queryForIdObject:id];
        if(userCustomRow != nil){
            [simpleAttributesRows addObject:[self rowFromUserCustomRow:userCustomRow]];
        }
    }
    return simpleAttributesRows;
}

@end
