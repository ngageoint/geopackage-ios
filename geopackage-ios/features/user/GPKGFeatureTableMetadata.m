//
//  GPKGFeatureTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureTableMetadata.h"
#import "GPKGContentsDataTypes.h"

NSString * const GPKG_FTM_DEFAULT_COLUMN_NAME = @"geometry";

@implementation GPKGFeatureTableMetadata

static enum GPKGContentsDataType defaultDataType = GPKG_CDT_FEATURES;

static enum SFGeometryType defaultGeometryType = SF_GEOMETRY;

+(GPKGFeatureTableMetadata *) create{
    return [[GPKGFeatureTableMetadata alloc] init];
}

+(GPKGFeatureTableMetadata *) createWithAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:nil andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (GPKGFeatureColumns *) columns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andBoundingBox:nil andColumns:(NSArray<GPKGFeatureColumn *> *)[columns columns]];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (GPKGFeatureColumns *) columns{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andColumns:(NSArray<GPKGFeatureColumn *> *)[columns columns]];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andTable: (GPKGFeatureTable *) table{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andBoundingBox:nil andColumns:(NSArray<GPKGFeatureColumn *> *)[table columns]];
}

+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andTable: (GPKGFeatureTable *) table{
    return [[GPKGFeatureTableMetadata alloc] initWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andColumns:(NSArray<GPKGFeatureColumn *> *)[table columns]];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:nil andIdColumn:nil andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:nil andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:nil andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:nil];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (GPKGFeatureColumns *) columns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andBoundingBox:nil andColumns:(NSArray<GPKGFeatureColumn *> *)[columns columns]];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (GPKGFeatureColumns *) columns{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andBoundingBox:boundingBox andColumns:(NSArray<GPKGFeatureColumn *> *)[columns columns]];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andTable: (GPKGFeatureTable *) table{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andBoundingBox:nil andColumns:(NSArray<GPKGFeatureColumn *> *)[table columns]];
}

+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andTable: (GPKGFeatureTable *) table{
    return [[GPKGFeatureTableMetadata alloc] initWithDataType:dataType andGeometryColumns:geometryColumns andBoundingBox:boundingBox andColumns:(NSArray<GPKGFeatureColumn *> *)[table columns]];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self initWithDataType:nil andGeometryColumns:geometryColumns andIdColumn:idColumnName andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    self = [super init];
    if(self != nil){
        self.dataType = dataType;
        self.geometryColumns = geometryColumns;
        self.idColumnName = idColumnName;
        self.additionalColumns = additionalColumns;
        self.boundingBox = boundingBox;
    }
    return self;
}

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self initWithDataType:nil andGeometryColumns:geometryColumns andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andBoundingBox:boundingBox];
}

-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    self = [super init];
    if(self != nil){
        self.dataType = dataType;
        self.geometryColumns = geometryColumns;
        self.idColumnName = idColumnName;
        self.autoincrement = autoincrement;
        self.additionalColumns = additionalColumns;
        self.boundingBox = boundingBox;
    }
    return self;
}

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (NSArray<GPKGFeatureColumn *> *) columns{
    return [self initWithDataType:nil andGeometryColumns:geometryColumns andBoundingBox:boundingBox andColumns:columns];
}

-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (NSArray<GPKGFeatureColumn *> *) columns{
    self = [super init];
    if(self != nil){
        self.dataType = dataType;
        self.geometryColumns = geometryColumns;
        self.boundingBox = boundingBox;
        self.columns = columns;
    }
    return self;
}

-(NSString *) defaultDataType{
    return [GPKGContentsDataTypes name:defaultDataType];
}

-(NSArray<GPKGUserColumn *> *) buildColumns{
    
    NSArray<GPKGUserColumn *> *featureColumns = [self columns];
    
    if(featureColumns == nil){
        
        NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
        [columns addObject:[GPKGFeatureColumn createPrimaryKeyColumnWithName:self.idColumnName andAutoincrement:[self autoincrement]]];
        [columns addObject:[GPKGFeatureColumn createGeometryColumnWithName:[self columnName] andGeometryType:[self geometryType]]];
        
        NSArray<GPKGUserColumn *> *additional = [self additionalColumns];
        if(additional != nil){
            [columns addObjectsFromArray:additional];
        }
        
         featureColumns = columns;
    }
    
    return featureColumns;
}

-(NSString *) tableName{
    NSString *tableName = nil;
    if (self.geometryColumns != nil) {
        tableName = self.geometryColumns.tableName;
    }
    if (tableName == nil) {
        tableName = super.tableName;
        if (self.geometryColumns != nil) {
            [self.geometryColumns setTableName:tableName];
        }
    }
    return tableName;
}

-(NSString *) columnName{
    NSString *columnName = nil;
    if (self.geometryColumns != nil) {
        columnName = self.geometryColumns.columnName;
    }
    if (columnName == nil) {
        columnName = GPKG_FTM_DEFAULT_COLUMN_NAME;
        if (self.geometryColumns != nil) {
            [self.geometryColumns setColumnName:columnName];
        }
    }
    return columnName;
}

-(enum SFGeometryType) geometryType{
    enum SFGeometryType geometryType = SF_NONE;
    if (self.geometryColumns != nil) {
        geometryType = [self.geometryColumns geometryType];
    }
    if (geometryType == SF_NONE) {
        geometryType = defaultGeometryType;
        if (self.geometryColumns != nil) {
            [self.geometryColumns setGeometryType:geometryType];
        }
    }
    return geometryType;
}

@end
