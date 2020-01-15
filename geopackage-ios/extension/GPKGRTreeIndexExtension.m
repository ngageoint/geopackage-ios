//
//  GPKGRTreeIndexExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRTreeIndexExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGIOUtils.h"
#import "GPKGSqlUtils.h"
#import "SFGeometryEnvelopeBuilder.h"

NSString * const GPKG_RTREE_INDEX_EXTENSION_NAME = @"rtree_index";
NSString * const GPKG_RTREE_INDEX_PREFIX = @"rtree_";
NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_ID = @"id";
NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_X = @"minx";
NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_X = @"maxx";
NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_Y = @"miny";
NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_Y = @"maxy";
NSString * const GPKG_PROP_RTREE_INDEX_EXTENSION_DEFINITION = @"geopackage.extensions.rtree_index";

NSString * const GPKG_RTREE_INDEX_RESOURCES_SQL = @"geopackage.rtree_sql";

NSString * const GPKG_RTREE_INDEX_MIN_X_FUNCTION = @"ST_MinX";
NSString * const GPKG_RTREE_INDEX_MAX_X_FUNCTION = @"ST_MaxX";
NSString * const GPKG_RTREE_INDEX_MIN_Y_FUNCTION = @"ST_MinY";
NSString * const GPKG_RTREE_INDEX_MAX_Y_FUNCTION = @"ST_MaxY";
NSString * const GPKG_RTREE_INDEX_IS_EMPTY_FUNCTION = @"ST_IsEmpty";

NSString * const GPKG_PROP_RTREE_INDEX_CREATE = @"create";
NSString * const GPKG_PROP_RTREE_INDEX_TABLE = @"table";
NSString * const GPKG_PROP_RTREE_INDEX_LOAD = @"load";
NSString * const GPKG_PROP_RTREE_INDEX_DROP = @"drop";
NSString * const GPKG_PROP_RTREE_INDEX_DROP_FORCE = @"drop_force";
NSString * const GPKG_PROP_RTREE_INDEX_TRIGGER_BASE = @"trigger";
NSString * const GPKG_RTREE_INDEX_TRIGGER_INSERT_NAME = @"insert";
NSString * const GPKG_RTREE_INDEX_TRIGGER_UPDATE1_NAME = @"update1";
NSString * const GPKG_RTREE_INDEX_TRIGGER_UPDATE2_NAME = @"update2";
NSString * const GPKG_RTREE_INDEX_TRIGGER_UPDATE3_NAME = @"update3";
NSString * const GPKG_RTREE_INDEX_TRIGGER_UPDATE4_NAME = @"update4";
NSString * const GPKG_RTREE_INDEX_TRIGGER_DELETE_NAME = @"delete";
NSString * const GPKG_PROP_RTREE_INDEX_TRIGGER_DROP = @"trigger.drop";

NSString * const GPKG_PROP_RTREE_INDEX_TABLE_SUBSTITUTE = @"substitute.table";
NSString * const GPKG_PROP_RTREE_INDEX_GEOMETRY_COLUMN_SUBSTITUTE = @"substitute.geometry_column";
NSString * const GPKG_PROP_RTREE_INDEX_PK_COLUMN_SUBSTITUTE = @"substitute.pk_column";
NSString * const GPKG_PROP_RTREE_INDEX_TRIGGER_SUBSTITUTE = @"substitute.trigger";

@interface GPKGRTreeIndexExtension()

@property (nonatomic, strong) GPKGConnection *connection;
@property (nonatomic, strong) NSDictionary *sqlStatements;
@property (nonatomic, strong) NSString *tableSubstitute;
@property (nonatomic, strong) NSString *geometryColumnSubstitute;
@property (nonatomic, strong) NSString *pkColumnSubstitute;
@property (nonatomic, strong) NSString *triggerSubstitute;

@end

@implementation GPKGRTreeIndexExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.connection = geoPackage.database;
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_RTREE_INDEX_EXTENSION_NAME];
        self.definition = [GPKGProperties valueOfProperty:GPKG_PROP_RTREE_INDEX_EXTENSION_DEFINITION];
        
        NSString * sqlProperties = [GPKGIOUtils propertyListPathWithName:GPKG_RTREE_INDEX_RESOURCES_SQL];
        self.sqlStatements = [NSDictionary dictionaryWithContentsOfFile:sqlProperties];
        
        self.tableSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_TABLE_SUBSTITUTE];
        self.geometryColumnSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_GEOMETRY_COLUMN_SUBSTITUTE];
        self.pkColumnSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_PK_COLUMN_SUBSTITUTE];
        self.triggerSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_TRIGGER_SUBSTITUTE];
    }
    return self;
}

-(GPKGRTreeIndexTableDao *) tableDaoWithFeatureTable: (NSString *) featureTable{
    return [self tableDaoWithFeatureDao:[self.geoPackage featureDaoWithTableName:featureTable]];
}

-(GPKGRTreeIndexTableDao *) tableDaoWithFeatureDao: (GPKGFeatureDao *) featureDao{
    
    GPKGConnection *connection = self.geoPackage.database;
    GPKGUserCustomTable *userCustomTable =  [self rTreeTableWithFeatureTable:[featureDao featureTable]];
    GPKGUserCustomDao *userCustomDao = [[GPKGUserCustomDao alloc] initWithDatabase:connection andTable:userCustomTable];
    
    return [[GPKGRTreeIndexTableDao alloc] initWithExtension:self andDao:userCustomDao andFeatureDao:featureDao];
}

-(GPKGExtensions *) extensionCreateWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self extensionCreateWithTableName:featureTable.tableName andColumnName:[featureTable geometryColumnName]];
}

-(GPKGExtensions *) extensionCreateWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    return [self extensionCreateWithName:self.extensionName andTableName:tableName andColumnName:columnName andDefinition:self.definition andScope:GPKG_EST_WRITE_ONLY];
}

-(BOOL) hasWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self hasWithTableName:featureTable.tableName andColumnName:[featureTable geometryColumnName]];
}

-(BOOL) hasWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    return [self hasWithExtensionName:self.extensionName andTableName:tableName andColumnName:columnName]
    && [self.connection tableExists:[self rTreeTableNameWithTable:tableName andColumn:columnName]];
}

-(BOOL) hasWithTableName: (NSString *) tableName{
    return [self hasWithExtensionName:self.extensionName andTableName:tableName];
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName];
}

-(BOOL) createFunctionsWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self createFunctionsWithTableName:featureTable.tableName andColumnName:[featureTable geometryColumnName]];
}

-(BOOL) createFunctionsWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    
    BOOL created = [self hasWithTableName:tableName andColumnName:columnName];
    if (created) {
        [self createAllFunctions];
    }
    return created;
}

-(BOOL) createFunctions {
    
    BOOL created = [self has];
    if (created) {
        [self createAllFunctions];
    }
    return created;
}

-(GPKGExtensions *) createWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self createWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName] andIdColumnName:[featureTable pkColumn].name];
}

-(GPKGExtensions *) createWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    GPKGExtensions *extension = [self extensionCreateWithTableName:tableName andColumnName:geometryColumnName];
    
    [self createAllFunctions];
    [self createRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self loadRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createAllTriggersWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];

    return extension;
}

-(void) createRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self createRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName]];
}

-(void) createRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_CREATE andTableName:tableName andGeometryColumnName:geometryColumnName];
}

-(void) createAllFunctions{
    NSMutableArray<GPKGConnectionFunction *> *functions = [NSMutableArray array];
    [functions addObject:[self buildMinXFunction]];
    [functions addObject:[self buildMaxXFunction]];
    [functions addObject:[self buildMinYFunction]];
    [functions addObject:[self buildMaxYFunction]];
    [functions addObject:[self buildIsEmptyFunction]];
    [self addFunctions:functions];
}

/**
 * Retrieve the Geometry Data from the custom function blob argument value
 *
 * @param count
 *            function argument count
 * @param args
 *            function arguments
 * @return geometry data
 */
+(GPKGGeometryData *) geometryDataFunctionWithCount: (int) count andArguments: (sqlite3_value **) args{
    
    if(count != 1){
        [NSException raise:@"Function Arguments" format:@"Single argument is required. args: %d", count];
    }
    
    GPKGGeometryData *geometryData = nil;
    
    const void * bytes = sqlite3_value_blob(args[0]);
    int byteCount = sqlite3_value_bytes(args[0]);
    if(byteCount > 0){
        NSData *data = [NSData dataWithBytes:bytes length:byteCount];
        if(data != nil){
            geometryData = [[GPKGGeometryData alloc] initWithData:data];
        }
    }
    
    return geometryData;
}

/**
 * Retrieve or build a Geometry Envelope from the Geometry Data
 *
 * @param data
 *            geometry data
 * @return geometry envelope
 */
+(SFGeometryEnvelope *) envelopeOfGeometryData: (GPKGGeometryData *) data{
    SFGeometryEnvelope *envelope = nil;
    if(data != nil){
        envelope = [data buildEnvelope];
    }
    if(envelope == nil){
        envelope = [[SFGeometryEnvelope alloc] init];
    }
    return envelope;
}

/**
 * Get the RTree Table name for the feature table and geometry column
 *
 * @param tableName
 *            feature table name
 * @param geometryColumnName
 *            geometry column name
 * @return RTree table name
 */
-(NSString *) rTreeTableNameWithTable: (NSString *) tableName andColumn: (NSString *) geometryColumnName{
    NSString *sqlName = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_TABLE];
    NSString *rTreeTableName = [self substituteSqlArgumentsWithSql:sqlName andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:nil andTriggerName:nil];
    return rTreeTableName;
}

/**
 * Get the RTree Table
 *
 * @param featureTable
 *            feature table
 * @return RTree table
 */
-(GPKGUserCustomTable *) rTreeTableWithFeatureTable: (GPKGFeatureTable *) featureTable{

    NSMutableArray *columns = [[NSMutableArray alloc] init];
    [columns addObject:[GPKGUserCustomColumn createPrimaryKeyColumnWithName:GPKG_RTREE_INDEX_EXTENSION_COLUMN_ID]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_X andDataType:GPKG_DT_FLOAT]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_X andDataType:GPKG_DT_FLOAT]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_Y andDataType:GPKG_DT_FLOAT]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_Y andDataType:GPKG_DT_FLOAT]];
    
    NSString *rTreeTableName = [self rTreeTableNameWithTable:featureTable.tableName andColumn:[featureTable geometryColumnName]];
    
    GPKGUserCustomTable *userCustomTable = [[GPKGUserCustomTable alloc] initWithTable:rTreeTableName andColumns:columns];
    
    return userCustomTable;
}

/**
 *  Min X SQL function
 */
void minXFunction (sqlite3_context *context, int argc, sqlite3_value **argv) {
    GPKGGeometryData *data = [GPKGRTreeIndexExtension geometryDataFunctionWithCount:argc andArguments:argv];
    NSDecimalNumber *minX = [GPKGRTreeIndexExtension envelopeOfGeometryData:data].minX;
    sqlite3_result_double(context, [minX doubleValue]);
}

/**
 *  Min Y SQL function
 */
void minYFunction (sqlite3_context *context, int argc, sqlite3_value **argv) {
    GPKGGeometryData *data = [GPKGRTreeIndexExtension geometryDataFunctionWithCount:argc andArguments:argv];
    NSDecimalNumber *minY = [GPKGRTreeIndexExtension envelopeOfGeometryData:data].minY;
    sqlite3_result_double(context, [minY doubleValue]);
}

/**
 *  Max X SQL function
 */
void maxXFunction (sqlite3_context *context, int argc, sqlite3_value **argv) {
    GPKGGeometryData *data = [GPKGRTreeIndexExtension geometryDataFunctionWithCount:argc andArguments:argv];
    NSDecimalNumber *maxX = [GPKGRTreeIndexExtension envelopeOfGeometryData:data].maxX;
    sqlite3_result_double(context, [maxX doubleValue]);
}

/**
 *  Max Y SQL function
 */
void maxYFunction (sqlite3_context *context, int argc, sqlite3_value **argv) {
    GPKGGeometryData *data = [GPKGRTreeIndexExtension geometryDataFunctionWithCount:argc andArguments:argv];
    NSDecimalNumber *maxY = [GPKGRTreeIndexExtension envelopeOfGeometryData:data].maxY;
    sqlite3_result_double(context, [maxY doubleValue]);
}

/**
 *  Is Empty SQL function
 */
void isEmptyFunction (sqlite3_context *context, int argc, sqlite3_value **argv) {
    GPKGGeometryData *data = [GPKGRTreeIndexExtension geometryDataFunctionWithCount:argc andArguments:argv];
    BOOL empty = data == nil || data.empty || data.geometry == nil;
    sqlite3_result_int(context, empty ? 1 : 0);
}

-(void) createMinXFunction{
    [self addFunction:[self buildMinXFunction]];
}

-(GPKGConnectionFunction *) buildMinXFunction{
    return [self buildFunction:minXFunction withName:GPKG_RTREE_INDEX_MIN_X_FUNCTION];
}

-(void) createMaxXFunction{
    [self addFunction:[self buildMaxXFunction]];
}

-(GPKGConnectionFunction *) buildMaxXFunction{
    return [self buildFunction:maxXFunction withName:GPKG_RTREE_INDEX_MAX_X_FUNCTION];
}

-(void) createMinYFunction{
    [self addFunction:[self buildMinYFunction]];
}

-(GPKGConnectionFunction *) buildMinYFunction{
    return [self buildFunction:minYFunction withName:GPKG_RTREE_INDEX_MIN_Y_FUNCTION];
}

-(void) createMaxYFunction{
    [self addFunction:[self buildMaxYFunction]];
}

-(GPKGConnectionFunction *) buildMaxYFunction{
    return [self buildFunction:maxYFunction withName:GPKG_RTREE_INDEX_MAX_Y_FUNCTION];
}

-(void) createIsEmptyFunction{
    [self addFunction:[self buildIsEmptyFunction]];
}

-(GPKGConnectionFunction *) buildIsEmptyFunction{
    return [self buildFunction:isEmptyFunction withName:GPKG_RTREE_INDEX_IS_EMPTY_FUNCTION];
}

-(void) loadRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self loadRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName] andIdColumnName:[featureTable pkColumn].name];
}

-(void) loadRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName {
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_LOAD andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self createAllTriggersWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName] andIdColumnName:[featureTable pkColumn].name];
}

-(void) createAllTriggersWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    [self createInsertTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createUpdate1TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createUpdate2TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createUpdate3TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createUpdate4TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createDeleteTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    
}

-(void) createInsertTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_INSERT_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createUpdate1TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_UPDATE1_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createUpdate2TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_UPDATE2_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createUpdate3TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_UPDATE3_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createUpdate4TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_UPDATE4_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createDeleteTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    NSString *name = [GPKGProperties combineBaseProperty:GPKG_PROP_RTREE_INDEX_TRIGGER_BASE withProperty:GPKG_RTREE_INDEX_TRIGGER_DELETE_NAME];
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) deleteWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self deleteWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName]];
}

-(void) deleteWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    
    if([self hasWithTableName:tableName andColumnName:geometryColumnName]){
        [self dropWithTableName:tableName andGeometryColumnName:geometryColumnName];
        
        @try {
            
            [self.extensionsDao deleteByExtension:self.extensionName andTable:tableName andColumnName:geometryColumnName];
            
        } @catch (NSException *e) {
            [NSException raise:@"RTree Index Deletion" format:@"Failed to delete RTree Index extension. GeoPackage %@, Table: %@, GeometryColumn: %@, error: %@", self.geoPackage.name, tableName, geometryColumnName, [e description]];
        }
    }
        
}

-(void) deleteWithTableName: (NSString *) tableName{
    
    if([self.extensionsDao tableExists]){
        NSMutableArray<GPKGExtensions *> *extensionsToDelete = [[NSMutableArray alloc] init];
        GPKGResultSet *extensions = [self.extensionsDao queryByExtension:self.extensionName andTable:tableName];
        @try {
            while([extensions moveToNext]){
                GPKGExtensions *extension = (GPKGExtensions *)[self.extensionsDao object:extensions];
                [extensionsToDelete addObject:extension];
            }
        } @finally {
            [extensions close];
        }
        for(GPKGExtensions *extension in extensionsToDelete){
            [self deleteWithTableName:extension.tableName andGeometryColumnName:extension.columnName];
        }
    }
    
}

-(void) deleteAll{
    
    if([self.extensionsDao tableExists]){
        NSMutableArray<GPKGExtensions *> *extensionsToDelete = [[NSMutableArray alloc] init];
        GPKGResultSet *extensions = [self.extensionsDao queryByExtension:self.extensionName];
        @try {
            while([extensions moveToNext]){
                GPKGExtensions *extension = (GPKGExtensions *)[self.extensionsDao object:extensions];
                [extensionsToDelete addObject:extension];
            }
        } @finally {
            [extensions close];
        }
        for(GPKGExtensions *extension in extensionsToDelete){
            [self deleteWithTableName:extension.tableName andGeometryColumnName:extension.columnName];
        }
    }
    
}

-(void) dropWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName]];
}

-(void) dropWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    
    [self dropAllTriggersWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName];
    
}

-(void) dropRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName]];
}

-(void) dropRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_DROP andTableName:tableName andGeometryColumnName:geometryColumnName];
}

-(void) dropTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropTriggersWithTableName:featureTable.tableName andColumnName:[featureTable geometryColumnName]];
}

-(BOOL) dropTriggersWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName {
    BOOL dropped = [self hasWithTableName:tableName andColumnName:columnName];
    if (dropped) {
        [self dropAllTriggersWithTableName:tableName andGeometryColumnName:columnName];
    }
    return dropped;
}

-(void) dropAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropAllTriggersWithTableName:featureTable.tableName andGeometryColumnName:[featureTable geometryColumnName]];
}

-(void) dropAllTriggersWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    
    [self dropInsertTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropUpdate1TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropUpdate2TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropUpdate3TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropUpdate4TriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropDeleteTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName];
    
}

-(void) dropInsertTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_INSERT_NAME];
}

-(void) dropUpdate1TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_UPDATE1_NAME];
}

-(void) dropUpdate2TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_UPDATE2_NAME];
}

-(void) dropUpdate3TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_UPDATE3_NAME];
}

-(void) dropUpdate4TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_UPDATE4_NAME];
}

-(void) dropDeleteTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self dropTriggerWithTableName:tableName andGeometryColumnName:geometryColumnName andTriggerName:GPKG_RTREE_INDEX_TRIGGER_DELETE_NAME];
}

-(void) dropTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andTriggerName: (NSString *) triggerName{
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_TRIGGER_DROP andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:nil andTriggerName:triggerName];
}

/**
 * Execute the SQL for the SQL file name while substituting values for the
 * table and geometry column
 *
 * @param name
 *            sql property name
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) executeSQLWithName: (NSString *) name andTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:nil];
}

/**
 * Execute the SQL for the SQL file name while substituting values for the
 * table, geometry column, and id column
 *
 * @param name
 *            sql property name
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) executeSQLWithName: (NSString *) name andTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    [self executeSQLWithName:name andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName andTriggerName:nil];
}

/**
 * Execute the SQL for the SQL file name while substituting values for the
 * table, geometry column, id column, and trigger name
 *
 * @param name
 *            sql property name
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 * @param triggerName
 *            trigger name
 */
-(void) executeSQLWithName: (NSString *) name andTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName andTriggerName: (NSString *) triggerName{
    
    NSArray *statements = [self.sqlStatements objectForKey:name];
    if(statements == nil){
        [NSException raise:@"RTree SQL" format:@"Failed to find SQL statements for RTree name: %@, in resource: %@", name, GPKG_RTREE_INDEX_RESOURCES_SQL];
    }
    
    for (NSString *statement in statements) {
        NSString *sql = [self substituteSqlArgumentsWithSql:statement andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName andTriggerName:triggerName];
        [self.connection execResettable:sql];
    }
    
}

/**
 * Replace the SQL arguments for the table, geometry column, id column, and
 * trigger name
 *
 * @param sql
 *            sql to substitute
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 * @param triggerName
 *            trigger name
 * @return substituted sql
 */
-(NSString *) substituteSqlArgumentsWithSql: (NSString *) sql andTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName andTriggerName: (NSString *) triggerName{
    
    NSString *substituted = sql;
    
    substituted = [substituted stringByReplacingOccurrencesOfString:self.tableSubstitute withString:tableName];
    substituted = [substituted stringByReplacingOccurrencesOfString:self.geometryColumnSubstitute withString:geometryColumnName];
    
    if (idColumnName != nil) {
        substituted = [substituted stringByReplacingOccurrencesOfString:self.pkColumnSubstitute withString:idColumnName];
    }
    
    if (triggerName != nil) {
        substituted = [substituted stringByReplacingOccurrencesOfString:self.triggerSubstitute withString:triggerName];
    }
    
    return substituted;
}

/**
 * Build the function for database connections
 *
 * @param function function
 * @param name function name
 */
-(GPKGConnectionFunction *) buildFunction: (void *) function withName: (NSString *) name{
    return [[GPKGConnectionFunction alloc] initWithFunction:function withName:name andNumArgs:1];
}

/**
 * Add the function for database connections
 *
 * @param function function
 * @param name function name
 */
-(void) addFunction: (void *) function withName: (NSString *) name{
    [self addFunction:[self buildFunction:function withName:name]];
}

/**
 * Add the function for database connections
 *
 * @param function function
 */
-(void) addFunction: (GPKGConnectionFunction *) function{
    [self.connection addWriteFunction:function];
}

/**
 * Add the functions for database connections
 *
 * @param functions functions
 */
-(void) addFunctions: (NSArray<GPKGConnectionFunction *> *) functions{
    [self.connection addWriteFunctions:functions];
}

@end
