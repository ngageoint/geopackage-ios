//
//  GPKGMediaTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGMediaTable.h"

NSString * const GPKG_RMT_COLUMN_ID = @"id";
NSString * const GPKG_RMT_COLUMN_DATA = @"data";
NSString * const GPKG_RMT_COLUMN_CONTENT_TYPE = @"content_type";

@implementation GPKGMediaTable

+(enum GPKGRelationType) relationType{
    return GPKG_RT_MEDIA;
}

+(GPKGMediaTable *) createWithMetadata: (GPKGMediaTableMetadata *) metadata{
    NSArray<GPKGUserColumn *> *columns = [metadata buildColumns];
    return [[GPKGMediaTable alloc] initWithTable:metadata.tableName andColumns:columns andIdColumnName:[metadata idColumnName]];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns{
    return [self createRequiredColumnsWithAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithAutoincrement: (BOOL) autoincrement{
    return [self createRequiredColumnsWithIdColumnName:nil andAutoincrement:autoincrement];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName{
    return [self createRequiredColumnsWithIdColumnName:idColumnName andAutoincrement:autoincrement];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RMT_COLUMN_ID;
    }
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createIdColumnWithName:idColumnName andAutoincrement:autoincrement]];
    [columns addObject:[self createDataColumn]];
    [columns addObject:[self createContentTypeColumn]];
    
    return columns;
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex{
    return [self createRequiredColumnsWithIndex:startingIndex andAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andAutoincrement: (BOOL) autoincrement{
    return [self createRequiredColumnsWithIndex:startingIndex andIdColumnName:nil andAutoincrement:autoincrement];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName{
    return [self createRequiredColumnsWithIndex:startingIndex andIdColumnName:idColumnName andAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RMT_COLUMN_ID;
    }
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createIdColumnWithIndex:startingIndex++ andName:idColumnName andAutoincrement:autoincrement]];
    [columns addObject:[self createDataColumnWithIndex:startingIndex++]];
    [columns addObject:[self createContentTypeColumnWithIndex:startingIndex++]];
    
    return columns;
}

+(GPKGUserCustomColumn *) createIdColumnWithName: (NSString *) idColumnName{
    return [GPKGUserCustomColumn createPrimaryKeyColumnWithName:idColumnName];
}

// TODO

+(GPKGUserCustomColumn *) createIdColumnWithIndex: (int) index andName: (NSString *) idColumnName{
    return [GPKGUserCustomColumn createPrimaryKeyColumnWithIndex:index andName:idColumnName];
}

+(GPKGUserCustomColumn *) createDataColumn{
    return [self createDataColumnWithIndex:NO_INDEX];
}

+(GPKGUserCustomColumn *) createDataColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_RMT_COLUMN_DATA andDataType:GPKG_DT_BLOB andNotNull:YES];
}

+(GPKGUserCustomColumn *) createContentTypeColumn{
    return [self createContentTypeColumnWithIndex:NO_INDEX];
}

+(GPKGUserCustomColumn *) createContentTypeColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_RMT_COLUMN_CONTENT_TYPE andDataType:GPKG_DT_TEXT andNotNull:YES];
}

+(int) numRequiredColumns{
    return (int)[self requiredColumns].count;
}

+(NSArray<NSString *> *) requiredColumns{
    return [self requiredColumnsWithIdColumnName:nil];
}

+(NSArray<NSString *> *) requiredColumnsWithIdColumnName: (NSString *) idColumnName{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RMT_COLUMN_ID;
    }
    
    NSMutableArray<NSString *> *requiredColumns = [[NSMutableArray alloc] init];
    [requiredColumns addObject:idColumnName];
    [requiredColumns addObject:GPKG_RMT_COLUMN_DATA];
    [requiredColumns addObject:GPKG_RMT_COLUMN_CONTENT_TYPE];
    return requiredColumns;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andColumns:columns andIdColumnName:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andIdColumnName: (NSString *) idColumnName{
    self = [super initWithTable:tableName andRelation:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andDataType:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]] andColumns:columns andRequiredColumns:[GPKGMediaTable requiredColumnsWithIdColumnName:idColumnName]];
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithRelation:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andDataType:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]] andCustomTable:table];
    return self;
}

-(int) idColumnIndex{
    return [self pkIndex];
}

-(GPKGUserCustomColumn *) idColumn{
    return (GPKGUserCustomColumn *)[self pkColumn];
}

-(int) dataColumnIndex{
    return [self columnIndexWithColumnName:GPKG_RMT_COLUMN_DATA];
}

-(GPKGUserCustomColumn *) dataColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_RMT_COLUMN_DATA];
}

-(int) contentTypeColumnIndex{
    return [self columnIndexWithColumnName:GPKG_RMT_COLUMN_CONTENT_TYPE];
}

-(GPKGUserCustomColumn *) contentTypeColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_RMT_COLUMN_CONTENT_TYPE];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGMediaTable *mediaTable = [super mutableCopyWithZone:zone];
    return mediaTable;
}

@end
