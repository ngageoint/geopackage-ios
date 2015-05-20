//
//  GPKGMetadataReference.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMetadataReference.h"

NSString * const MR_TABLE_NAME = @"gpkg_metadata_reference";
NSString * const MR_COLUMN_REFERENCE_SCOPE = @"reference_scope";
NSString * const MR_COLUMN_TABLE_NAME = @"table_name";
NSString * const MR_COLUMN_COLUMN_NAME = @"column_name";
NSString * const MR_COLUMN_ROW_ID_VALUE = @"row_id_value";
NSString * const MR_COLUMN_TIMESTAMP = @"timestamp";
NSString * const MR_COLUMN_FILE_ID = @"md_file_id";
NSString * const MR_COLUMN_PARENT_ID = @"md_parent_id";

NSString * const RST_GEOPACKAGE = @"geopackage";
NSString * const RST_TABLE = @"table";
NSString * const RST_COLUMN = @"column";
NSString * const RST_ROW = @"row";
NSString * const RST_ROW_COL = @"row/col";

@implementation GPKGMetadataReference

-(enum GPKGReferenceScopeType) getReferenceScopeType{
    enum GPKGReferenceScopeType value = -1;
    
    if(self.referenceScope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:GEOPACKAGE], RST_GEOPACKAGE,
                                    [NSNumber numberWithInteger:TABLE], RST_TABLE,
                                    [NSNumber numberWithInteger:COLUMN], RST_COLUMN,
                                    [NSNumber numberWithInteger:ROW], RST_ROW,
                                    [NSNumber numberWithInteger:ROW_COL], RST_ROW_COL,
                                    nil
                                    ];
        NSNumber *enumValue = [scopeTypes objectForKey:self.referenceScope];
        value = (enum GPKGReferenceScopeType)[enumValue intValue];
    }
    
    return value;
}

-(void) setReferenceScopeType: (enum GPKGReferenceScopeType) referenceScopeType{
    
    switch(referenceScopeType){
        case GEOPACKAGE:
            self.referenceScope = RST_GEOPACKAGE;
            self.tableName = nil;
            self.columnName = nil;
            self.rowIdValue = nil;
            break;
        case TABLE:
            self.referenceScope = RST_TABLE;
            self.columnName = nil;
            self.rowIdValue = nil;
            break;
        case ROW:
            self.referenceScope = RST_ROW;
            self.columnName = nil;
            break;
        case COLUMN:
            self.referenceScope = RST_COLUMN;
            self.rowIdValue = nil;
            break;
        case ROW_COL:
            self.referenceScope = RST_ROW_COL;
            break;
    }
    
}

-(void) setTableName:(NSString *)tableName{
    if (self.referenceScope != nil && self.tableName != nil && [self getReferenceScopeType] == GEOPACKAGE){
        [NSException raise:@"Illegal Argument" format:@"The table name must be null for %@ reference scope", RST_GEOPACKAGE];
    }
    _tableName = tableName;
}

-(void) setColumnName:(NSString *)columnName{
    if(self.referenceScope != nil && self.columnName != nil){
        enum GPKGReferenceScopeType scopeType = [self getReferenceScopeType];
        if(scopeType == GEOPACKAGE || scopeType == TABLE || scopeType == ROW){
            [NSException raise:@"Illegal Argument" format:@"The column name must be null for %@ reference scope", self.referenceScope];
        }
    }
    _columnName = columnName;
}

-(void) setRowIdValue:(NSNumber *)rowIdValue{
    if(self.referenceScope != nil && self.rowIdValue != nil){
        enum GPKGReferenceScopeType scopeType = [self getReferenceScopeType];
        if(scopeType == GEOPACKAGE || scopeType == TABLE || scopeType == COLUMN){
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
