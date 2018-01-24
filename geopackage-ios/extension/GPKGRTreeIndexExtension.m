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

NSString * const GPKG_RTREE_INDEX_EXTENSION_NAME = @"rtree_index";
NSString * const GPKG_PROP_RTREE_INDEX_EXTENSION_DEFINITION = @"geopackage.extensions.rtree_index";

NSString * const GPKG_RTREE_INDEX_RESOURCES_SQL = @"rtree_sql";

NSString * const GPKG_RTREE_INDEX_MIN_X_FUNCTION = @"ST_MinX";
NSString * const GPKG_RTREE_INDEX_MAX_X_FUNCTION = @"ST_MaxX";
NSString * const GPKG_RTREE_INDEX_MIN_Y_FUNCTION = @"ST_MinY";
NSString * const GPKG_RTREE_INDEX_MAX_Y_FUNCTION = @"ST_MaxY";
NSString * const GPKG_RTREE_INDEX_IS_EMPTY_FUNCTION = @"ST_IsEmpty";

NSString * const GPKG_PROP_RTREE_INDEX_CREATE = @"create";
NSString * const GPKG_PROP_RTREE_INDEX_LOAD = @"load";
NSString * const GPKG_PROP_RTREE_INDEX_DROP = @"drop";
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
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_RTREE_INDEX_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_RTREE_INDEX_EXTENSION_DEFINITION];
        
        NSString * sqlProperties = [GPKGIOUtils getPropertyListPathWithName:GPKG_RTREE_INDEX_RESOURCES_SQL];
        self.sqlStatements = [NSDictionary dictionaryWithContentsOfFile:sqlProperties];
        
        self.tableSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_TABLE_SUBSTITUTE];
        self.geometryColumnSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_GEOMETRY_COLUMN_SUBSTITUTE];
        self.pkColumnSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_PK_COLUMN_SUBSTITUTE];
        self.triggerSubstitute = [self.sqlStatements objectForKey:GPKG_PROP_RTREE_INDEX_TRIGGER_SUBSTITUTE];
    }
    return self;
}

-(GPKGExtensions *) getOrCreateWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self getOrCreateWithTableName:featureTable.tableName andColumnName:[featureTable getGeometryColumn].name];
}

-(GPKGExtensions *) getOrCreateWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    return [self getOrCreateWithExtensionName:self.extensionName andTableName:tableName andColumnName:columnName andDefinition:self.definition andScope:GPKG_EST_WRITE_ONLY];
}

-(BOOL) hasWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self hasWithTableName:featureTable.tableName andColumnName:[featureTable getGeometryColumn].name];
}

-(BOOL) hasWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    return [self hasWithExtensionName:self.extensionName andTableName:tableName andColumnName:columnName];
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName andTableName:nil andColumnName:nil];
}

-(BOOL) createFunctionsWithFeatureTable: (GPKGFeatureTable *) featureTable{
    return [self createFunctionsWithTableName:featureTable.tableName andColumnName:[featureTable getGeometryColumn].name];
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
    return [self createWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name andIdColumnName:[featureTable getPkColumn].name];
}

-(GPKGExtensions *) createWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName{
    
    GPKGExtensions *extension = [self getOrCreateWithTableName:tableName andColumnName:geometryColumnName];
    
    [self createAllFunctions];
    [self createRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self loadRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
    [self createAllTriggersWithTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];

    return extension;
}

-(void) createRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self createRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name];
}

-(void) createRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_CREATE andTableName:tableName andGeometryColumnName:geometryColumnName];
}

-(void) createAllFunctions{
    [self createMinXFunction];
    [self createMaxXFunction];
    [self createMinYFunction];
    [self createMaxYFunction];
    [self createIsEmptyFunction];
}

-(void) createMinXFunction{
    [self createFunctionWithName:GPKG_RTREE_INDEX_MIN_X_FUNCTION];
}

-(void) createMaxXFunction{
    [self createFunctionWithName:GPKG_RTREE_INDEX_MAX_X_FUNCTION];
}

-(void) createMinYFunction{
    [self createFunctionWithName:GPKG_RTREE_INDEX_MIN_Y_FUNCTION];
}

-(void) createMaxYFunction{
    [self createFunctionWithName:GPKG_RTREE_INDEX_MAX_Y_FUNCTION];
}

-(void) createIsEmptyFunction{
    [self createFunctionWithName:GPKG_RTREE_INDEX_IS_EMPTY_FUNCTION];
}

-(void) loadRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self loadRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name andIdColumnName:[featureTable getPkColumn].name];
}

-(void) loadRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName {
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_LOAD andTableName:tableName andGeometryColumnName:geometryColumnName andIdColumnName:idColumnName];
}

-(void) createAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self createAllTriggersWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name andIdColumnName:[featureTable getPkColumn].name];
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
    [self deleteWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name];
}

-(void) deleteWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    
    [self dropWithTableName:tableName andGeometryColumnName:geometryColumnName];
    
    @try {
        
        [self.extensionsDao deleteByExtension:self.extensionName andTable:tableName andColumnName:geometryColumnName];
        
    } @catch (NSException *e) {
        [NSException raise:@"RTree Index Deletion" format:@"Failed to delete RTree Index extension. GeoPackage %@, Table: %@, GeometryColumn: %@, error: %@", self.geoPackage.name, tableName, geometryColumnName, [e description]];
    }
    
}

-(void) dropWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name ];
}

-(void) dropWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    
    [self dropAllTriggersWithTableName:tableName andGeometryColumnName:geometryColumnName];
    [self dropRTreeIndexWithTableName:tableName andGeometryColumnName:geometryColumnName];
    
}

-(void) dropRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropRTreeIndexWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name];
}

-(void) dropRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName{
    [self executeSQLWithName:GPKG_PROP_RTREE_INDEX_DROP andTableName:tableName andGeometryColumnName:geometryColumnName];
}

-(void) dropTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropTriggersWithTableName:featureTable.tableName andColumnName:[featureTable getGeometryColumn].name];
}

-(BOOL) dropTriggersWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName {
    BOOL dropped = [self hasWithTableName:tableName andColumnName:columnName];
    if (dropped) {
        [self dropAllTriggersWithTableName:tableName andGeometryColumnName:columnName];
    }
    return dropped;
}

-(void) dropAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable{
    [self dropAllTriggersWithTableName:featureTable.tableName andGeometryColumnName:[featureTable getGeometryColumn].name];
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
        [self.connection exec:sql];
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
 * Create the function for the connection
 *
 * @param name function name
 */
-(void) createFunctionWithName: (NSString *) name {
    [NSException raise:@"Unsupported" format:@"User defined SQL functions are not supported. name: %@", name];
}

@end
