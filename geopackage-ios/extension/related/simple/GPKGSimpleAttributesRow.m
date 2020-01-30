//
//  GPKGSimpleAttributesRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGSimpleAttributesRow.h"

@implementation GPKGSimpleAttributesRow

-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
    return self;
}

-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(GPKGSimpleAttributesTable *) simpleAttributesTable{
    return (GPKGSimpleAttributesTable *) [super userCustomTable];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGSimpleAttributesRow *simpleAttributesRow = [super mutableCopyWithZone:zone];
    return simpleAttributesRow;
}

@end
