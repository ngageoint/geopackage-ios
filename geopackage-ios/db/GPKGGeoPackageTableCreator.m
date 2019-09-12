//
//  GPKGGeoPackageTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/25/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageTableCreator.h"
#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"
#import "GPKGGeometryColumns.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileMatrix.h"
#import "GPKGDataColumns.h"
#import "GPKGDataColumnConstraints.h"
#import "GPKGMetadata.h"
#import "GPKGMetadataReference.h"
#import "GPKGExtensions.h"
#import "GPKGTableIndex.h"
#import "GPKGGeometryIndex.h"
#import "GPKGFeatureTileLink.h"
#import "GPKGGriddedCoverage.h"
#import "GPKGGriddedTile.h"
#import "GPKGTileScaling.h"
#import "GPKGExtendedRelation.h"
#import "GPKGSqlUtils.h"
#import "GPKGContentsId.h"

@implementation GPKGGeoPackageTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db{
    self = [super initWithDatabase:db];
    return self;
}

-(int) createSpatialReferenceSystem{
    return [self createTable:GPKG_SRS_TABLE_NAME];
}

-(int) createContents{
    return [self createTable:GPKG_CON_TABLE_NAME];
}

-(int) createGeometryColumns{
    return [self createTable:GPKG_GC_TABLE_NAME];
}

-(int) createTileMatrixSet{
    return [self createTable:GPKG_TMS_TABLE_NAME];
}

-(int) createTileMatrix{
    return [self createTable:GPKG_TM_TABLE_NAME];
}

-(int) createDataColumns{
    return [self createTable:GPKG_DC_TABLE_NAME];
}

-(int) createDataColumnConstraints{
    return [self createTable:GPKG_DCC_TABLE_NAME];
}

-(int) createMetadata{
    return [self createTable:GPKG_M_TABLE_NAME];
}

-(int) createMetadataReference{
    return [self createTable:GPKG_MR_TABLE_NAME];
}

-(int) createExtensions{
    return [self createTable:GPKG_EX_TABLE_NAME];
}

-(int) createGriddedCoverage{
    return [self createTable:GPKG_CDGC_TABLE_NAME];
}

-(int) createGriddedTile{
    return [self createTable:GPKG_CDGT_TABLE_NAME];
}

-(int) createExtendedRelations{
    return [self createTable:GPKG_ER_TABLE_NAME];
}

-(int) createTableIndex{
    return [self createTable:GPKG_TI_TABLE_NAME];
}

-(int) createGeometryIndex{
    return [self createTable:GPKG_GI_TABLE_NAME];
}

-(int) indexGeometryIndex{
    return [self execSQLScript:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_index"]];
}

-(int) unindexGeometryIndex{
    return [self execSQLScript:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_unindex"]];
}

-(int) createFeatureTileLink{
    return [self createTable:GPKG_FTL_TABLE_NAME];
}

-(int) createTileScaling{
    return [self createTable:GPKG_TS_TABLE_NAME];
}

-(int) createContentsId{
    return [self createTable:GPKG_CI_TABLE_NAME];
}

-(int) createTable: (NSString *) tableName{
    
    NSArray<NSString *> *statements = [GPKGTableCreator readSQLScript:tableName];
    
    for(NSString * statement in statements){
        [self.db exec:statement];
    }
    
    return (int)[statements count];
}

-(void) createUserTable: (GPKGUserTable *) table{
    
    // Verify the table does not already exist
    if([self.db tableExists:table.tableName]){
        [NSException raise:@"Table Creation" format:@"Table already exists and can not be created: %@", table.tableName];
    }
    
    // Build the create table sql
    NSString *sql = [GPKGSqlUtils createTableSQL:table];
    
    // Create the table
    [self.db exec:sql];
}

-(void) createRequired{
    
    // Create the Spatial Reference System table (spec Requirement 10)
    [self createSpatialReferenceSystem];
    
    // Create the Contents table (spec Requirement 13)
    [self createContents];
    
    // Create the required Spatial Reference Systems (spec Requirement
    // 11)
    GPKGSpatialReferenceSystemDao * dao =[[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.db];
    [dao createWgs84];
    [dao createUndefinedCartesian];
    [dao createUndefinedGeographic];
    
}

-(void) dropTable: (NSString *) table{
    [GPKGSqlUtils dropTable:table withConnection:self.db];
}

@end
