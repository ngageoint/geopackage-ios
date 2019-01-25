//
//  GPKGMediaDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGMediaDao.h"

@implementation GPKGMediaDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [self initWithDao:dao andTable:[[GPKGMediaTable alloc] initWithTable:[dao table]]];
    return self;
}

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGMediaTable *) mediaTable{
    self = [super initWithDao:dao andTable:mediaTable];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGMediaTable *) table{
    return (GPKGMediaTable *)[super table];
}

-(GPKGMediaRow *) row: (GPKGResultSet *) results{
    return (GPKGMediaRow *) [self getRow:results];
}

-(GPKGMediaRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGMediaRow alloc] initWithMediaTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGMediaRow *) newRow{
    return [[GPKGMediaRow alloc] initWithMediaTable:[self table]];
}

-(NSArray<GPKGMediaRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids{
    NSMutableArray<GPKGMediaRow *> *mediaRows = [[NSMutableArray alloc] init];
    for(NSNumber *id in ids){
        GPKGMediaRow *row = (GPKGMediaRow *)[self queryForIdObject:id];
        if(row != nil){
            [mediaRows addObject:row];
        }
    }
    return mediaRows;
}

@end
