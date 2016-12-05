//
//  GPKGAttributesRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesRow.h"

@implementation GPKGAttributesRow

-(instancetype) initWithAttributesTable: (GPKGAttributesTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    if(self != nil){
        self.attributesTable = table;
    }
    return self;
}

-(instancetype) initWithAttributesTable: (GPKGAttributesTable *) table{
    self = [super initWithTable:table];
    if(self != nil){
        self.attributesTable = table;
    }
    return self;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

@end
