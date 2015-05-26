//
//  GPKGFeatureTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTable.h"

@implementation GPKGFeatureTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns];
    if(self != nil){
        
        NSNumber *geometry = nil;
        
        // Find the geometry
        for(GPKGFeatureColumn *column in columns){
            if([column isGeometry]){
                [self duplicateCheckWithIndex:column.index andPreviousIndex:geometry andColumn:WKB_GEOMETRY_NAME];
                geometry = [NSNumber numberWithInt:column.index];
            }
        }
        
        [self missingCheckWithIndex:geometry andColumn:WKB_GEOMETRY_NAME];
        self.geometryIndex = [geometry intValue];
    }
    return self;
}

-(GPKGFeatureColumn *) getGeometryColumn{
    return (GPKGFeatureColumn *) [self getColumnWithIndex:self.geometryIndex];
}

@end
