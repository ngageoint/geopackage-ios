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
#import "GPKGTableCreator.h"

@interface GPKGGeoPackage()

@property (nonatomic, strong) GPKGTableCreator *tableCreator;

@end

@implementation GPKGGeoPackage

-(instancetype) initWithConnection: (GPKGConnection *) database andWritable: (BOOL) writable{
    self = [super init];
    if(self != nil){
        self.database = database;
        self.name = database.name;
        self.path = database.filename;
        self.writable = writable;
        self.tableCreator = [[GPKGTableCreator alloc] initWithDatabase:database];
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
    
    GPKGTileMatrixSetDao *dao = [self getTileMatrixSetDao];
    NSArray *tables = dao.getTileTables;
    
    return tables;
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
    [self verifyWritable];
    
    BOOL created = false;
    GPKGGeometryColumnsDao * dao = [self getGeometryColumnsDao];
    if(![dao tableExists]){
        created = [self.tableCreator createGeometryColumns] > 0;
    }
    
    return created;
}

-(void) createFeatureTable: (GPKGFeatureTable *) table{
    [self verifyWritable];
    
    [self.tableCreator createUserTable:table];
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
    [self verifyWritable];
    
    BOOL created = false;
    GPKGTileMatrixSetDao * dao = [self getTileMatrixSetDao];
    if(![dao tableExists]){
        created = [self.tableCreator createTileMatrixSet] > 0;
    }
    
    return created;
}

-(GPKGTileMatrixDao *) getTileMatrixDao{
    return [[GPKGTileMatrixDao alloc] initWithDatabase:self.database];
}

-(BOOL) createTileMatrixTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGTileMatrixDao * dao = [self getTileMatrixDao];
    if(![dao tableExists]){
        created = [self.tableCreator createTileMatrix] > 0;
    }
    
    return created;
}

-(void) createTileTable: (GPKGTileTable *) table{
    [self verifyWritable];
    
    [self.tableCreator createUserTable:table];
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
    [self verifyWritable];
    
    BOOL created = false;
    GPKGDataColumnsDao * dao = [self getDataColumnsDao];
    if(![dao tableExists]){
        created = [self.tableCreator createDataColumns] > 0;
    }
    
    return created;
}

-(GPKGDataColumnConstraintsDao *) getDataColumnConstraintsDao{
    return [[GPKGDataColumnConstraintsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createDataColumnConstraintsTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGDataColumnConstraintsDao * dao = [self getDataColumnConstraintsDao];
    if(![dao tableExists]){
        created = [self.tableCreator createDataColumnConstraints] > 0;
    }
    
    return created;
}

-(GPKGMetadataDao *) getMetadataDao{
    return [[GPKGMetadataDao alloc] initWithDatabase:self.database];
}

-(BOOL) createMetadataTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGMetadataDao * dao = [self getMetadataDao];
    if(![dao tableExists]){
        created = [self.tableCreator createMetadata] > 0;
    }
    
    return created;
}

-(GPKGMetadataReferenceDao *) getMetadataReferenceDao{
    return [[GPKGMetadataReferenceDao alloc] initWithDatabase:self.database];
}

-(BOOL) createMetadataReferenceTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGMetadataReferenceDao * dao = [self getMetadataReferenceDao];
    if(![dao tableExists]){
        created = [self.tableCreator createMetadataReference] > 0;
    }
    
    return created;
}

-(GPKGExtensionsDao *) getExtensionsDao{
    return [[GPKGExtensionsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createExtensionsTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGExtensionsDao * dao = [self getExtensionsDao];
    if(![dao tableExists]){
        created = [self.tableCreator createExtensions] > 0;
    }
    
    return created;
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
