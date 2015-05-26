//
//  GPKGExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GPKG_EX_EXTENSION_NAME_DIVIDER;
extern NSString * const GPKG_EX_TABLE_NAME;
extern NSString * const GPKG_EX_COLUMN_TABLE_NAME;
extern NSString * const GPKG_EX_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_EX_COLUMN_EXTENSION_NAME;
extern NSString * const GPKG_EX_COLUMN_DEFINITION;
extern NSString * const GPKG_EX_COLUMN_SCOPE;

enum GPKGExtensionScopeType{
    GPKG_EST_READ_WRITE,
    GPKG_EST_WRITE_ONLY
};

extern NSString * const GPKG_EST_READ_WRITE_NAME;
extern NSString * const GPKG_EST_WRITE_ONLY_NAME;

@interface GPKGExtensions : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *definition;
@property (nonatomic, strong) NSString *scope;

-(enum GPKGExtensionScopeType) getExtensionScopeType;

-(void) setExtensionScopeType: (enum GPKGExtensionScopeType) extensionScopeType;

-(void) setTableName:(NSString *)tableName;

-(void) setExtensionNameWithAuthor: (NSString *) author andExtensionName: (NSString *) extensionName;

-(NSString *) getAuthor;

-(NSString *) getExtensionNameNoAuthor;

@end
