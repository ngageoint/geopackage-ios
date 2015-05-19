//
//  GPKGMetadataReference.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMetadata.h"

extern NSString * const MR_TABLE_NAME;
extern NSString * const MR_COLUMN_REFERENCE_SCOPE;
extern NSString * const MR_COLUMN_TABLE_NAME;
extern NSString * const MR_COLUMN_COLUMN_NAME;
extern NSString * const MR_COLUMN_ROW_ID_VALUE;
extern NSString * const MR_COLUMN_TIMESTAMP;
extern NSString * const MR_COLUMN_FILE_ID;
extern NSString * const MR_COLUMN_PARENT_ID;

enum GPKGReferenceScopeType{
    GEOPACKAGE,
    TABLE,
    COLUMN,
    ROW,
    ROW_COL
};

extern NSString * const RST_GEOPACKAGE;
extern NSString * const RST_TABLE;
extern NSString * const RST_COLUMN;
extern NSString * const RST_ROW;
extern NSString * const RST_ROW_COL;

@interface GPKGMetadataReference : NSObject

@property (nonatomic, strong) NSString *referenceScope;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSNumber *rowIdValue;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSNumber *fileId;
@property (nonatomic, strong) NSNumber *parentId;

-(enum GPKGReferenceScopeType) getReferenceScopeType;

-(void) setReferenceScopeType: (enum GPKGReferenceScopeType) referenceScopeType;

-(void) setTableName:(NSString *)tableName;

-(void) setColumnName:(NSString *)columnName;

-(void) setRowIdValue:(NSNumber *)rowIdValue;

-(void) setMetadata:(GPKGMetadata *) metadata;

-(void) setParentMetadata:(GPKGMetadata *) metadata;

@end
