//
//  GPKGIconDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIconDao.h"

@implementation GPKGIconDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [self initWithDao:dao andTable:[[GPKGIconTable alloc] initWithTable:[dao table]]];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGIconTable *) table{
    return (GPKGIconTable *)[super table];
}

-(GPKGIconRow *) row: (GPKGResultSet *) results{
    return (GPKGIconRow *) [self getRow:results];
}

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGIconRow alloc] initWithIconTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGIconRow *) newRow{
    return [[GPKGIconRow alloc] initWithIconTable:[self table]];
}

-(NSArray<GPKGIconRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids{
    NSMutableArray<GPKGIconRow *> *iconRows = [[NSMutableArray alloc] init];
    for(NSNumber *id in ids){
        GPKGIconRow *row = (GPKGIconRow *)[self queryForIdObject:id];
        if(row != nil){
            [iconRows addObject:row];
        }
    }
    return iconRows;
}

-(GPKGIconRow *) queryForRow: (GPKGStyleMappingRow *) styleMappingRow{
    return (GPKGIconRow *)[self queryForIdObject:[NSNumber numberWithInt:[styleMappingRow relatedId]]];
}

@end
