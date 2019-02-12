//
//  GPKGStyleDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleDao.h"

@implementation GPKGStyleDao

-(instancetype) initWithDao: (GPKGAttributesDao *) dao{
    self = [self initWithDatabase:dao.database andTable:[[GPKGStyleTable alloc] initWithTable:[dao getAttributesTable]]];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGStyleTable *) table{
    return (GPKGStyleTable *)[super table];
}

-(GPKGStyleRow *) row: (GPKGResultSet *) results{
    return (GPKGStyleRow *) [self getRow:results];
}

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGStyleRow alloc] initWithStyleTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGStyleRow *) newRow{
    return [[GPKGStyleRow alloc] initWithStyleTable:[self table]];
}

-(GPKGStyleRow *) queryForRow: (GPKGStyleMappingRow *) styleMappingRow{
    return (GPKGStyleRow *)[self queryForIdObject:[NSNumber numberWithInt:[styleMappingRow relatedId]]];
}

@end
