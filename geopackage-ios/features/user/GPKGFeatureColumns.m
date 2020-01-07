//
//  GPKGFeatureColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureColumns.h"

@implementation GPKGFeatureColumns

-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andGeometryColumn:geometryColumn andColumns:columns andCustom:NO];
}

-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    self = [super initWithTable:tableName andColumns:columns andCustom:custom];
    if(self != nil){
        _geometryIndex = -1;
        _geometryColumnName = geometryColumn;
        [self updateColumns];
    }
    return self;
}

-(instancetype) initWithFeatureColumns: (GPKGFeatureColumns *) featureColumns{
    self = [super initWithUserColumns:featureColumns];
    if(self != nil){
        _geometryColumnName = featureColumns.geometryColumnName;
        _geometryIndex = featureColumns.geometryIndex;
    }
    return self;
}

-(void) updateColumns{
    [super updateColumns];
    
    NSNumber *index = nil;
    
    if(self.geometryColumnName != nil){
        index = [self columnIndexWithColumnName:self.geometryColumnName andRequired:NO];
    }else{
        // Try to find the geometry
        for(GPKGFeatureColumn *column in [self columns]){
            if([column isGeometry]){
                index = [NSNumber numberWithInt:column.index];
                self.geometryColumnName = column.name;
                break;
            }
        }
    }
    
    if(!self.custom){
        [self missingCheckWithIndex:index andColumn:SF_GEOMETRY_NAME];
    }
    if(index != nil){
        self.geometryIndex = [index intValue];
    }
}

-(BOOL) hasGeometryColumn{
    return self.geometryIndex >= 0;
}

-(GPKGFeatureColumn *) geometryColumn{
    GPKGFeatureColumn *column = nil;
    if ([self hasGeometryColumn]) {
        column = (GPKGFeatureColumn *)[self columnWithIndex:self.geometryIndex];
    }
    return column;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGFeatureColumns *featureColumns = [super mutableCopyWithZone:zone];
    return featureColumns;
}

@end
