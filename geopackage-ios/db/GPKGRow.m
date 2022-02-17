//
//  GPKGRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/17/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGRow.h"

@implementation GPKGRow

+(GPKGRow *) create{
    return [[GPKGRow alloc] init];
}

+(GPKGRow *) createWithValues: (NSArray<NSObject *> *) values{
    return [[GPKGRow alloc] initWithValues:values];
}

+(GPKGRow *) createWithColumns: (NSArray<NSString *> *) columns andValues: (NSArray<NSObject *> *) values{
    return [[GPKGRow alloc] initWithColumns:columns andValues:values];
}

-(instancetype) init{
    self = [self initWithValues:nil];
    return self;
}

-(instancetype) initWithValues: (NSArray<NSObject *> *) values{
    self = [self initWithColumns:nil andValues:values];
    return self;
}

-(instancetype) initWithColumns: (NSArray<NSString *> *) columns andValues: (NSArray<NSObject *> *) values{
    self = [super init];
    if(self != nil){
        _columns = [NSMutableArray arrayWithArray:columns];
        _values = [NSMutableArray arrayWithArray:values];
    }
    return self;
}

-(int) columnCount{
    return (int) _columns.count;
}

-(NSObject *) columnAtIndex: (int) index{
    return [_columns objectAtIndex:index];
}

-(NSObject *) valueAtIndex: (int) index{
    return [_values objectAtIndex:index];
}

@end
