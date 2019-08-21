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
#import "GPKGGeoPackageTableCreator.h"
#import "GPKGTileTableReader.h"
#import "GPKGUtils.h"
#import "GPKGGeoPackageExtensions.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGSchemaExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGSqlUtils.h"
#import "GPKGAttributesTableReader.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGFeatureIndexManager.h"

@interface GPKGGeoPackage()

@property (nonatomic, strong) GPKGGeoPackageTableCreator *tableCreator;

@end

@implementation GPKGGeoPackage

-(instancetype) initWithConnection: (GPKGConnection *) database andWritable: (BOOL) writable andMetadataDb: (GPKGMetadataDb *) metadataDb{
    self = [super init];
    if(self != nil){
        self.database = database;
        self.name = database.name;
        self.path = database.filename;
        self.writable = writable;
        self.metadataDb = metadataDb;
        self.tableCreator = [[GPKGGeoPackageTableCreator alloc] initWithDatabase:database];
    }
    return self;
}

-(void)close{
    [self.database close];
}

-(NSString *) applicationId{
    return [self.database applicationId];
}

-(int) userVersion{
    return [self.database userVersion];
}

-(int) userVersionMajor{
    return [self userVersion] / 10000;
}

-(int) userVersionMinor{
    return ([self userVersion] % 10000) / 100;
}

-(int) userVersionPatch{
    return [self userVersion] % 100;
}

-(NSArray *)getFeatureTables{
    NSArray * tableNames = [self getTablesByType:GPKG_CDT_FEATURES];
    return tableNames;
}

-(NSArray *)getTileTables{
    NSArray * tableNames = [self getTablesByType:GPKG_CDT_TILES];
    return tableNames;
}

-(NSArray *)getAttributesTables{
    NSArray * tableNames = [self getTablesByType:GPKG_CDT_ATTRIBUTES];
    return tableNames;
}

-(NSArray *)getTablesByType: (enum GPKGContentsDataType) type{
    return [self getTablesByTypeName:[GPKGContentsDataTypes name:type]];
}

-(NSArray *)getTablesByTypeName: (NSString *) type{
    GPKGContentsDao * contentsDao = [self getContentsDao];
    NSArray *tableNames = [contentsDao getTablesOfTypeName:type];
    return tableNames;
}

-(NSArray *)getFeatureAndTileTables{
    NSMutableArray * tables = [[NSMutableArray alloc] init];
    [tables addObjectsFromArray:[self getFeatureTables]];
    [tables addObjectsFromArray:[self getTileTables]];
    return tables;
}

-(NSArray *)getTables{
    GPKGContentsDao * contentsDao = [self getContentsDao];
    NSArray * tableNames = [contentsDao getTables];
    return tableNames;
}

-(BOOL) isFeatureTable: (NSString *) table{
    return [self isTable:table ofType:GPKG_CDT_FEATURES];
}

-(BOOL) isTileTable: (NSString *) table{
    return [self isTable:table ofType:GPKG_CDT_TILES];
}

-(BOOL) isAttributeTable: (NSString *) table{
    return [self isTable:table ofType:GPKG_CDT_ATTRIBUTES];
}

-(BOOL) isTable: (NSString *) table ofType: (enum GPKGContentsDataType) type{
    return [self isTable:table ofTypeName:[GPKGContentsDataTypes name:type]];
}

-(BOOL) isTable: (NSString *) table ofTypeName: (NSString *) type{
    return [type isEqualToString:[self typeOfTable:table]];
}

-(BOOL) isFeatureOrTileTable: (NSString *) table{
    BOOL isType = NO;
    GPKGContents *contents = [self contentsOfTable:table];
    if(contents != nil){
        enum GPKGContentsDataType dataType = [contents getContentsDataType];
        isType = dataType == GPKG_CDT_FEATURES || dataType == GPKG_CDT_TILES;
    }
    return isType;
}

-(BOOL) isContentsTable: (NSString *) table{
    return [self contentsOfTable:table] != nil;
}

-(BOOL) isTable: (NSString *) table{
    return [self.database tableExists:table];
}

-(GPKGContents *) contentsOfTable: (NSString *) table{
    GPKGContentsDao *contentsDao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[contentsDao queryForIdObject:table];
    return contents;
}

-(NSString *) typeOfTable: (NSString *) table{
    NSString *tableType = nil;
    GPKGContents *contents = [self contentsOfTable:table];
    if(contents != nil){
        tableType = contents.dataType;
    }
    return tableType;
}

-(enum GPKGContentsDataType) dataTypeOfTable: (NSString *) table{
    enum GPKGContentsDataType tableType = -1;
    GPKGContents *contents = [self contentsOfTable:table];
    if(contents != nil){
        tableType = [contents getContentsDataType];
    }
    return tableType;
}

-(int)getFeatureTableCount{
    int count = 0;
    GPKGGeometryColumnsDao *dao = [self getGeometryColumnsDao];
    if([dao tableExists]){
        count = [dao count];
    }
    return count;
}

-(int)getTileTableCount{
    int count = 0;
    GPKGTileMatrixSetDao *dao = [self getTileMatrixSetDao];
    if([dao tableExists]){
        count = [dao count];
    }
    return count;
}

-(int)getTableCount{
    int count = [self getFeatureTableCount] + [self getTileTableCount];
    return count;
}

-(GPKGBoundingBox *) contentsBoundingBoxInProjection: (SFPProjection *) projection{
    GPKGContentsDao *contentsDao = [self getContentsDao];
    GPKGBoundingBox *boundingBox = [contentsDao boundingBoxInProjection:projection];
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    return [self boundingBoxInProjection:projection andManual:NO];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection andManual: (BOOL) manual{
    
    GPKGBoundingBox *boundingBox = [self contentsBoundingBoxInProjection:projection];
    
    NSArray<NSString *> *tables = [self getTables];
    for(NSString *table in tables){
        GPKGBoundingBox *tableBoundingBox = [self boundingBoxOfTable:table inProjection:projection andManual:manual];
        
        if(tableBoundingBox != nil){
            if(boundingBox != nil){
                boundingBox = [boundingBox union:tableBoundingBox];
            }else{
                boundingBox = tableBoundingBox;
            }
        }
    }
    
    return boundingBox;
}

-(GPKGBoundingBox *) contentsBoundingBoxOfTable: (NSString *) table{
    GPKGContentsDao *contentsDao = [self getContentsDao];
    GPKGBoundingBox *boundingBox = [contentsDao boundingBoxOfTable:table];
    return boundingBox;
}

-(GPKGBoundingBox *) contentsBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection{
    GPKGContentsDao *contentsDao = [self getContentsDao];
    GPKGBoundingBox *boundingBox = [contentsDao boundingBoxOfTable:table inProjection:projection];
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table{
    return [self boundingBoxOfTable:table inProjection:nil];
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection{
    return [self boundingBoxOfTable:table inProjection:projection andManual:NO];
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table andManual: (BOOL) manual{
    return [self boundingBoxOfTable:table inProjection:nil andManual:manual];
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection andManual: (BOOL) manual{
    
    GPKGBoundingBox *boundingBox = [self contentsBoundingBoxOfTable:table inProjection:projection];
    
    GPKGBoundingBox *tableBoundingBox = nil;
    NSString *tableType = [self typeOfTable:table];
    enum GPKGContentsDataType dataType = [GPKGContentsDataTypes fromName:tableType];
    if((int)dataType >= 0){
        switch (dataType) {
            case GPKG_CDT_FEATURES:
                tableBoundingBox = [self featureBoundingBoxOfTable:table inProjection:projection andManual:manual];
                break;
            case GPKG_CDT_TILES:
            case GPKG_CDT_GRIDDED_COVERAGE:
                {
                    GPKGTileMatrixSetDao *tileMatrixSetDao = [self getTileMatrixSetDao];
                    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:table];
                    tableBoundingBox = [tileMatrixSetDao boundingBoxOfTileMatrixSet:tileMatrixSet inProjection:projection];
                }
                break;
            default:
                break;
        }
    }
    
    if (tableBoundingBox != nil) {
        if (boundingBox == nil) {
            boundingBox = tableBoundingBox;
        } else {
            boundingBox = [boundingBox union:tableBoundingBox];
        }
    }
    
    return boundingBox;
}

-(GPKGBoundingBox *) featureBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection andManual: (BOOL) manual{
    
    GPKGBoundingBox *boundingBox = nil;
    
    GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:self andFeatureTable:table];
    
    @try{
        if (manual || [indexManager isIndexed]) {
            boundingBox = [indexManager boundingBoxInProjection:projection];
        }
    }@finally{
        [indexManager close];
    }
    
    return boundingBox;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    GPKGSpatialReferenceSystemDao * dao = [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
    [dao setCrsWktExtension:[[GPKGCrsWktExtension alloc] initWithGeoPackage:self]];
    return dao;
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    // If the GeoPackage is writable and has a RTree Index
    // extension, create the SQL functions
    if(self.writable) {
        GPKGRTreeIndexExtension *rtree = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:self];
        [rtree createFunctions];
    }
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
    [self createUserTable:table];
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId{
    return [self createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:nil andAdditionalColumns:nil andBoundingBox:boundingBox andSrsId:srsId];
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                               andIdColumnName: (NSString *) idColumnName
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId{
    return [self createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:idColumnName andAdditionalColumns:nil andBoundingBox:boundingBox andSrsId:srsId];
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                          andAdditionalColumns: (NSArray *) additionalColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId{
    return [self createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:nil andAdditionalColumns:additionalColumns andBoundingBox:boundingBox andSrsId:srsId];
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                               andIdColumnName: (NSString *) idColumnName
                                          andAdditionalColumns: (NSArray *) additionalColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId{
    
    if(idColumnName == nil){
        idColumnName = @"id";
    }
    
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [columns addObject:[GPKGFeatureColumn createPrimaryKeyColumnWithName:idColumnName]];
    [columns addObject:[GPKGFeatureColumn createGeometryColumnWithName:geometryColumns.columnName
                                                        andGeometryType:[geometryColumns getGeometryType]]];
    
    if(additionalColumns != nil){
        [columns addObjectsFromArray:additionalColumns];
    }
    
    return [self createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andSrsId:srsId andColumns:columns];
}

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId
                                                    andColumns: (NSArray *) columns{
    
    // Get the SRS
    GPKGSpatialReferenceSystem * srs = [self getSrs:srsId];
    
    // Create the Geometry Columns table
    [self createGeometryColumnsTable];
    
    // Create the user feature table
    GPKGFeatureTable * table = [[GPKGFeatureTable alloc] initWithGeometryColumns:geometryColumns andColumns:columns];
    [self createFeatureTable:table];
    
    @try {
        // Create the contents
        GPKGContents * contents = [[GPKGContents alloc] init];
        [contents setTableName:geometryColumns.tableName];
        [contents setDataType:GPKG_CDT_FEATURES_NAME];
        [contents setIdentifier:geometryColumns.tableName];
        // [contents setLastChange:[NSDate date]];
        if(boundingBox != nil){
            [contents setMinX:boundingBox.minLongitude];
            [contents setMinY:boundingBox.minLatitude];
            [contents setMaxX:boundingBox.maxLongitude];
            [contents setMaxY:boundingBox.maxLatitude];
        }
        [contents setSrs:srs];
        [[self getContentsDao] create:contents];
        
        [table setContents:contents];
        
        // Create new geometry columns
        [geometryColumns setContents:contents];
        [geometryColumns setSrs:srs];
        [[self getGeometryColumnsDao] create:geometryColumns];
    }
    @catch (NSException *e) {
        [self deleteUserTableQuietly:geometryColumns.tableName];
        @throw e;
    }
    
    return geometryColumns;
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
    [self createUserTable:table];
}

-(GPKGTileMatrixSet *) createTileTableWithTableName: (NSString *) tableName
                             andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox
                                   andContentsSrsId: (NSNumber *) contentsSrsId
                        andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox
                              andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    return [self createTileTableWithType:GPKG_CDT_TILES andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
}

-(GPKGTileMatrixSet *) createTileTableWithType: (enum GPKGContentsDataType) type
                                  andTableName: (NSString *) tableName
                        andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox
                              andContentsSrsId: (NSNumber *) contentsSrsId
                   andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox
                         andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = nil;
    
    // Get the SRS
    GPKGSpatialReferenceSystem * contentsSrs = [self getSrs:contentsSrsId];
    GPKGSpatialReferenceSystem * tileMatrixSetSrs = [self getSrs:tileMatrixSetSrsId];
    
    // Create the Tile Matrix Set and Tile Matrix tables
    [self createTileMatrixSetTable];
    [self createTileMatrixTable];
    
    // Create the user tile table
    NSArray * columns = [GPKGTileTable createRequiredColumns];
    GPKGTileTable * table = [[GPKGTileTable alloc] initWithTable:tableName andColumns:columns];
    [self createTileTable:table];
    
    @try {
        // Create the contents
        GPKGContents * contents = [[GPKGContents alloc] init];
        [contents setTableName:tableName];
        [contents setContentsDataType:type];
        [contents setIdentifier:tableName];
        // [contents setLastChange:[NSDate date]];
        [contents setMinX:contentsBoundingBox.minLongitude];
        [contents setMinY:contentsBoundingBox.minLatitude];
        [contents setMaxX:contentsBoundingBox.maxLongitude];
        [contents setMaxY:contentsBoundingBox.maxLatitude];
        [contents setSrs:contentsSrs];
        [[self getContentsDao] create:contents];
        
        [table setContents:contents];
        
        // Create new matrix tile set
        tileMatrixSet = [[GPKGTileMatrixSet alloc] init];
        [tileMatrixSet setContents:contents];
        [tileMatrixSet setSrs:tileMatrixSetSrs];
        [tileMatrixSet setMinX:tileMatrixSetBoundingBox.minLongitude];
        [tileMatrixSet setMinY:tileMatrixSetBoundingBox.minLatitude];
        [tileMatrixSet setMaxX:tileMatrixSetBoundingBox.maxLongitude];
        [tileMatrixSet setMaxY:tileMatrixSetBoundingBox.maxLatitude];
        [[self getTileMatrixSetDao] create:tileMatrixSet];
    }
    @catch (NSException *e) {
        [self deleteUserTableQuietly:tableName];
        @throw e;
    }
    
    return tileMatrixSet;
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
        if(created){
            GPKGSchemaExtension * schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:self];
            [schemaExtension getOrCreate];
        }
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
        if(created){
            GPKGMetadataExtension * metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:self];
            [metadataExtension getOrCreate];
        }
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
    
    [GPKGGeoPackageExtensions deleteTableExtensionsWithGeoPackage:self andTable:tableName];
    
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

-(GPKGTableIndexDao *) getTableIndexDao{
    return [[GPKGTableIndexDao alloc] initWithDatabase:self.database];
}

-(BOOL) createTableIndexTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGTableIndexDao * dao = [self getTableIndexDao];
    if(![dao tableExists]){
        created = [self.tableCreator createTableIndex] > 0;
    }
    
    return created;
}

-(GPKGGeometryIndexDao *) getGeometryIndexDao{
    return [[GPKGGeometryIndexDao alloc] initWithDatabase:self.database];
}

-(BOOL) createGeometryIndexTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGGeometryIndexDao * dao = [self getGeometryIndexDao];
    if(![dao tableExists]){
        created = [self.tableCreator createGeometryIndex] > 0;
    }
    
    return created;
}

-(BOOL) indexGeometryIndexTable{
    [self verifyWritable];
    
    BOOL indexed = NO;
    GPKGGeometryIndexDao *dao = [self getGeometryIndexDao];
    if([dao tableExists]){
        indexed = [self.tableCreator indexGeometryIndex] > 0;
    }
    return indexed;
}

-(BOOL) unindexGeometryIndexTable{
    [self verifyWritable];
    
    BOOL unindexed = NO;
    GPKGGeometryIndexDao *dao = [self getGeometryIndexDao];
    if([dao tableExists]){
        unindexed = [self.tableCreator unindexGeometryIndex] > 0;
    }
    return unindexed;
}

-(GPKGFeatureTileLinkDao *) getFeatureTileLinkDao{
    return [[GPKGFeatureTileLinkDao alloc] initWithDatabase:self.database];
}

-(BOOL) createFeatureTileLinkTable{
    [self verifyWritable];
    
    BOOL created = false;
    GPKGFeatureTileLinkDao * dao = [self getFeatureTileLinkDao];
    if(![dao tableExists]){
        created = [self.tableCreator createFeatureTileLink] > 0;
    }
    
    return created;
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
    
    // Read the existing table and create the dao
    GPKGFeatureTableReader * tableReader = [[GPKGFeatureTableReader alloc] initWithGeometryColumns:geometryColumns];
    GPKGFeatureTable * featureTable = [tableReader readFeatureTableWithConnection:self.database];
    [featureTable setContents:[[self getGeometryColumnsDao] getContents:geometryColumns]];
    GPKGFeatureDao * dao = [[GPKGFeatureDao alloc] initWithDatabase:self.database andTable:featureTable andGeometryColumns:geometryColumns andMetadataDb:self.metadataDb];
    
    // If the GeoPackage is writable and the feature table has a RTree Index
    // extension, create the SQL functions
    if(self.writable) {
        GPKGRTreeIndexExtension *rtree = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:self];
        [rtree createFunctionsWithFeatureTable:featureTable];
    }
    
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
    if(tileMatrixSet == nil){
        [NSException raise:@"Illegal Argument" format:@"Non null Tile Matrix Set is required to create Tile DAO"];
    }
    
    // Get the Tile Matrix collection, order by zoom level ascending & pixel
    // size descending per requirement 51
    NSMutableArray * tileMatrices = [[NSMutableArray alloc] init];
    GPKGTileMatrixDao * tileMatrixDao = [self getTileMatrixDao];
    GPKGResultSet * results = [tileMatrixDao queryForEqWithField:GPKG_TM_COLUMN_TABLE_NAME andValue:tileMatrixSet.tableName andGroupBy:nil andHaving:nil
                  andOrderBy:[NSString stringWithFormat:@"%@ ASC, %@ DESC, %@ DESC", GPKG_TM_COLUMN_ZOOM_LEVEL, GPKG_TM_COLUMN_PIXEL_X_SIZE, GPKG_TM_COLUMN_PIXEL_Y_SIZE]];
    @try{
        while([results moveToNext]){
            GPKGTileMatrix * tileMatrix = (GPKGTileMatrix *)[tileMatrixDao getObject:results];
            [GPKGUtils addObject:tileMatrix toArray:tileMatrices];
        }
    }@finally{
        [results close];
    }
    
    // Read the existing table and create the dao
    GPKGTileTableReader * tableReader = [[GPKGTileTableReader alloc] initWithTable:tileMatrixSet.tableName];
    GPKGTileTable * tileTable = [tableReader readTileTableWithConnection:self.database];
    [tileTable setContents:[[self getTileMatrixSetDao] getContents:tileMatrixSet]];
    GPKGTileDao * dao = [[GPKGTileDao alloc] initWithDatabase:self.database andTable:tileTable andTileMatrixSet:tileMatrixSet andTileMatrices:tileMatrices];
    return dao;
}

-(GPKGTileDao *) getTileDaoWithContents: (GPKGContents *) contents{
    if(contents == nil){
        [NSException raise:@"Illegal Argument" format:@"Non null Contents is required to create Tile DAO"];
    }
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGTileMatrixSet * tileMatrixSet = [dao getTileMatrixSet:contents];
    return [self getTileDaoWithTileMatrixSet:tileMatrixSet];
}

-(GPKGTileDao *) getTileDaoWithTableName: (NSString *) tableName{
    
    GPKGTileMatrixSetDao * dao = [self getTileMatrixSetDao];
    
    GPKGTileMatrixSet *tileMatrixSet = nil;
    
    GPKGResultSet * tileMatrixSetList = nil;
    @try{
        tileMatrixSetList = [dao queryForEqWithField:GPKG_TMS_COLUMN_TABLE_NAME andValue:tableName];
        if([tileMatrixSetList moveToNext]){
            tileMatrixSet = (GPKGTileMatrixSet *)[dao getObject: tileMatrixSetList];
            if([tileMatrixSetList moveToNext]){
                [NSException raise:@"Multiple Tile Matrix Sets" format:@"Unexpected state. More than one Tile Matrix Set matched for table name: %@, count: %d", tableName, [tileMatrixSetList count]];
            }
        }
    }@finally{
        if(tileMatrixSetList != nil){
            [tileMatrixSetList close];
        }
    }
    
    if(tileMatrixSet == nil){
        [NSException raise:@"No Tile Matrix Set" format:@"No Tile Table exists for table name: %@", tableName];
    }
    
    return [self getTileDaoWithTileMatrixSet:tileMatrixSet];
}

-(GPKGAttributesDao *) getAttributesDaoWithContents: (GPKGContents *) contents{
    if(contents == nil){
        [NSException raise:@"Illegal Argument" format:@"Non null Contents is required to create Attributes DAO"];
    }
    if([contents getContentsDataType] != GPKG_CDT_ATTRIBUTES){
        [NSException raise:@"Illegal Argument" format:@"Contents is required to be of type Attributes. Actual: %@", contents.dataType];
    }
    
    // Read the existing table and create the dao
    GPKGAttributesTableReader * tableReader = [[GPKGAttributesTableReader alloc] initWithTable:contents.tableName];
    GPKGAttributesTable * attributesTable = [tableReader readAttributesTableWithConnection:self.database];
    [attributesTable setContents:contents];
    GPKGAttributesDao * dao = [[GPKGAttributesDao alloc] initWithDatabase:self.database andTable:attributesTable];
    
    return dao;
}

-(GPKGAttributesDao *) getAttributesDaoWithTableName: (NSString *) tableName{

    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents * contents = (GPKGContents *)[dao queryForIdObject:tableName];
    if(contents == nil){
        [NSException raise:@"No Contents" format:@"No Contents Table entry exists for table name: %@", tableName];
    }
    return [self getAttributesDaoWithContents:contents];
}

-(void) execSQL: (NSString *) sql{
    [self.database exec:sql];
}

-(void) beginTransaction{
    [self.database beginTransaction];
}

-(void) commitTransaction{
    [self.database commitTransaction];
}

-(void) rollbackTransaction{
    [self.database rollbackTransaction];
}

-(void) enableForeignKeys{
    [self.database enableForeignKeys];
}

-(BOOL) foreignKeys{
    return [self.database foreignKeys];
}

-(BOOL) foreignKeysAsOn: (BOOL) on{
    return [self.database foreignKeysAsOn:on];
}

-(void) dropTable: (NSString *) table{
    [self.tableCreator dropTable:table];
}

-(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName{
    if((int)[self dataTypeOfTable:tableName] != -1){
        [self copyTable:tableName toTable:newTableName];
        [self deleteTable:tableName];
    }else{
        [GPKGAlterTable renameTable:tableName toTable:newTableName withConnection:self.database];
    }
}

-(void) copyTable: (NSString *) tableName toTable: (NSString *) newTableName{
    [self copyTable:tableName toTable:newTableName andTransfer:YES andExtensions:YES];
}

-(void) copyTableNoExtensions: (NSString *) tableName toTable: (NSString *) newTableName{
    [self copyTable:tableName toTable:newTableName andTransfer:YES andExtensions:NO];
}

-(void) copyTableAsEmpty: (NSString *) tableName toTable: (NSString *) newTableName{
    [self copyTable:tableName toTable:newTableName andTransfer:NO andExtensions:NO];
}

/**
 * Copy the table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer content flag
 * @param extensions
 *            extensions copy flag
 */
-(void) copyTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent andExtensions: (BOOL) extensions{
    
    enum GPKGContentsDataType dataType = [self dataTypeOfTable:tableName];
    if((int)dataType != -1){
        switch(dataType){
                
            case GPKG_CDT_ATTRIBUTES:
                [self copyAttributeTable:tableName toTable:newTableName andTransfer:transferContent];
                break;
                
            case GPKG_CDT_FEATURES:
                [self copyFeatureTable:tableName toTable:newTableName andTransfer:transferContent];
                break;
                
            case GPKG_CDT_TILES:
            case GPKG_CDT_GRIDDED_COVERAGE:
                [self copyTileTable:tableName toTable:newTableName andTransfer:transferContent];
                break;
                
            default:
                [NSException raise:@"Unsupported data type" format:@"Unsupported data type: %@", [GPKGContentsDataTypes name:dataType]];
        }
    }else{
        [self copyUserTable:tableName toTable:newTableName andTransfer:transferContent andValidate:NO];
    }
    
    // Copy extensions
    if(extensions){
        [GPKGGeoPackageExtensions copyTableExtensions:tableName toTable:newTableName inGeoPackage:self];
    }
    
}

/**
 * Copy the attribute table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer content flag
 */
-(void) copyAttributeTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent{
    [self copyUserTable:tableName toTable:newTableName andTransfer:transferContent];
}

/**
 * Copy the feature table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer content flag
 */
-(void) copyFeatureTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [self getGeometryColumnsDao];
    GPKGGeometryColumns *geometryColumns = [geometryColumnsDao queryForTableName:tableName];
    if(geometryColumns == nil){
        [NSException raise:@"No Geometry Columns" format:@"No geometry columns for table: %@", tableName];
    }
    
    GPKGContents *contents = [self copyUserTable:tableName toTable:newTableName andTransfer:transferContent];
    
    [geometryColumns setContents:contents];
    [geometryColumnsDao create:geometryColumns];
}

/**
 * Copy the tile table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer content flag
 */
-(void) copyTileTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent{
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [self getTileMatrixSetDao];
    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:tableName];
    if(tileMatrixSet == nil){
        [NSException raise:@"No Tile Matrix Set" format:@"No tile matrix set for table: %@", tableName];
    }
    
    GPKGContents *contents = [self copyUserTable:tableName toTable:newTableName andTransfer:transferContent];
    
    [tileMatrixSet setContents:contents];
    [tileMatrixSetDao create:tileMatrixSet];
    
    GPKGTileMatrixDao *tileMatrixDao = [self getTileMatrixDao];
    GPKGResultSet *tileMatrices = [tileMatrixDao queryForEqWithField:GPKG_TM_COLUMN_TABLE_NAME andValue:tableName];
    @try{
        while([tileMatrices moveToNext]){
            GPKGTileMatrix * tileMatrix = (GPKGTileMatrix *)[tileMatrixDao getObject:tileMatrices];
            [tileMatrix setContents:contents];
            [tileMatrixDao create:tileMatrix];
        }
    }@finally{
        [tileMatrices close];
    }
    
}

/**
 * Copy the user table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer user table content flag
 * @return copied contents
 */
-(GPKGContents *) copyUserTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent{
    return [self copyUserTable:tableName toTable:newTableName andTransfer:transferContent andValidate:YES];
}

/**
 * Copy the user table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer user table content flag
 * @param validateContents
 *            true to validate a contents was copied
 * @return copied contents
 */
-(GPKGContents *) copyUserTable: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent andValidate: (BOOL) validateContents{
    
    [GPKGAlterTable copyTable:tableName toTable:newTableName andTransfer:transferContent withConnection:self.database];
    
    GPKGContents *contents = [self copyContentsFromTable:tableName toTable:newTableName];
    
    if(contents == nil && validateContents){
        [NSException raise:@"No Table Contents" format:@"No table contents found for table: %@", tableName];
    }
    
    return contents;
}

/**
 * Copy the contents
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @return copied contents
 */
-(GPKGContents *) copyContentsFromTable: (NSString *) tableName toTable: (NSString *) newTableName{
    
    GPKGContents *contents = [self contentsOfTable:tableName];
    
    if(contents != nil){
        
        [contents setTableName:newTableName];
        [contents setIdentifier:newTableName];
        
        [[self getContentsDao] create:contents];
        
    }
    
    return contents;
}

-(void) vacuum{
    [GPKGSqlUtils vacuum:self.database];
}

-(GPKGResultSet *) rawQuery: (NSString *) sql andArgs: (NSArray *) args{
    return [self.database rawQuery:sql andArgs:args];
}

-(GPKGResultSet *) foreignKeyCheck{
    GPKGResultSet * resultSet = [self rawQuery:@"PRAGMA foreign_key_check" andArgs:nil];
    if(![resultSet moveToNext]){
        [resultSet close];
        resultSet = nil;
    }
    return resultSet;
}

-(GPKGResultSet *) integrityCheck{
    return [self integrityCheck:[self rawQuery:@"PRAGMA integrity_check" andArgs:nil]];
}

-(GPKGResultSet *) quickCheck{
    return [self integrityCheck:[self rawQuery:@"PRAGMA quick_check" andArgs:nil]];
}

/**
 *  Check the result set returned from the integrity check to see if things are "ok"
 *
 *  @param resultSet result set
 *
 *  @return nil if ok, else the open result set
 */
-(GPKGResultSet *) integrityCheck: (GPKGResultSet *) resultSet{
    if([resultSet moveToNext]){
        NSString * value = [resultSet getString:0];
        if([value isEqualToString:@"ok"]){
            [resultSet close];
            resultSet = nil;
        }
    }
    return resultSet;
}

-(GPKGGriddedCoverageDao *) getGriddedCoverageDao{
    return [[GPKGGriddedCoverageDao alloc] initWithDatabase:self.database];
}

-(BOOL) createGriddedCoverageTable{
    
    [self verifyWritable];
    
    BOOL created = false;
    GPKGGriddedCoverageDao * dao = [self getGriddedCoverageDao];
    if(![dao tableExists]){
        created = [self.tableCreator createGriddedCoverage] > 0;
    }
    
    return created;
}

-(GPKGGriddedTileDao *) getGriddedTileDao{
    return [[GPKGGriddedTileDao alloc] initWithDatabase:self.database];
}

-(BOOL) createGriddedTileTable{
    
    [self verifyWritable];
    
    BOOL created = false;
    GPKGGriddedTileDao * dao = [self getGriddedTileDao];
    if(![dao tableExists]){
        created = [self.tableCreator createGriddedTile] > 0;
    }
    
    return created;
}

-(void) createAttributesTable: (GPKGAttributesTable *) table{
    [self createUserTable:table];
}

-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                       andAdditionalColumns: (NSArray *) additionalColumns{
    return [self createAttributesTableWithTableName:tableName andIdColumnName:nil andAdditionalColumns:additionalColumns];
}

-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                       andAdditionalColumns: (NSArray *) additionalColumns
                                       andConstraints: (NSArray<GPKGConstraint *> *) constraints{
    return [self createAttributesTableWithTableName:tableName andIdColumnName:nil andAdditionalColumns:additionalColumns andConstraints:constraints];
}

-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                            andIdColumnName: (NSString *) idColumnName
                                       andAdditionalColumns: (NSArray *) additionalColumns{
    return [self createAttributesTableWithTableName:tableName andIdColumnName:idColumnName andAdditionalColumns:additionalColumns andConstraints:nil];
}

-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                            andIdColumnName: (NSString *) idColumnName
                                       andAdditionalColumns: (NSArray *) additionalColumns
                                       andConstraints: (NSArray<GPKGConstraint *> *) constraints{
    
    if(idColumnName == nil){
        idColumnName = @"id";
    }
    
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [columns addObject:[GPKGFeatureColumn createPrimaryKeyColumnWithName:idColumnName]];
    
    if(additionalColumns != nil){
        [columns addObjectsFromArray:additionalColumns];
    }
    
    return [self createAttributesTableWithTableName:tableName andColumns:columns andConstraints:constraints];
}

-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                                 andColumns: (NSArray *) columns{
    return [self createAttributesTableWithTableName:tableName andColumns:columns andConstraints:nil];
}
    
-(GPKGAttributesTable *) createAttributesTableWithTableName: (NSString *) tableName
                                                 andColumns: (NSArray *) columns
                                       andConstraints: (NSArray<GPKGConstraint *> *) constraints{
    
    // Build the user attributes table
    GPKGAttributesTable * table = [[GPKGAttributesTable alloc] initWithTable:tableName andColumns:columns];
    
    // Add constraints
    if(constraints != nil){
        [table addConstraints:constraints];
    }
    
    // Create the user attributes table
    [self createAttributesTable:table];
    
    @try {
        
        // Create the contents
        GPKGContents * contents = [[GPKGContents alloc] init];
        [contents setTableName:tableName];
        [contents setDataType:GPKG_CDT_ATTRIBUTES_NAME];
        [contents setIdentifier:tableName];
        // [contents setLastChange:[NSDate date]];
        [[self getContentsDao] create:contents];
        
        [table setContents:contents];
    }
    @catch (NSException *e) {
        [self deleteUserTableQuietly:tableName];
        @throw e;
    }
    
    return table;
}

-(GPKGTileScalingDao *) getTileScalingDao{
    return [[GPKGTileScalingDao alloc] initWithDatabase:self.database];
}

-(BOOL) createTileScalingTable{
    
    [self verifyWritable];
    
    BOOL created = false;
    GPKGTileScalingDao * dao = [self getTileScalingDao];
    if(![dao tableExists]){
        created = [self.tableCreator createTileScaling] > 0;
    }
    
    return created;
}

-(GPKGSpatialReferenceSystem *) getSrs: (NSNumber *) srsId{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:srsId];
    if(srs == nil){
        [NSException raise:@"No SRS" format:@"Spatial Reference System could not be found. SRS ID: %@", srsId];
    }
    return srs;
}

-(GPKGExtendedRelationsDao *) getExtendedRelationsDao{
    return [[GPKGExtendedRelationsDao alloc] initWithDatabase:self.database];
}

-(BOOL) createExtendedRelationsTable{
    
    [self verifyWritable];
    
    BOOL created = false;
    GPKGExtendedRelationsDao * dao = [self getExtendedRelationsDao];
    if(![dao tableExists]){
        created = [self.tableCreator createExtendedRelations] > 0;
    }
    
    return created;
}

-(GPKGContentsIdDao *) getContentsIdDao{
    return [[GPKGContentsIdDao alloc] initWithDatabase:self.database];
}

-(BOOL) createContentsIdTable{
    
    [self verifyWritable];
    
    BOOL created = NO;
    GPKGContentsIdDao *dao = [self getContentsIdDao];
    if(![dao tableExists]){
        created = [self.tableCreator createContentsId] > 0;
    }
    
    return created;
}

-(void) createUserTable: (GPKGUserTable *) table{
    [self verifyWritable];
    
    [self.tableCreator createUserTable:table];
}

@end
