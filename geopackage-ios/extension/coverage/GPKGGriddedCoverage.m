//
//  GPKGGriddedCoverage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGriddedCoverage.h"

NSString * const GPKG_CDGC_TABLE_NAME = @"gpkg_2d_gridded_coverage_ancillary";
NSString * const GPKG_CDGC_COLUMN_PK = @"id";
NSString * const GPKG_CDGC_COLUMN_ID = @"id";
NSString * const GPKG_CDGC_COLUMN_TILE_MATRIX_SET_NAME = @"tile_matrix_set_name";
NSString * const GPKG_CDGC_COLUMN_DATATYPE = @"datatype";
NSString * const GPKG_CDGC_COLUMN_SCALE = @"scale";
NSString * const GPKG_CDGC_COLUMN_OFFSET = @"offset";
NSString * const GPKG_CDGC_COLUMN_PRECISION = @"precision";
NSString * const GPKG_CDGC_COLUMN_DATA_NULL = @"data_null";
NSString * const GPKG_CDGC_COLUMN_GRID_CELL_ENCODING = @"grid_cell_encoding";
NSString * const GPKG_CDGC_COLUMN_UOM = @"uom";
NSString * const GPKG_CDGC_COLUMN_FIELD_NAME = @"field_name";
NSString * const GPKG_CDGC_COLUMN_QUANTITY_DEFINITION = @"quantity_definition";

@implementation GPKGGriddedCoverage

-(void) setTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    if(tileMatrixSet != nil){
        self.tileMatrixSetName = tileMatrixSet.tableName;
    }else{
        self.tileMatrixSetName = nil;
    }
}

-(enum GPKGGriddedCoverageDataType) griddedCoverageDataType{
    enum GPKGGriddedCoverageDataType value = -1;
    
    if(self.datatype != nil){
        value = [GPKGGriddedCoverageDataTypes fromName:self.datatype];
    }
    
    return value;
}

-(void) setGriddedCoverageDataType: (enum GPKGGriddedCoverageDataType) dataType{
    self.datatype = [GPKGGriddedCoverageDataTypes name:dataType];
}

-(double) scaleOrDefault{
    return self.scale != nil ? [self.scale doubleValue] : 1.0;
}

-(double) offsetOrDefault{
    return self.offset != nil ? [self.offset doubleValue] : 0.0;
}

-(double) precisionOrDefault{
    return self.precision != nil ? [self.precision doubleValue] : 1.0;
}

-(enum GPKGGriddedCoverageEncodingType) gridCellEncodingType{
    enum GPKGGriddedCoverageEncodingType value = -1;
    
    if(self.gridCellEncoding != nil){
        value = [GPKGGriddedCoverageEncodingTypes fromName:self.gridCellEncoding];
    }
    
    return value;
}

-(void) setGridCellEncodingType: (enum GPKGGriddedCoverageEncodingType) encodingType{
    self.gridCellEncoding = [GPKGGriddedCoverageEncodingTypes name:encodingType];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGGriddedCoverage *griddedCoverage = [[GPKGGriddedCoverage alloc] init];
    griddedCoverage.id = _id;
    griddedCoverage.tileMatrixSetName = _tileMatrixSetName;
    griddedCoverage.datatype = _datatype;
    griddedCoverage.scale = _scale;
    griddedCoverage.offset = _offset;
    griddedCoverage.precision = _precision;
    griddedCoverage.dataNull = _dataNull;
    griddedCoverage.gridCellEncoding = _gridCellEncoding;
    griddedCoverage.uom = _uom;
    griddedCoverage.fieldName = _fieldName;
    griddedCoverage.quantityDefinition = _quantityDefinition;
    
    return griddedCoverage;
}

@end
