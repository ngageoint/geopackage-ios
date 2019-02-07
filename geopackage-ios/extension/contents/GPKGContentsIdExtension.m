//
//  GPKGContentsIdExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGContentsIdExtension.h"
#import "GPKGProperties.h"

NSString * const GPKG_EXTENSION_CONTENTS_ID_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_CONTENTS_ID_NAME_NO_AUTHOR = @"contents_id";
NSString * const GPKG_PROP_EXTENSION_CONTENTS_ID_DEFINITION = @"geopackage.extensions.contents_id";

@interface GPKGContentsIdExtension ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) GPKGContentsIdDao *contentsIdDao;

@end

@implementation GPKGContentsIdExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_CONTENTS_ID_AUTHOR andExtensionName:GPKG_EXTENSION_CONTENTS_ID_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_CONTENTS_ID_DEFINITION];
        self.contentsIdDao = [geoPackage getContentsIdDao];
    }
    return self;
}

-(GPKGContentsIdDao *) getDao{
    return self.contentsIdDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(BOOL) has{
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:nil andColumnName:nil]
        && [self.contentsIdDao tableExists];
    return exists;
}

-(GPKGContentsId *) contentsId: (GPKGResultSet *) results{
    return [self.contentsIdDao contentsId:results];
}

-(GPKGContentsId *) getForContents: (GPKGContents *) contents{
    return [self getForTableName:contents.tableName];
}

-(GPKGContentsId *) getForTableName: (NSString *) tableName{
    GPKGContentsId *contentsId = nil;
    if ([self.contentsIdDao tableExists]) {
        contentsId = [self.contentsIdDao queryForTableName:tableName];
    }
    return contentsId;
}

-(NSNumber *) getIdForContents: (GPKGContents *) contents{
    return [self getIdForTableName:contents.tableName];
}

-(NSNumber *) getIdForTableName: (NSString *) tableName{
    NSNumber *id = nil;
    GPKGContentsId *contentsId = [self getForTableName:tableName];
    if (contentsId != nil) {
        id = contentsId.id;
    }
    return id;
}

-(GPKGContentsId *) createForContents: (GPKGContents *) contents{
    return [self createForTableName:contents.tableName];
}

-(GPKGContentsId *) createForTableName: (NSString *) tableName{

    if (![self has]) {
        [self getOrCreateExtension];
    }
    
    GPKGContentsId *contentsId = [[GPKGContentsId alloc] init];
    GPKGContents *contents = [self.geoPackage contentsOfTable:tableName];
    [contentsId setContents:contents];
    [self.contentsIdDao create:contentsId];
    return contentsId;
}

-(NSNumber *) createIdForContents: (GPKGContents *) contents{
    return [self createIdForTableName:contents.tableName];
}

-(NSNumber *) createIdForTableName: (NSString *) tableName{
    GPKGContentsId *contentsId = [self createForTableName:tableName];
    return contentsId.id;
}

-(GPKGContentsId *) getOrCreateForContents: (GPKGContents *) contents{
    return [self getOrCreateForTableName:contents.tableName];
}

-(GPKGContentsId *) getOrCreateForTableName: (NSString *) tableName{
    GPKGContentsId *contentsId = [self getForTableName:tableName];
    if (contentsId == nil) {
        contentsId = [self createForTableName:tableName];
    }
    return contentsId;
}

-(NSNumber *) getOrCreateIdForContents: (GPKGContents *) contents{
    return [self getOrCreateIdForTableName:contents.tableName];
}

-(NSNumber *) getOrCreateIdForTableName: (NSString *) tableName{
    GPKGContentsId *contentsId = [self getOrCreateForTableName:tableName];
    return contentsId.id;
}

-(BOOL) deleteForContents: (GPKGContents *) contents{
    return [self deleteForTableName:contents.tableName];
}

-(BOOL) deleteForTableName: (NSString *) tableName{
    BOOL deleted = NO;
    if ([self.contentsIdDao tableExists]) {
        deleted = [self.contentsIdDao deleteByTableName:tableName] > 0;
    }
    return deleted;
}

-(int) createIds{
    return [self createIdsForTypeName:nil];
}

-(int) createIdsForType: (enum GPKGContentsDataType) type{
    return [self createIdsForTypeName:[GPKGContentsDataTypes name:type]];
}

-(int) createIdsForTypeName: (NSString *) type{

    NSArray<NSString *> *tables = [self missingForTypeName:type];
    
    for(NSString *tableName in tables){
        [self getOrCreateForTableName:tableName];
    }
    
    return (int) tables.count;
}

-(int) deleteIds{
    int deleted = 0;
    if ([self.contentsIdDao tableExists]) {
        deleted = [self.contentsIdDao deleteAll];
    }
    return deleted;
}

-(int) deleteIdsForType: (enum GPKGContentsDataType) type{
    return [self deleteIdsForTypeName:[GPKGContentsDataTypes name:type]];
}

-(int) deleteIdsForTypeName: (NSString *) type{
    int deleted = 0;
    if ([self.contentsIdDao tableExists]) {
        GPKGResultSet *contentsIds = [self idsForTypeName:type];
        if(contentsIds != nil){
            @try {
                while([contentsIds moveToNext]){
                    GPKGContentsId *contentsId = (GPKGContentsId *) [self.contentsIdDao getObject:contentsIds];
                    deleted += [self.contentsIdDao delete:contentsId];
                }
            } @finally {
                [contentsIds close];
            }
        }
    }
    return deleted;
}

-(GPKGResultSet *) ids{
    GPKGResultSet *contentsIds = nil;
    if ([self.contentsIdDao tableExists]) {
        contentsIds = [self.contentsIdDao queryForAll];
    }
    return contentsIds;
}

-(int) count{
    int count = 0;
    if ([self has]) {
        count = [self.contentsIdDao count];
    }
    return count;
}

-(GPKGResultSet *) idsForType: (enum GPKGContentsDataType) type{
    return [self idsForTypeName:[GPKGContentsDataTypes name:type]];
}

-(GPKGResultSet *) idsForTypeName: (NSString *) type{

    GPKGResultSet *contentsIds = nil;
    
    if([self.contentsIdDao tableExists]){
        
        NSString *query = [NSString stringWithFormat:@"SELECT %@.* FROM %@ INNER JOIN %@ ON %@.%@ = %@.%@ WHERE %@ = ?", GPKG_CI_TABLE_NAME, GPKG_CI_TABLE_NAME, GPKG_CON_TABLE_NAME, GPKG_CI_TABLE_NAME, GPKG_CI_COLUMN_TABLE_NAME, GPKG_CON_TABLE_NAME, GPKG_CON_COLUMN_TABLE_NAME, GPKG_CON_COLUMN_DATA_TYPE];
        contentsIds = [self.contentsIdDao rawQuery:query andArgs:[[NSArray alloc] initWithObjects:type, nil]];
        
    }
    
    return contentsIds;
}

-(NSArray<NSString *> *) missing{
    return [self missingForTypeName:nil];
}

-(NSArray<NSString *> *) missingForType: (enum GPKGContentsDataType) type{
    return [self missingForTypeName:[GPKGContentsDataTypes name:type]];
}

-(NSArray<NSString *> *) missingForTypeName: (NSString *) type{
    
    NSMutableArray<NSString *> *missing = [[NSMutableArray alloc] init];
    
    GPKGContentsDao *contentDao = [self.geoPackage getContentsDao];
    
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT %@ FROM %@", GPKG_CON_COLUMN_TABLE_NAME, GPKG_CON_TABLE_NAME];
    
    NSMutableString *where = [[NSMutableString alloc] init];
    
    NSMutableArray *queryArgs = nil;
    if(type != nil && type.length > 0){
        [where appendFormat:@"%@ = ?", GPKG_CON_COLUMN_DATA_TYPE];
        queryArgs = [[NSMutableArray alloc] initWithObjects:type, nil];
    }else{
        type = nil;
    }
    
    if([self.contentsIdDao tableExists]){
        if(where.length > 0){
            [where appendString:@" AND "];
        }
        [where appendFormat:@"%@ NOT IN (SELECT %@ FROM %@)", GPKG_CON_COLUMN_TABLE_NAME, GPKG_CI_COLUMN_TABLE_NAME, GPKG_CI_TABLE_NAME];
    }
    
    if(where.length > 0){
        [query appendFormat:@" WHERE %@", where];
    }
    
    GPKGResultSet *results = [contentDao rawQuery:query andArgs:queryArgs];
    @try {
        while([results moveToNext]){
            [missing addObject:[results getString:0]];
        }
    } @finally {
        [results close];
    }
    
    return missing;
}

-(GPKGExtensions *) getOrCreateExtension{
    
    // Create table
    [self.geoPackage createContentsIdTable];
    
    GPKGExtensions *extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:nil andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(GPKGExtensions *) getExtension{
    GPKGExtensions *extension = [self getWithExtensionName:self.extensionName andTableName:nil andColumnName:nil];
    return extension;
}

-(void) removeExtension{
    
    if([self.contentsIdDao tableExists]){
        [self.geoPackage dropTable:self.contentsIdDao.tableName];
    }
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }
    
}

@end
