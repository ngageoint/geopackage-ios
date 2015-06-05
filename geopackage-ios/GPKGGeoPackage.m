//
//  GPKGGeoPackage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGFeatureTableReader.h"

@implementation GPKGGeoPackage

-(instancetype) initWithConnection: (GPKGConnection *) database andWritable: (BOOL) writable{
    self = [super init];
    if(self != nil){
        self.database = database;
        self.name = database.name;
        self.path = database.filename;
        self.writable = writable;
    }
    return self;
}

-(void)close{
    [self.database close];
}

-(NSArray *)getFeatureTables{
    
    GPKGGeometryColumnsDao *dao = [self getGeometryColumnsDao];
    NSArray *tables = dao.getFeatureTables;
    
    return tables;
}

-(NSArray *)getTileTables{
    return nil; // TODO
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createGeometryColumnsTable{
    return false; // TODO
}

-(void) createFeatureTable: (GPKGFeatureTable *) table{
    // TODO
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                andSrsId: (NSNumber *) srsId{
    return nil; // TODO
}

-(GPKGTileMatrixSetDao *) getTileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(BOOL) createTileMatrixSetTable{
    return false; // TODO
}

-(GPKGTileMatrixDao *) getTileMatrixDao{
    return [[GPKGTileMatrixDao alloc] initWithDatabase:self.database];
}

-(BOOL) createTileMatrixTable{
    return false; //TODO
}

-(void) createTileTable: (GPKGTileTable *) table{
    // TODO
}

-(GPKGTileMatrixSet *) createTileTableWithTableName: (NSString *) tableName
                                                andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox
                                                andContentsSrsId: (NSNumber *) contentsSrsId
                                                andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox
                                                andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    return nil; // TODO
}

-(GPKGDataColumnsDao *) getDataColumnsDao{
    return [[GPKGDataColumnsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createDataColumnsTable{
    return false; //TODO
}

-(GPKGDataColumnConstraintsDao *) getDataColumnConstraintsDao{
    return [[GPKGDataColumnConstraintsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createDataColumnConstraintsTable{
    return false; //TODO
}

-(GPKGMetadataDao *) getMetadataDao{
    return [[GPKGMetadataDao alloc] initWithDatabase:self.database];
}

-(BOOL) createMetadataTable{
    return false; //TODO
}

-(GPKGMetadataReferenceDao *) getMetadataReferenceDao{
    return [[GPKGMetadataReferenceDao alloc] initWithDatabase:self.database];
}

-(BOOL) createMetadataReferenceTable{
    return false; //TODO
}

-(GPKGExtensionsDao *) getExtensionsDao{
    return [[GPKGExtensionsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createExtensionsTable{
    return false; //TODO
}

-(void) deleteUserTable: (NSString *) tableName{
    [self verifyWritable];
    
    GPKGContentsDao * contentsDao = [self getContentsDao];
    [contentsDao deleteTable:tableName];
}

-(void) deleteUserTableQuietly: (NSString *) tableName{
    [self verifyWritable];
    
    @try{
        [self deleteUserTable:tableName];
    }@catch(NSException * e){
        // eat
    }
}

-(void) verifyWritable{
    if(!self.writable){
        [NSException raise:@"Read Only" format:@"GeoPackage file is not writable. Name: %@%@", self.name, (self.path != nil ? [NSString stringWithFormat:@", Path: %@", self.path] : @"")];
    }
}

-(GPKGFeatureDao *) getFeatureDaoWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    if(geometryColumns == nil){
        [NSException raise:@"Illegal Argument" format:@"Non null Geometry Columns is required to create Feature DAO"];
    }
    GPKGFeatureTableReader * tableReader = [[GPKGFeatureTableReader alloc] initWithGeometryColumns:geometryColumns];
    GPKGFeatureTable * featureTable = [tableReader readFeatureTableWithConnection:self.database];
    GPKGFeatureDao * dao = [[GPKGFeatureDao alloc] initWithDatabase:self.database andTable:featureTable andGeometryColumns:geometryColumns];
    
    // TODO
    // GeoPackages created with SQLite version 4.2.0+ with GeoPackage
    // support are not fully supported in previous sqlite versions
    [self dropSQLiteTriggers:geometryColumns];
    
    return dao;
}

-(GPKGFeatureDao *) getFeatureDaoWithContents: (GPKGContents *) contents{
    if(contents == nil){
        [NSException raise:@"Illegal Argument" format:@"Non null Contents is required to create Feature DAO"];
    }
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGGeometryColumns * geometryColumns = [dao getGeometryColumns:contents];
    return [self getFeatureDaoWithGeometryColumns:geometryColumns];
}

-(GPKGFeatureDao *) getFeatureDaoWithTableName: (NSString *) tableName{
    GPKGGeometryColumnsDao * dao = [self getGeometryColumnsDao];
    GPKGGeometryColumns * geometryColumns = [dao queryForTableName:tableName];
    if(geometryColumns == nil){
        [NSException raise:@"No Feature Table" format:@"No Feature Table exists for table name: %@", tableName];
    }
    return [self getFeatureDaoWithGeometryColumns:geometryColumns];
}

-(GPKGTileDao *) getTileDaoWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    //TODO
    return nil;
}

-(GPKGTileDao *) getTileDaoWithContents: (GPKGContents *) contents{
    //TODO
    return nil;
}

-(GPKGTileDao *) getTileDaoWithTableName: (NSString *) tableName{
    //TODO
    return nil;
}

-(void) dropSQLiteTriggers: (GPKGGeometryColumns *) geometryColumns{
    
    if (self.writable) {
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_insert", geometryColumns.tableName, geometryColumns.columnName]];
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_update1", geometryColumns.tableName, geometryColumns.columnName]];
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_update2", geometryColumns.tableName, geometryColumns.columnName]];
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_update3", geometryColumns.tableName, geometryColumns.columnName]];
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_update4", geometryColumns.tableName, geometryColumns.columnName]];
        [self.database exec:[NSString stringWithFormat:@"DROP TRIGGER IF EXISTS rtree_%@_%@_delete", geometryColumns.tableName, geometryColumns.columnName]];
    }
}

@end
