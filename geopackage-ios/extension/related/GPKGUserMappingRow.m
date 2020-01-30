//
//  GPKGUserMappingRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserMappingRow.h"

@implementation GPKGUserMappingRow

-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
    return self;
}

-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(GPKGUserMappingTable *) userMappingTable{
    return (GPKGUserMappingTable *) [super userCustomTable];
}

-(int) baseIdColumnIndex{
    return [[self userMappingTable] baseIdColumnIndex];
}

-(GPKGUserCustomColumn *) baseIdColumn{
    return [[self userMappingTable] baseIdColumn];
}

-(int) baseId{
    return [(NSNumber *)[self valueWithIndex:[self baseIdColumnIndex]] intValue];
}

-(void) setBaseId: (int) baseId{
    [self setValueWithIndex:[self baseIdColumnIndex] andValue:[NSNumber numberWithInt:baseId]];
}

-(int) relatedIdColumnIndex{
    return [[self userMappingTable] relatedIdColumnIndex];
}

-(GPKGUserCustomColumn *) relatedIdColumn{
    return [[self userMappingTable] relatedIdColumn];
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
