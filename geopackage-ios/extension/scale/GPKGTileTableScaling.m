//
//  GPKGTileTableScaling.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileTableScaling.h"
#import "GPKGProperties.h"

NSString * const GPKG_EXTENSION_TILE_SCALING_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR = @"tile_scaling";
NSString * const GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION = @"geopackage.extensions.tile_scaling";

@interface GPKGTileTableScaling ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) GPKGTileScalingDao *tileScalingDao;

@end

@implementation GPKGTileTableScaling

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    return [self initWithGeoPackage:geoPackage andTableName:tileMatrixSet.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    return [self initWithGeoPackage:geoPackage andTableName:tileMatrix.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao{
    return [self initWithGeoPackage:geoPackage andTableName:tileDao.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION];
        self.tableName = tableName;
        self.tileScalingDao = [geoPackage getTileScalingDao];
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{
    return self.geoPackage;
}

-(NSString *) getTableName{
    return self.tableName;
}

-(GPKGTileScalingDao *) getDao{
    return self.tileScalingDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:nil]
        && [self.tileScalingDao tableExists]
        && [self.tileScalingDao idExists:self.tableName];
    
    return exists;
}

-(GPKGTileScaling *) get{
    GPKGTileScaling *tileScaling = nil;
    if([self has]){
        tileScaling = (GPKGTileScaling *)[self.tileScalingDao queryForIdObject:self.tableName];
    }
    return tileScaling;
}

-(void) create: (GPKGTileScaling *) tileScaling{
    [self createOrUpdate:tileScaling];
}

-(void) update: (GPKGTileScaling *) tileScaling{
    [self createOrUpdate:tileScaling];
}

-(void) createOrUpdate: (GPKGTileScaling *) tileScaling{
    
    [tileScaling setTableName:self.tableName];
    
    [self getOrCreateExtension];
    if(![self.tileScalingDao tableExists]){
        [self.geoPackage createTileScalingTable];
    }
    
    [self.tileScalingDao createOrUpdate:tileScaling];
}

-(BOOL) delete{
    
    BOOL deleted = NO;
    
    GPKGExtensionsDao *extensionsDao = [self.geoPackage getExtensionsDao];
    if([self.tileScalingDao tableExists]){
        deleted = [self.tileScalingDao deleteById:self.tableName] > 0;
    }
    if([extensionsDao tableExists]){
        deleted = [extensionsDao deleteByExtension:self.extensionName andTable:self.tableName] > 0 || deleted;
    }

    return deleted;
}

-(GPKGExtensions *) getOrCreateExtension{
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    return extension;
}

-(GPKGExtensions *) getExtension{
    GPKGExtensions * extension = [self getWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:nil];
    return extension;
}

@end
