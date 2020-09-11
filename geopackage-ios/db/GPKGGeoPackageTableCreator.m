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

-(int) createExtensions{
    return [self createTable:GPKG_EX_TABLE_NAME];
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

-(int) createGriddedCoverage{
    return [self createTable:GPKG_CDGC_TABLE_NAME];
}

-(int) createGriddedTile{
    return [self createTable:GPKG_CDGT_TABLE_NAME];
}

-(int) createExtendedRelations{
    return [self createTable:GPKG_ER_TABLE_NAME];
}

-(int) createTable: (NSString *) tableName{
    
    NSArray<NSString *> *statements = [GPKGTableCreator readSQLScript:tableName];
    
    for(NSString * statement in statements){
        [self.db execResettable:statement];
    }
    
    return (int)[statements count];
}

-(void) createUserTable: (GPKGUserTable *) table{
    
    // Verify the table does not already exist
    if([self.db tableOrViewExists:table.tableName]){
        [NSException raise:@"Table Creation" format:@"Table or view already exists and can not be created: %@", table.tableName];
    }
    
    // Build the create table sql
    NSString *sql = [GPKGSqlUtils createTableSQL:table];
    
    // Create the table
    [self.db execResettable:sql];
}

-(void) createRequired{
    
    // Create the Spatial Reference System table (spec Requirement 10)
    [self createSpatialReferenceSystem];
    
    // Create the Contents table (spec Requirement 13)
    [self createContents];
    
    // Create the required Spatial Reference Systems (spec Requirement
    // 11)
    GPKGSpatialReferenceSystemDao *dao = [GPKGSpatialReferenceSystemDao createDao:self.db];
    GPKGSpatialReferenceSystemDao * dao = [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.db];
    [dao createWgs84];
    [dao createUndefinedCartesian];
    [dao createUndefinedGeographic];
    
}

-(void) dropTable: (NSString *) table{
    [GPKGSqlUtils dropTable:table withConnection:self.db];
}

-(void) dropView: (NSString *) view{
    [GPKGSqlUtils dropView:view withConnection:self.db];
}

@end
