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
    self = [self initWithDao:dao andTable:[[GPKGSimpleAttributesTable alloc] initWithTable:[dao userCustomTable]]];
    return self;
}

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGSimpleAttributesTable *) simpleAttributesTable{
    self = [super initWithDao:dao andTable:simpleAttributesTable];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGSimpleAttributesTable *) simpleAttributesTable{
    return (GPKGSimpleAttributesTable *)[super userCustomTable];
}

-(GPKGSimpleAttributesRow *) row: (GPKGResultSet *) results{
    return (GPKGSimpleAttributesRow *) [super row:results];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGSimpleAttributesRow alloc] initWithSimpleAttributesTable:[self simpleAttributesTable] andColumns:columns andValues:values];
}

-(GPKGSimpleAttributesRow *) newRow{
    return [[GPKGSimpleAttributesRow alloc] initWithSimpleAttributesTable:[self simpleAttributesTable]];
}

-(NSArray<GPKGSimpleAttributesRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids{
    NSMutableArray<GPKGSimpleAttributesRow *> *simpleAttributesRows = [NSMutableArray array];
    for(NSNumber *id in ids){
        GPKGSimpleAttributesRow *row = (GPKGSimpleAttributesRow *)[self queryForIdObject:id];
        if(row != nil){
            [simpleAttributesRows addObject:row];
        }
    }
    return simpleAttributesRows;
}

@end
