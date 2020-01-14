//
//  GPKGTransactionTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTransactionTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGSQLiteMaster.h"

@implementation GPKGTransactionTestCase

/**
 * Test transactions on the User DAO
 */
- (void) testUserDao {

    int rows = 500;
    int chunkSize = 150;
    
    for (NSString *featureTable in [self.geoPackage featureTables]) {
        
        GPKGFeatureDao *featureDao = [self.geoPackage featureDaoWithTableName:featureTable];
        
        [self testUserDao:featureDao andRows:rows asSuccessful:NO];
        [self testUserDao:featureDao andRows:rows asSuccessful:YES];
        
        [self testUserDaoShortcuts:featureDao andRows:rows asSuccessful:NO];
        [self testUserDaoShortcuts:featureDao andRows:rows asSuccessful:YES];
        
        [self testUserDaoChunksWithDao:featureDao andRows:rows andChunkSize:chunkSize asSuccessful:NO];
        [self testUserDaoChunksWithDao:featureDao andRows:rows andChunkSize:chunkSize asSuccessful:YES];
        
    }

}

/**
 * Test transactions on the GeoPackage
 */
- (void) testGeoPackage {
    [self testGeoPackage:self.geoPackage asSuccessful:NO];
    [self testGeoPackage:self.geoPackage asSuccessful:YES];
}

/**
 * Test a transaction
 *
 * @param featureDao feature dao
 * @param rows       rows to insert
 * @param successful true for a successful transaction
 */
-(void) testUserDao: (GPKGFeatureDao *) featureDao andRows: (int) rows asSuccessful: (BOOL) successful{
    
    int countBefore = [featureDao count];
    
    GPKGConnection *db = featureDao.database;
    [db beginTransaction];
    [GPKGTestUtils assertTrue:[db inTransaction]];
    
    @try {
        
        [self insertRows:rows withDao:featureDao];
        
    } @catch (NSException *exception) {
        
        [db rollbackTransaction];
        [GPKGTestUtils fail:exception.reason];
        
    } @finally {
        
        [GPKGTestUtils assertTrue:[db inTransaction]];
        
        if(successful){
            [db commitTransaction];
        }else{
            [db rollbackTransaction];
        }
        
        [GPKGTestUtils assertFalse:[db inTransaction]];
        
    }
    
    [GPKGTestUtils assertEqualIntWithValue:successful ? countBefore + rows : countBefore andValue2:[featureDao count]];
    
}

/**
 * Test a transaction using shortcut methods
 *
 * @param featureDao feature dao
 * @param rows       rows to insert
 * @param successful true for a successful transaction
 */
-(void) testUserDaoShortcuts: (GPKGFeatureDao *) featureDao andRows: (int) rows asSuccessful: (BOOL) successful{
    
    int countBefore = [featureDao count];
    
    [featureDao beginTransaction];
    [GPKGTestUtils assertTrue:[featureDao inTransaction]];
    
    @try {
        
        [self insertRows:rows withDao:featureDao];
       
    } @catch (NSException *exception) {
        
        [featureDao rollbackTransaction];
        [GPKGTestUtils fail:exception.reason];
        
    } @finally {
        
        [GPKGTestUtils assertTrue:[featureDao inTransaction]];
        
        if(successful){
            [featureDao commitTransaction];
        }else{
            [featureDao rollbackTransaction];
        }
       
        [GPKGTestUtils assertFalse:[featureDao inTransaction]];
        
    }
    
    [GPKGTestUtils assertEqualIntWithValue:successful ? countBefore + rows : countBefore andValue2:[featureDao count]];
    
}

/**
 * Test a transaction with chunked inserts
 *
 * @param featureDao feature dao
 * @param rows       rows to insert
 * @param chunkSize  chunk size
 * @param successful true for a successful transaction
 */
-(void) testUserDaoChunksWithDao: (GPKGFeatureDao *) featureDao andRows: (int) rows andChunkSize: (int) chunkSize asSuccessful: (BOOL) successful{
    
    int countBefore = [featureDao count];
    
    [featureDao beginTransaction];
    [GPKGTestUtils assertTrue:[featureDao inTransaction]];
    
    @try {
        
        for (int count = 1; count <= rows; count++) {
            
            [self insertRow:featureDao];
            
            if (count % chunkSize == 0) {
                
                [GPKGTestUtils assertTrue:[featureDao inTransaction]];
                if (successful) {
                    [featureDao commitTransaction];
                    [GPKGTestUtils assertFalse:[featureDao inTransaction]];
                    [featureDao beginTransaction];
                    [GPKGTestUtils assertTrue:[featureDao inTransaction]];
                } else {
                    [featureDao rollbackTransaction];
                    [GPKGTestUtils assertFalse:[featureDao inTransaction]];
                    [featureDao beginTransaction];
                    [GPKGTestUtils assertTrue:[featureDao inTransaction]];
                }
                
            }
        }
        
    } @catch (NSException *exception) {
        
        [featureDao rollbackTransaction];
        [GPKGTestUtils fail:exception.reason];
        
    } @finally {
        
        [GPKGTestUtils assertTrue:[featureDao inTransaction]];
        
        if(successful){
            [featureDao commitTransaction];
        }else{
            [featureDao rollbackTransaction];
        }
        
        [GPKGTestUtils assertFalse:[featureDao inTransaction]];
    }
    
    [GPKGTestUtils assertEqualIntWithValue:successful ? countBefore + rows : countBefore andValue2:[featureDao count]];
    
}

/**
 * Insert rows into the feature table
 *
 * @param featureDao feature dao
 * @param rows       number of rows
 */
-(void) insertRows: (int) rows withDao: (GPKGFeatureDao *) featureDao{
    
    for (int count = 0; count < rows; count++) {
        [self insertRow:featureDao];
    }
    
}

/**
 * Insert a row into the feature table
 *
 * @param featureDao feature dao
 */
-(void) insertRow: (GPKGFeatureDao *) featureDao{
    
    GPKGFeatureRow *row = [featureDao newRow];
    GPKGGeometryData *geometry = [[GPKGGeometryData alloc] initWithSrsId:featureDao.geometryColumns.srsId];
    [geometry setGeometry:[[SFPoint alloc] initWithXValue:0 andYValue:0]];
    [row setGeometry:geometry];
    [featureDao insert:row];
    
}

/**
 * Test a transaction on the GeoPackage
 *
 * @param geoPackage
 *            GeoPackage
 * @param successful
 *            true for a successful transaction
 */
-(void) testGeoPackage: (GPKGGeoPackage *) geoPackage asSuccessful: (BOOL) successful{
    
    int count = [GPKGSQLiteMaster countViewsWithConnection:geoPackage.database andTable:GPKG_CON_TABLE_NAME];
    
    [geoPackage beginTransaction];
    [GPKGTestUtils assertTrue:[geoPackage inTransaction]];
    
    @try {
        
        [geoPackage execSQL:[NSString stringWithFormat:@"CREATE VIEW %@_view AS SELECT table_name AS tableName FROM %@", GPKG_CON_TABLE_NAME, GPKG_CON_TABLE_NAME]];
        
    } @catch (NSException *exception) {
        
        [geoPackage rollbackTransaction];
        [GPKGTestUtils fail:exception.reason];
        
    } @finally {
        
        [GPKGTestUtils assertTrue:[geoPackage inTransaction]];
        
        if(successful){
            [geoPackage commitTransaction];
        }else{
            [geoPackage rollbackTransaction];
        }
        
        [GPKGTestUtils assertFalse:[geoPackage inTransaction]];
        
    }
    
    [GPKGTestUtils assertEqualIntWithValue:successful ? count + 1 : count andValue2:[GPKGSQLiteMaster countViewsWithConnection:geoPackage.database andTable:GPKG_CON_TABLE_NAME]];
    
}

@end
