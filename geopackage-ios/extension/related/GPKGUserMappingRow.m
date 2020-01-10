//
//  GPKGUserMappingRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserMappingRow.h"

@implementation GPKGUserMappingRow

-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    return self;
}

-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(GPKGUserMappingTable *) table{
    return (GPKGUserMappingTable *) [super table];
}

-(int) baseIdColumnIndex{
    return [[self table] baseIdColumnIndex];
}

-(GPKGUserCustomColumn *) baseIdColumn{
    return [[self table] baseIdColumn];
}

-(int) baseId{
    return [(NSNumber *)[self valueWithIndex:[self baseIdColumnIndex]] intValue];
}

-(void) setBaseId: (int) baseId{
    [self setValueWithIndex:[self baseIdColumnIndex] andValue:[NSNumber numberWithInt:baseId]];
}

-(int) relatedIdColumnIndex{
    return [[self table] relatedIdColumnIndex];
}

-(GPKGUserCustomColumn *) relatedIdColumn{
    return [[self table] relatedIdColumn];
}

-(int) relatedId{
    return [(NSNumber *)[self valueWithIndex:[self relatedIdColumnIndex]] intValue];
}

-(void) setRelatedId: (int) relatedId{
    [self setValueWithIndex:[self relatedIdColumnIndex] andValue:[NSNumber numberWithInt:relatedId]];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserMappingRow *userMappingRow = [super mutableCopyWithZone:zone];
    return userMappingRow;
}

@end
