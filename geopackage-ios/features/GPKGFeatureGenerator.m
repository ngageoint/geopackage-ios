//
//  GPKGFeatureGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureGenerator.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGFeatureTableReader.h"

@interface GPKGFeatureGenerator()

/**
 * GeoPackage
 */
@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

/**
 * Table Name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Table Geometry Columns
 */
@property (nonatomic, strong) GPKGGeometryColumns *geometryColumns;

/**
 * Table columns
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGFeatureColumn *> *columns;

/**
 * Spatial Reference System
 */
@property (nonatomic, strong) GPKGSpatialReferenceSystem *srs;

/**
 * Feature DAO
 */
@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGFeatureGenerator

static SFPProjection *EPSG_WGS84 = nil;

+(void) initialize{
    if(EPSG_WGS84 == nil){
        EPSG_WGS84 = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    }
}

+(SFPProjection *) epsgWGS84{
    return EPSG_WGS84;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage
                          andTable: (NSString *) tableName{
    self = [super init];
    if(self != nil){
        self.transactionLimit = 1000;
        self.columns = [NSMutableDictionary dictionary];
        [geoPackage verifyWritable];
        self.geoPackage = geoPackage;
        self.tableName = tableName;
        [self setProjection:nil];
    }
    return self;
}

-(GPKGGeoPackage *) geoPackage{
    return _geoPackage;
}

-(NSString *) tableName{
    return _tableName;
}

-(BOOL) isActive{
    return self.progress == nil || [self.progress isActive];
}

-(GPKGGeometryColumns *) geometryColumns{
    return _geometryColumns;
}

-(NSDictionary<NSString *, GPKGFeatureColumn *> *) columns{
    return _columns;
}

-(GPKGSpatialReferenceSystem *) srs{
    return _srs;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(int) generateFeatures{
    [self doesNotRecognizeSelector:_cmd];
    return -1;
}

/**
 * Add a new column
 *
 * @param featureColumn
 *            feature column
 */
-(void) addColumn: (GPKGFeatureColumn *) featureColumn{
    // TODO move this and remove method?
    [self.featureDao addColumn:featureColumn];
}

/**
 * Save the feature
 *
 * @param geometry
 *            geometry
 * @param values
 *            column to value mapping
 */
-(void) saveFeatureWithGeometry: (SFGeometry *) geometry andValues: (NSDictionary<NSString *, NSObject *> *) values{
    
    GPKGFeatureRow *featureRow = [self.featureDao newRow];
    
    [featureRow setGeometry:[self createGeometryData:geometry]];
    for(NSString *column in [values allKeys]){
        NSObject *value = [values objectForKey:column];
        [featureRow setValueWithColumnName:column andValue:value];
    }
    
    [self.featureDao create:featureRow];
}

-(void) createFeatureWithGeometry: (SFGeometry *) geometry andProperties: (NSDictionary<NSString *, NSObject *> *) properties{

    if (self.srs == nil) {
        [self createSrs];
    }
    
    if (self.geometryColumns == nil) {
        [self createTableWithProperties:properties];
    }
    
    NSMutableDictionary<NSString *, NSObject *> *values = [NSMutableDictionary dictionary];
    
    for(NSString *column in [properties allKeys]){
        NSObject *value = [self valueOfColumn:column withValue:[properties objectForKey:column]];
        [values setObject:value forKey:column];
    }
    
    [self saveFeatureWithGeometry:geometry andValues:values];
    
}

-(void) createSrs{
    
    GPKGSpatialReferenceSystemDao *srsDao = [self.geoPackage getSpatialReferenceSystemDao];
    SFPProjection *srsProjection = [self srsProjection];
    NSNumber *coordsysId = [NSNumber numberWithInteger:[[srsProjection code] integerValue]];
    self.srs = [srsDao getOrCreateWithOrganization:[srsProjection authority] andCoordsysId:coordsysId];
    
}

-(SFPProjection *) srsProjection{
    SFPProjection *srsProjection = self.projection;
    if (srsProjection == nil) {
        srsProjection = EPSG_WGS84;
    }
    return srsProjection;
}

/**
 * Create the feature table
 *
 * @param properties
 *            properties
 * @throws SQLException
 *             upon error
 */
-(void) createTableWithProperties: (NSDictionary<NSString *, NSObject *> *) properties{

    // Create a new geometry columns or update an existing
    GPKGGeometryColumnsDao *geometryColumnsDao = [self.geoPackage getGeometryColumnsDao];
    if([geometryColumnsDao tableExists]){
        self.geometryColumns = [geometryColumnsDao queryForTableName:self.tableName];
    }
    
    BOOL inTransaction = [self.geoPackage inTransaction];
    if(inTransaction){
        [self.geoPackage commitTransaction];
    }
    
    if (self.geometryColumns == nil) {
        
        NSMutableArray<GPKGFeatureColumn *> *featureColumns = [NSMutableArray array];
        for(NSString *column in [properties allKeys]){
            GPKGFeatureColumn *featureColumn = [self createColumn:column withValue:[properties objectForKey:column]];
            [featureColumns addObject:featureColumn];
            [_columns setObject:featureColumn forKey:column];
        }
        
        // Create the feature table
        GPKGGeometryColumns *geomColumns = [[GPKGGeometryColumns alloc] init];
        [geomColumns setTableName:self.tableName];
        [geomColumns setColumnName:@"geometry"];
        [geomColumns setGeometryType:SF_GEOMETRY];
        [geomColumns setZ:[NSNumber numberWithInt:0]];
        [geomColumns setM:[NSNumber numberWithInt:0]];
        self.geometryColumns = [self.geoPackage createFeatureTableWithGeometryColumns:geomColumns andIdColumnName:[NSString stringWithFormat:@"%@_id", self.tableName] andAdditionalColumns:featureColumns andBoundingBox:self.boundingBox andSrsId:self.srs.srsId];
        
    } else {
        GPKGFeatureTableReader *tableReader = [[GPKGFeatureTableReader alloc] initWithGeometryColumns:self.geometryColumns];
        GPKGFeatureTable *featureTable = [tableReader readFeatureTableWithConnection:self.geoPackage.database];
        for (GPKGFeatureColumn *featureColumn in [featureTable featureColumns]) {
            [_columns setObject:featureColumn forKey:featureColumn.name];
        }
    }
    
    self.featureDao = [self.geoPackage getFeatureDaoWithGeometryColumns:self.geometryColumns];
    
    if(inTransaction){
        [self.geoPackage beginTransaction];
    }
    
}

/**
 * Get the column value
 *
 * @param column
 *            column name
 * @param value
 *            value
 * @return column value
 */
-(NSObject *) valueOfColumn: (NSString *) column withValue: (NSObject *) value{

    GPKGFeatureColumn *featureColumn = [self column:column withValue:value];
    NSObject *columnValue = [GPKGFeatureGenerator value:value withType:featureColumn.dataType];
    
    return columnValue;
}

/**
 * Get the column, create if needed
 *
 * @param column
 *            column name
 * @param value
 *            value
 * @return feature column
 */
-(GPKGFeatureColumn *) column: (NSString *) column withValue: (NSObject *) value{
    
    GPKGFeatureColumn *featureColumn = [self.columns objectForKey:column];
    
    if (featureColumn == nil) {
        BOOL inTransaction = [self.geoPackage inTransaction];
        if (inTransaction) {
            [self.geoPackage commitTransaction];
        }
        featureColumn = [self createColumn:column withValue:value];
        [self addColumn:featureColumn];
        [_columns setObject:featureColumn forKey:column];
        if (inTransaction) {
            [self.geoPackage beginTransaction];
        }
    }
    
    return featureColumn;
}

/**
 * Create a feature column
 *
 * @param name
 *            column name
 * @param value
 *            value
 * @return feature column
 */
-(GPKGFeatureColumn *) createColumn: (NSString *) name withValue: (NSObject *) value{
    enum GPKGDataType type = [GPKGFeatureGenerator typeOfValue:value];
    return [GPKGFeatureColumn createColumnWithName:name andDataType:type];
}

-(GPKGGeometryData *) createGeometryData: (SFGeometry *) geometry{
    GPKGGeometryData *geometryData = [[GPKGGeometryData alloc] initWithSrsId:self.srs.srsId];
    [geometryData setGeometry:geometry];
    return geometryData;
}

/**
 * Get the type for the object value
 *
 * @param value
 *            value
 * @return data type
 */
+(enum GPKGDataType) typeOfValue: (NSObject *) value{
    
    enum GPKGDataType type = -1;
    
    if([value isKindOfClass:[NSString class]]){
        type = GPKG_DT_TEXT;
    }else if([value isKindOfClass:[NSDecimalNumber class]]){
        type = GPKG_DT_DOUBLE;
    }else if([value isKindOfClass:[NSNumber class]]){
        type = GPKG_DT_INT;
    }else if([value isKindOfClass:[NSData class]]){
        type = GPKG_DT_BLOB;
    }
    
    if (type < 0) {
        type = GPKG_DT_TEXT;
    }
    
    return type;
}

/**
 * Get the value for the object value with the data type
 *
 * @param value
 *            value
 * @param type
 *            data type
 * @return default value
 */
+(NSObject *) value: (NSObject *) value withType: (enum GPKGDataType) type{
    
    if (value != nil && type >= 0) {
        
        switch (type) {
            case GPKG_DT_TEXT:
            case GPKG_DT_DATE:
            case GPKG_DT_DATETIME:
                value = [value description];
                break;
            case GPKG_DT_BOOLEAN:
            case GPKG_DT_TINYINT:
            case GPKG_DT_SMALLINT:
            case GPKG_DT_MEDIUMINT:
            case GPKG_DT_INT:
            case GPKG_DT_INTEGER:
            case GPKG_DT_FLOAT:
            case GPKG_DT_DOUBLE:
            case GPKG_DT_REAL:
            case GPKG_DT_BLOB:
                break;
            default:
                [NSException raise:@"Unsupported Data Type" format:@"Unsupported Data Type %d", type];
        }
        
    }
    
    return value;
}

-(void) addProjectionWithAuthority: (NSString *) authority andCode: (NSString *) code toProjections: (SFPProjections *) projections{
    
    SFPProjection *projection = [self createProjectionWithAuthority:authority andCode:code];
    
    if (projection != nil) {
        [projections addProjection:projection];
    }
}

-(SFPProjection *) createProjectionWithAuthority: (NSString *) authority andCode: (NSString *) code{
    
    SFPProjection *projection = nil;
    
    @try {
        projection = [SFPProjectionFactory projectionWithAuthority:authority andCode:code];
    } @catch (NSException *exception) {
        NSLog(@"Unable to create projection. Authority: %@, Code: %@", authority, code);
    }
    
    return projection;
}

@end
