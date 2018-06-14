//
//  GPKGRelatedTablesExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedTablesExtension.h"
#import "GPKGProperties.h"

NSString * const GPKG_EXTENSION_RELATED_TABLES_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR = @"related_tables";
NSString * const GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION = @"geopackage.extensions.extended_relations";

@interface GPKGRelatedTablesExtension ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) GPKGExtendedRelationsDao *extendedRelationsDao;

@end

@implementation GPKGRelatedTablesExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_RELATED_TABLES_AUTHOR andExtensionName:GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION];
        self.extendedRelationsDao = [geoPackage getExtendedRelationsDao];
    }
    return self;
}

-(GPKGExtendedRelationsDao *) getExtendedRelationsDao{
    return self.extendedRelationsDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(GPKGExtensions *) getOrCreateExtension{
    
    // Create table
    [self.geoPackage createExtendedRelationsTable];
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(GPKGExtensions *) getOrCreateExtensionWithMappingTable: (NSString *) mappingTable{
    
    [self getOrCreateExtension];
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:mappingTable andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:nil];
}

-(BOOL) hasWithMappingTable: (NSString *) mappingTable{
    return [self has] && [self hasWithExtensionName:self.extensionName andTableName:mappingTable andColumnName:nil];
}


-(NSString *) primaryKeyColumnNameOfTable: (NSString *) tableName{
    return nil; // TODO
}

-(void) setContentsInTable: (GPKGUserRelatedTable *) table{
    GPKGContentsDao *dao = [self.geoPackage getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:table.tableName];
    if(contents == nil){
        [NSException raise:@"No Contents Table" format:@"No Contents Table exists for table name: %@", table.tableName];
    }
    [table setContents:contents];
}

// TODO

@end
