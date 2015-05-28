//
//  GPKGMetadataReference.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMetadataReference.h"
#import "GPKGUtils.h"

NSString * const GPKG_MR_TABLE_NAME = @"gpkg_metadata_reference";
NSString * const GPKG_MR_COLUMN_REFERENCE_SCOPE = @"reference_scope";
NSString * const GPKG_MR_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_MR_COLUMN_COLUMN_NAME = @"column_name";
NSString * const GPKG_MR_COLUMN_ROW_ID_VALUE = @"row_id_value";
NSString * const GPKG_MR_COLUMN_TIMESTAMP = @"timestamp";
NSString * const GPKG_MR_COLUMN_FILE_ID = @"md_file_id";
NSString * const GPKG_MR_COLUMN_PARENT_ID = @"md_parent_id";

NSString * const GPKG_RST_GEOPACKAGE_NAME = @"geopackage";
NSString * const GPKG_RST_TABLE_NAME = @"table";
NSString * const GPKG_RST_COLUMN_NAME = @"column";
NSString * const GPKG_RST_ROW_NAME = @"row";
NSString * const GPKG_RST_ROW_COL_NAME = @"row/col";

@implementation GPKGMetadataReference

-(enum GPKGReferenceScopeType) getReferenceScopeType{
    enum GPKGReferenceScopeType value = -1;
    
    if(self.referenceScope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:GPKG_RST_GEOPACKAGE], GPKG_RST_GEOPACKAGE_NAME,
                                    [NSNumber numberWithInteger:GPKG_RST_TABLE], GPKG_RST_TABLE_NAME,
                                    [NSNumber numberWithInteger:GPKG_RST_COLUMN], GPKG_RST_COLUMN_NAME,
                                    [NSNumber numberWithInteger:GPKG_RST_ROW], GPKG_RST_ROW_NAME,
                                    [NSNumber numberWithInteger:GPKG_RST_ROW_COL], GPKG_RST_ROW_COL_NAME,
                                    nil
                                    ];
        NSNumber *enumValue = [GPKGUtils objectForKey:self.referenceScope inDictionary:scopeTypes];
        value = (enum GPKGReferenceScopeType)[enumValue intValue];
    }
    
    return value;
}

-(void) setReferenceScopeType: (enum GPKGReferenceScopeType) referenceScopeType{
    
    switch(referenceScopeType){
        case GPKG_RST_GEOPACKAGE:
            self.referenceScope = GPKG_RST_GEOPACKAGE_NAME;
            self.tableName = nil;
            self.columnName = nil;
            self.rowIdValue = nil;
            break;
        case GPKG_RST_TABLE:
            self.referenceScope = GPKG_RST_TABLE_NAME;
            self.columnName = nil;
            self.rowIdValue = nil;
            break;
        case GPKG_RST_ROW:
            self.referenceScope = GPKG_RST_ROW_NAME;
            self.columnName = nil;
            break;
        case GPKG_RST_COLUMN:
            self.referenceScope = GPKG_RST_COLUMN_NAME;
            self.rowIdValue = nil;
            break;
        case GPKG_RST_ROW_COL:
            self.referenceScope = GPKG_RST_ROW_COL_NAME;
            break;
    }
    
}

-(void) setTableName:(NSString *)tableName{
    if (self.referenceScope != nil && self.tableName != nil && [self getReferenceScopeType] == GPKG_RST_GEOPACKAGE){
        [NSException raise:@"Illegal Argument" format:@"The table name must be null for %@ reference scope", GPKG_RST_GEOPACKAGE_NAME];
    }
    _tableName = tableName;
}

-(void) setColumnName:(NSString *)columnName{
    if(self.referenceScope != nil && self.columnName != nil){
        enum GPKGReferenceScopeType scopeType = [self getReferenceScopeType];
        if(scopeType == GPKG_RST_GEOPACKAGE || scopeType == GPKG_RST_TABLE || scopeType == GPKG_RST_ROW){
            [NSException raise:@"Illegal Argument" format:@"The column name must be null for %@ reference scope", self.referenceScope];
        }
    }
    _columnName = columnName;
}

-(void) setRowIdValue:(NSNumber *)rowIdValue{
    if(self.referenceScope != nil && self.rowIdValue != nil){
        enum GPKGReferenceScopeType scopeType = [self getReferenceScopeType];
        if(scopeType == GPKG_RST_GEOPACKAGE || scopeType == GPKG_RST_TABLE || scopeType == GPKG_RST_COLUMN){
            [NSException raise:@"Illegal Argument" format:@"The row id must be null for %@ reference scope", self.referenceScope];
        }
    }
    _rowIdValue = rowIdValue;
}

-(void) setMetadata:(GPKGMetadata *) metadata{
    if(metadata != nil){
        self.fileId = metadata.id;
    }else{
        self.fileId = [NSNumber numberWithInt:-1];
    }
}

-(void) setParentMetadata:(GPKGMetadata *) metadata{
    if(metadata != nil){
        self.parentId = metadata.id;
    }else{
        self.parentId = [NSNumber numberWithInt:-1];
    }
}

@end
