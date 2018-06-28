//
//  GPKGSimpleAttributesRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGSimpleAttributesRow.h"

@implementation GPKGSimpleAttributesRow

-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    return self;
}

-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow{
    self = [super initWithUserCustomRow:userCustomRow];
    return self;
}

-(GPKGSimpleAttributesTable *) table{
    return (GPKGSimpleAttributesTable *) super.userCustomTable;
}

-(int) idColumnIndex{
    return [[self table] idColumnIndex];
}

-(GPKGUserCustomColumn *) idColumn{
    return [[self table] idColumn];
}

-(int) id{
    return [(NSNumber *)[self getValueWithIndex:[self idColumnIndex]] intValue];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGSimpleAttributesRow *simpleAttributesRow = [super mutableCopyWithZone:zone];
    return simpleAttributesRow;
}

@end
