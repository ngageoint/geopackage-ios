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
    self = [self initWithDatabase:dao.database andTable:[[GPKGStyleTable alloc] initWithTable:[dao attributesTable]]];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGStyleTable *) styleTable{
    return (GPKGStyleTable *)[super attributesTable];
}

-(GPKGStyleRow *) row: (GPKGResultSet *) results{
    return (GPKGStyleRow *) [super row:results];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGStyleRow alloc] initWithStyleTable:[self styleTable] andColumns:(GPKGAttributesColumns *) columns andValues:values];
}

-(GPKGStyleRow *) newRow{
    return [[GPKGStyleRow alloc] initWithStyleTable:[self styleTable]];
}

-(GPKGStyleRow *) queryForRow: (GPKGStyleMappingRow *) styleMappingRow{
    return (GPKGStyleRow *)[self queryForIdObject:[NSNumber numberWithInt:[styleMappingRow relatedId]]];
}

@end
