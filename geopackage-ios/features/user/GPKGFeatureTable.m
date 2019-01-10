//
//  GPKGFeatureTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTable.h"
#import "GPKGContentsDataTypes.h"

@implementation GPKGFeatureTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns];
    if(self != nil){
        
        NSNumber *geometry = nil;
        
        // Find the geometry
        for(GPKGFeatureColumn *column in columns){
            if([column isGeometry]){
                [self duplicateCheckWithIndex:column.index andPreviousIndex:geometry andColumn:SF_GEOMETRY_NAME];
                geometry = [NSNumber numberWithInt:column.index];
            }
        }
        
        [self missingCheckWithIndex:geometry andColumn:SF_GEOMETRY_NAME];
        self.geometryIndex = [geometry intValue];
    }
    return self;
}

-(NSString *) dataType{
    return GPKG_CDT_FEATURES_NAME;
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have a features data type
    enum GPKGContentsDataType dataType = [contents getContentsDataType];
    if (dataType != GPKG_CDT_FEATURES) {
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of a Feature Table must have a data type of %@", GPKG_CDT_FEATURES_NAME];
    }
}

-(GPKGFeatureColumn *) getGeometryColumn{
    return (GPKGFeatureColumn *) [self getColumnWithIndex:self.geometryIndex];
}

@end
