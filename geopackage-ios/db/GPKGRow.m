//
//  GPKGRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/17/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGRow.h"
#import "GPKGUtils.h"

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

-(int) count{
    return (int) _values.count;
}

-(NSString *) columnAtIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:_columns];
}

-(NSObject *) valueAtIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:_values];
}

-(NSObject *) valueWithColumn: (NSString *) column{
    NSObject *value = nil;
    NSUInteger index = [_columns indexOfObject:column];
    if(index != NSNotFound){
        value = [self valueAtIndex:(int)index];
    }
    return value;
}

@end
