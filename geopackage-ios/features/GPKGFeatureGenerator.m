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
#import "GPKGFeatureTableMetadata.h"

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

-(void) createFeatureWithGeometry: (SFGeometry *) geometry andProperties: (NSDictionary<NSString *, NSObject *> *) properties{

    if (self.srs == nil) {
        [self createSrs];
    }
    
    if (self.geometryColumns == nil) {
        [self createTableWithProperties:properties];
    }
    
    GPKGFeatureRow *featureRow = [self.featureDao newRow];
    [featureRow setGeometry:[self createGeometryData:geometry]];
    
    for(NSString *column in [properties allKeys]){
        NSObject *value = [self valueOfColumn:column withValue:[properties objectForKey:column]];
        [featureRow setValueWithColumnName:column andValue:value];
    }
    
    [self.featureDao create:featureRow];
    
}

-(void) createSrs{
    
    GPKGSpatialReferenceSystemDao *srsDao = [self.geoPackage spatialReferenceSystemDao];
    SFPProjection *srsProjection = [self srsProjection];
    self.srs = [srsDao srsWithProjection:srsProjection];
    
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
    GPKGGeometryColumnsDao *geometryColumnsDao = [self.geoPackage geometryColumnsDao];
    if([geometryColumnsDao tableExists]){
        self.geometryColumns = [geometryColumnsDao queryForTableName:self.tableName];
    }
    
    BOOL inTransaction = [self.geoPackage inTransaction];
    if(inTransaction){
        [self.geoPackage commitTransaction];
    }
    
    @try {
    
        if (self.geometryColumns == nil) {
            
            NSMutableArray<GPKGFeatureColumn *> *featureColumns = [NSMutableArray array];
            for(NSString *column in [properties allKeys]){
                GPKGFeatureColumn *featureColumn = [self createColumn:column withValue:[properties objectForKey:column]];
                [featureColumns addObject:featureColumn];
                [_columns setObject:featureColumn forKey:column];
            }
            
            // Create the feature table
            self.geometryColumns = [[GPKGGeometryColumns alloc] init];
            [self.geometryColumns setTableName:self.tableName];
            [self.geometryColumns setColumnName:@"geometry"];
            [self.geometryColumns setGeometryType:SF_GEOMETRY];
            [self.geometryColumns setZ:[NSNumber numberWithInt:0]];
            [self.geometryColumns setM:[NSNumber numberWithInt:0]];
            [self.geometryColumns setSrs:self.srs];
            [self.geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:self.geometryColumns andIdColumn:[NSString stringWithFormat:@"%@_id", self.tableName] andAdditionalColumns:featureColumns andBoundingBox:self.boundingBox]];
            
        } else {
            GPKGFeatureTableReader *tableReader = [[GPKGFeatureTableReader alloc] initWithGeometryColumns:self.geometryColumns];
            GPKGFeatureTable *featureTable = [tableReader readFeatureTableWithConnection:self.geoPackage.database];
            for (GPKGFeatureColumn *featureColumn in [featureTable columns]) {
                [_columns setObject:featureColumn forKey:featureColumn.name];
            }
        }
        
        self.featureDao = [self.geoPackage featureDaoWithGeometryColumns:self.geometryColumns];
    
    } @finally {
        if(inTransaction){
            [self.geoPackage beginTransaction];
        }
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
        @try {
            featureColumn = [self createColumn:column withValue:value];
            [self.featureDao addColumn:featureColumn];
            [_columns setObject:featureColumn forKey:column];
        } @finally {
            if (inTransaction) {
                [self.geoPackage beginTransaction];
            }
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
    return [GPKGGeometryData createWithSrsId:self.srs.srsId andGeometry:geometry];
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
    
    if ((int) type < 0) {
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
