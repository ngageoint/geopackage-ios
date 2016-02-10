//
//  GPKGFeatureTileTableLinker.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileTableLinker.h"
#import "GPKGExtensions.h"
#import "GPKGProperties.h"

NSString * const GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR = @"feature_tile_link";
NSString * const GPKG_PROP_EXTENSION_FEATURE_TILE_LINK_DEFINITION = @"geopackage.extensions.feature_tile_link";

@interface GPKGFeatureTileTableLinker ()

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) GPKGExtensionsDao *extensionsDao;
@property (nonatomic, strong) GPKGFeatureTileLinkDao *featureTileLinkDao;

@end

@implementation GPKGFeatureTileTableLinker

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super init];
    if(self != nil){
        self.geoPackage = geoPackage;
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_FEATURE_TILE_LINK_DEFINITION];
        self.extensionsDao = [geoPackage getExtensionsDao];
        self.featureTileLinkDao = [geoPackage getFeatureTileLinkDao];
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{
    return self.geoPackage;
}

-(GPKGFeatureTileLinkDao *) getDao{
    return self.featureTileLinkDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(void) linkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    
    if(![self isLinkedWithFeatureTable:featureTable andTileTable:tileTable]){
        [self getOrCreateExtension];
        
        if(![self.featureTileLinkDao tableExists]){
            [self.geoPackage createFeatureTileLinkTable];
        }
        
        GPKGFeatureTileLink * link = [[GPKGFeatureTileLink alloc] init];
        [link setFeatureTableName:featureTable];
        [link setTileTableName:tileTable];
        
        [self.featureTileLinkDao create:link];
    }

}

-(BOOL) isLinkedWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    GPKGFeatureTileLink * link = [self getLinkWithFeatureTable:featureTable andTileTable:tileTable];
    return link != nil;
}

-(GPKGFeatureTileLink *) getLinkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    GPKGFeatureTileLink * link = nil;
    
    if([self featureTileLinksActive]){
        link = [self.featureTileLinkDao queryForFeatureTable:featureTable andTileTable:tileTable];
    }
    
    return link;
}

-(GPKGResultSet *) queryForFeatureTable: (NSString *) featureTable{
    
    GPKGResultSet * links = nil;
    
    if([self featureTileLinksActive]){
        links = [self.featureTileLinkDao queryForFeatureTableName:featureTable];
    }
    
    return links;
}

-(GPKGResultSet *) queryForTileTable: (NSString *) tileTable{
    
    GPKGResultSet * links = nil;
    
    if([self featureTileLinksActive]){
        links = [self.featureTileLinkDao queryForTileTableName:tileTable];
    }
    
    return links;
}

-(BOOL) deleteLinkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    
    BOOL deleted = false;
    
    if([self.featureTileLinkDao tableExists]){
        deleted = [self.featureTileLinkDao deleteByFeatureTable:featureTable andTileTable:tileTable] > 0;
    }
    
    return deleted;
}

-(int) deleteLinksWithTable: (NSString *) table{
    
    int deleted = 0;
    
    if([self.featureTileLinkDao tableExists]){
        deleted = [self.featureTileLinkDao deleteByTableName:table];
    }
    
    return deleted;
}

-(GPKGExtensions *) getOrCreateExtension{
    GPKGExtensions * extension = [self getExtension];
    
    if(extension == nil){
        if(![self.extensionsDao tableExists]){
            [self.geoPackage createExtensionsTable];
        }
        
        extension = [[GPKGExtensions alloc] init];
        [extension setTableName:nil];
        [extension setColumnName:nil];
        [extension setExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR];
        [extension setDefinition:self.extensionDefinition];
        [extension setExtensionScopeType:GPKG_EST_READ_WRITE];
        
        [self.extensionsDao create:extension];
    }
    
    return extension;
}

-(GPKGExtensions *) getExtension{
    
    GPKGExtensions * extension = nil;
    if([self.extensionsDao tableExists]){
        extension = [self.extensionsDao queryByExtension:self.extensionName andTable:nil andColumnName:nil];
    }
    return extension;
}

-(BOOL) featureTileLinksActive{
    
    BOOL active = false;
    
    if([self getExtension] != nil){
        active = [self.featureTileLinkDao tableExists];
    }
    
    return active;
}

-(GPKGFeatureTileLink *) getLinkFromResultSet: (GPKGResultSet *) results{
    return (GPKGFeatureTileLink *)[self.featureTileLinkDao getObject:results];
}

-(NSArray<NSString *> *) getTileTablesForFeatureTable: (NSString *) featureTable{
    
    NSMutableArray<NSString *> * tileTables = [[NSMutableArray alloc] init];
    
    GPKGResultSet * results = [self queryForFeatureTable:featureTable];
    @try {
        while([results moveToNext]){
            GPKGFeatureTileLink * link = [self getLinkFromResultSet:results];
            [tileTables addObject:link.tileTableName];
        }
    }
    @finally {
        [results close];
    }
    
    return tileTables;
}

-(NSArray<NSString *> *) getFeatureTablesForTileTable: (NSString *) tileTable{
    
    NSMutableArray<NSString *> * featureTables = [[NSMutableArray alloc] init];
    
    GPKGResultSet * results = [self queryForTileTable:tileTable];
    @try {
        while([results moveToNext]){
            GPKGFeatureTileLink * link = [self getLinkFromResultSet:results];
            [featureTables addObject:link.featureTableName];
        }
    }
    @finally {
        [results close];
    }
    
    return featureTables;
}

-(NSArray<GPKGTileDao *> *) getTileDaosForFeatureTable: (NSString *) featureTable{
    
    NSMutableArray<GPKGTileDao *> * tileDaos = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> * tileTables = [self getTileTablesForFeatureTable:featureTable];
    for(NSString * tileTable in tileTables){
        GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileTable];
        [tileDaos addObject:tileDao];
    }
    
    return tileDaos;
}

-(NSArray<GPKGFeatureDao *> *) getFeatureDaosForTileTable: (NSString *) tileTable{
    
    NSMutableArray<GPKGFeatureDao *> * featureDaos = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> * featureTables = [self getFeatureTablesForTileTable:tileTable];
    for(NSString * featureTable in featureTables){
        GPKGFeatureDao * featureDao = [self.geoPackage getFeatureDaoWithTableName:featureTable];
        [featureDaos addObject:featureDao];
    }
    
    return featureDaos;
}

@end
