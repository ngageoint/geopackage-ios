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

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (NSArray *) columns{
    self = [self initWithTable:geometryColumns.tableName andGeometryColumn:geometryColumns.columnName andColumns:columns];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [self initWithTable:tableName andGeometryColumn:nil andColumns:columns];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns];
    if(self != nil){
        
        NSNumber *geometry = nil;
        
        // Find the geometry
        for(GPKGFeatureColumn *column in columns){
            
            BOOL isGeometryColumn = NO;
            
            if(geometryColumn != nil){
                isGeometryColumn = [geometryColumn caseInsensitiveCompare:column.name] == NSOrderedSame;
            }else{
                isGeometryColumn = [column isGeometry];
            }
            
            if(isGeometryColumn){
                geometry = [NSNumber numberWithInt:column.index];
                break;
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

-(NSArray<GPKGFeatureColumn *> *) featureColumns{
    return (NSArray<GPKGFeatureColumn *> *) [super columns];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGFeatureTable *featureTable = [super mutableCopyWithZone:zone];
    featureTable.geometryIndex = _geometryIndex;
    return featureTable;
}

@end
