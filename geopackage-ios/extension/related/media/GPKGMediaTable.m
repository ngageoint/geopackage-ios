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

+(GPKGMediaTable *) createWithName: (NSString *) tableName{
    return [self createWithName:tableName andIdColumnName:nil andAdditionalColumns:nil];
}

+(GPKGMediaTable *) createWithName: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    return [self createWithName:tableName andIdColumnName:nil andAdditionalColumns:additionalColumns];
}

+(GPKGMediaTable *) createWithName: (NSString *) tableName andIdColumnName: (NSString *) idColumnName{
    return [self createWithName:tableName andIdColumnName:idColumnName andAdditionalColumns:nil];
}

+(GPKGMediaTable *) createWithName: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObjectsFromArray:[self createRequiredColumnsWithIdColumnName:idColumnName]];
    
    if(additionalColumns != nil){
        [columns addObjectsFromArray:additionalColumns];
    }
    
    return [[GPKGMediaTable alloc] initWithTable:tableName andColumns:columns andIdColumnName:idColumnName];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns{
    return [self createRequiredColumnsWithIndex:0];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName{
    return [self createRequiredColumnsWithIndex:0 andIdColumnName:idColumnName];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex{
    return [self createRequiredColumnsWithIndex:startingIndex andIdColumnName:nil];
}

+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName{
    
    if(idColumnName == nil){
        idColumnName = GPKG_RMT_COLUMN_ID;
    }
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObject:[self createIdColumnWithIndex:startingIndex++ andName:idColumnName]];
    [columns addObject:[self createDataColumnWithIndex:startingIndex++]];
    [columns addObject:[self createContentTypeColumnWithIndex:startingIndex++]];
    
    return columns;
}

+(GPKGUserCustomColumn *) createIdColumnWithIndex: (int) index andName: (NSString *) idColumnName{
    return [GPKGUserCustomColumn createPrimaryKeyColumnWithIndex:index andName:idColumnName];
}

+(GPKGUserCustomColumn *) createDataColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_RMT_COLUMN_DATA andDataType:GPKG_DT_BLOB andNotNull:YES andDefaultValue:nil];
}

+(GPKGUserCustomColumn *) createContentTypeColumnWithIndex: (int) index{
    return [GPKGUserCustomColumn createColumnWithIndex:index andName:GPKG_RMT_COLUMN_CONTENT_TYPE andDataType:GPKG_DT_TEXT andNotNull:YES andDefaultValue:nil];
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
    return self.pkIndex;
}

-(GPKGUserCustomColumn *) idColumn{
    return (GPKGUserCustomColumn *)[self getPkColumn];
}

-(int) dataColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_RMT_COLUMN_DATA];
}

-(GPKGUserCustomColumn *) dataColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_RMT_COLUMN_DATA];
}

-(int) contentTypeColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_RMT_COLUMN_CONTENT_TYPE];
}

-(GPKGUserCustomColumn *) contentTypeColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_RMT_COLUMN_CONTENT_TYPE];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGMediaTable *mediaTable = [super mutableCopyWithZone:zone];
    return mediaTable;
}

@end
