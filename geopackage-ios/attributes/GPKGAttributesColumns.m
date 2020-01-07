//
//  GPKGAttributesColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGAttributesColumns.h"

@implementation GPKGAttributesColumns

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andColumns:columns andCustom:NO];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    self = [super initWithTable:tableName andColumns:columns andCustom:custom];
    if(self != nil){
        [self updateColumns];
    }
    return self;
}

-(instancetype) initWithAttributesColumns: (GPKGAttributesColumns *) attributesColumns{
    self = [super initWithUserColumns:attributesColumns];
    return self;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGAttributesColumns *attributesColumns = [super mutableCopyWithZone:zone];
    return attributesColumns;
}

@end
