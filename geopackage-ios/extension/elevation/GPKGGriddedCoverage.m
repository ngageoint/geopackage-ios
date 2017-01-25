//
//  GPKGGriddedCoverage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGriddedCoverage.h"

NSString * const GPKG_EGC_TABLE_NAME = @"gpkg_2d_gridded_coverage_ancillary";
NSString * const GPKG_EGC_COLUMN_PK = @"id";
NSString * const GPKG_EGC_COLUMN_ID = @"id";
NSString * const GPKG_EGC_COLUMN_TILE_MATRIX_SET_NAME = @"tile_matrix_set_name";
NSString * const GPKG_EGC_COLUMN_DATATYPE = @"datatype";
NSString * const GPKG_EGC_COLUMN_SCALE = @"scale";
NSString * const GPKG_EGC_COLUMN_OFFSET = @"offset";
NSString * const GPKG_EGC_COLUMN_PRECISION = @"precision";
NSString * const GPKG_EGC_COLUMN_DATA_NULL = @"data_null";

@implementation GPKGGriddedCoverage

-(void) setTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    if(tileMatrixSet != nil){
        self.tileMatrixSetName = tileMatrixSet.tableName;
    }else{
        self.tileMatrixSetName = nil;
    }
}

-(enum GPKGGriddedCoverageDataType) getGriddedCoverageDataType{
    enum GPKGGriddedCoverageDataType value = -1;
    
    if(self.datatype != nil){
        value = [GPKGGriddedCoverageDataTypes fromName:self.datatype];
    }
    
    return value;
}

-(void) setGriddedCoverageDataType: (enum GPKGGriddedCoverageDataType) dataType{
    self.datatype = [GPKGGriddedCoverageDataTypes name:dataType];
}

-(double) getScaleOrDefault{
    return self.scale != nil ? [self.scale doubleValue] : 1.0;
}

-(double) getOffsetOrDefault{
    return self.offset != nil ? [self.offset doubleValue] : 0.0;
}

-(double) getPrecisionOrDefault{
    return self.precision != nil ? [self.precision doubleValue] : 1.0;
}

@end
