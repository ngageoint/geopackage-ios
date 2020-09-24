//
//  GPKGSchemaExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGSchemaExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGDataColumns.h"

NSString * const GPKG_SCHEMA_EXTENSION_NAME = @"schema";
NSString * const GPKG_PROP_SCHEMA_EXTENSION_DEFINITION = @"geopackage.extensions.schema";

@implementation GPKGSchemaExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_SCHEMA_EXTENSION_NAME];
        self.definition = [GPKGProperties valueOfProperty:GPKG_PROP_SCHEMA_EXTENSION_DEFINITION];
    }
    return self;
}

-(NSArray<GPKGExtensions *> *) extensionCreate{
    
    NSMutableArray<GPKGExtensions *> *extensions = [[NSMutableArray alloc] init];
    
    [extensions addObject:[self extensionCreateWithName:self.extensionName andTableName:GPKG_DC_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE]];
    [extensions addObject:[self extensionCreateWithName:self.extensionName andTableName:GPKG_DCC_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE]];
    
    return extensions;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName];
    
    return exists;
}

-(void) removeExtension{
    
    if([self.geoPackage isTable:GPKG_DC_TABLE_NAME]){
        [self.geoPackage dropTable:GPKG_DC_TABLE_NAME];
    }
    
    if([self.geoPackage isTable:GPKG_DCC_TABLE_NAME]){
        [self.geoPackage dropTable:GPKG_DCC_TABLE_NAME];
    }
    
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }
    
}

-(GPKGDataColumnsDao *) dataColumnsDao{
    return [GPKGSchemaExtension dataColumnsDaoWithGeoPackage:self.geoPackage];
}

+(GPKGDataColumnsDao *) dataColumnsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [GPKGDataColumnsDao createWithGeoPackage:geoPackage];
}

+(GPKGDataColumnsDao *) dataColumnsDaoWithDatabase: (GPKGConnection *) database{
    return [GPKGDataColumnsDao createWithDatabase:database];
}

-(BOOL) createDataColumnsTable{
    [self verifyWritable];
    
    BOOL created = NO;
    GPKGDataColumnsDao *dao = [self dataColumnsDao];
    if(![dao tableExists]){
        created = [[self.geoPackage tableCreator] createDataColumns] > 0;
    }
    
    return created;
}

-(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDao{
    return [GPKGSchemaExtension dataColumnConstraintsDaoWithGeoPackage:self.geoPackage];
}

+(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [GPKGDataColumnConstraintsDao createWithGeoPackage:geoPackage];
}

+(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDaoWithDatabase: (GPKGConnection *) database{
    return [GPKGDataColumnConstraintsDao createWithDatabase:database];
}

-(BOOL) createDataColumnConstraintsTable{
    [self verifyWritable];
    
    BOOL created = NO;
    GPKGDataColumnConstraintsDao *dao = [self dataColumnConstraintsDao];
    if(![dao tableExists]){
        created = [[self.geoPackage tableCreator] createDataColumnConstraints] > 0;
        if(created){
            [self extensionCreate];
        }
    }
    
    return created;
}

@end
