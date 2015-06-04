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

@interface GPKGGeoPackage()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) GPKGConnection *database;

@end

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

-(NSString *)getName{
    return self.name;
}

-(NSString *)getPath{
    return self.path;
}

-(GPKGConnection *)getDatabase{
    return self.database;
}

-(NSArray *)getFeatureTables{
    
    GPKGGeometryColumnsDao *dao = [self getGeometryColumnsDao];
    NSArray *tables = dao.getFeatureTables;
    
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
