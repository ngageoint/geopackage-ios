//
//  GPKGCrsWktExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/3/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCrsWktExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGAlterTable.h"
#import "GPKGUtils.h"

NSString * const GPKG_CRS_WKT_EXTENSION_NAME = @"crs_wkt";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_V_1 = @"geopackage.extensions.crs_wkt";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_V_1_1 = @"geopackage.extensions.crs_wkt_1_1";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_COLUMN_NAME = @"geopackage.extensions.crs_wkt.definition.column_name";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_COLUMN_DEF = @"geopackage.extensions.crs_wkt.definition.column_def";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_EPOCH_COLUMN_NAME = @"geopackage.extensions.crs_wkt.epoch.column_name";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_EPOCH_COLUMN_DEF = @"geopackage.extensions.crs_wkt.epoch.column_def";

@interface GPKGCrsWktExtension()

@property (nonatomic, strong)  GPKGConnection * connection;

@end

@implementation GPKGCrsWktExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.connection = geoPackage.database;
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_CRS_WKT_EXTENSION_NAME];
        self.definitionV1 = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_V_1];
        self.definitionV1_1 = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_V_1_1];
        self.definitionColumnName = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_COLUMN_NAME];
        self.definitionColumnDef = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION_COLUMN_DEF];
        self.epochColumnName = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_EPOCH_COLUMN_NAME];
        self.epochColumnDef = [GPKGProperties valueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_EPOCH_COLUMN_DEF];
    }
    return self;
}

-(NSArray<GPKGExtensions *> *) extensionCreate{
    return [self extensionCreateVersion:[GPKGCrsWktExtensionVersions latest]];
}

-(NSArray<GPKGExtensions *> *) extensionCreateVersion: (enum GPKGCrsWktExtensionVersion) version{
    
    NSMutableArray<GPKGExtensions *> *extensions = [NSMutableArray array];
    
    [extensions addObject:[self extensionCreateWithName:self.extensionName andTableName:GPKG_SRS_TABLE_NAME andColumnName:self.definitionColumnName andDefinition:self.definitionV1 andScope:GPKG_EST_READ_WRITE]];
    
    if(![self hasDefinitionColumn]){
        [self createDefinitionColumn];
    }
    
    if([GPKGCrsWktExtensionVersions isVersion:version atMinimum:GPKG_CRS_WKT_V_1_1]){
        
        NSString *name = [self extensionName:version];
        [extensions addObject:[self extensionCreateWithName:name andTableName:GPKG_SRS_TABLE_NAME andColumnName:self.definitionColumnName andDefinition:self.definitionV1_1 andScope:GPKG_EST_READ_WRITE]];
        [extensions addObject:[self extensionCreateWithName:name andTableName:GPKG_SRS_TABLE_NAME andColumnName:self.epochColumnName andDefinition:self.definitionV1_1 andScope:GPKG_EST_READ_WRITE]];
        
        if(![self hasEpochColumn]){
            [self createEpochColumn];
        }
        
    }
    
    return extensions;
}

-(BOOL) has{
    
    BOOL has = NO;
    
    for(int version = 0; version <= [GPKGCrsWktExtensionVersions latest]; version++) {
        has = [self hasVersion:version];
        if(has){
            break;
        }
    }
    
    return has;
}

-(BOOL) hasMinimum: (enum GPKGCrsWktExtensionVersion) version{
    
    BOOL has = NO;
    
    for(NSNumber *ver in [GPKGCrsWktExtensionVersions atMinimum:version]){
        has = [self hasVersion:[ver intValue]];
        if(has){
            break;
        }
    }
    
    return has;
}

-(BOOL) hasVersion: (enum GPKGCrsWktExtensionVersion) version{
    
    NSString *name = [self extensionName:version];
    
    BOOL exists = [self hasWithExtensionName:name andTableName:GPKG_SRS_TABLE_NAME andColumnName:self.definitionColumnName];
    
    if(!exists && version == [GPKGCrsWktExtensionVersions first]){
        // Handle: "In (GeoPackage version) 1.1.0 and 1.2.0, the table_name
        // and column_name column values of the required gpkg_extensions row
        // were inadvertently left unspecified"
        exists = [super hasWithExtensionName:name];
    }
    
    if(exists){
        
        exists = [self hasDefinitionColumn];
        
        if(exists && [GPKGCrsWktExtensionVersions isVersion:version atMinimum:GPKG_CRS_WKT_V_1_1]){
            
            exists = [self hasWithExtensionName:name andTableName:GPKG_SRS_TABLE_NAME andColumnName:self.epochColumnName];
            
            if(exists){
             
                exists = [self hasEpochColumn];
                
            }
            
        }
        
    }
    
    return exists;
}

-(NSString *) extensionName: (enum GPKGCrsWktExtensionVersion) version{
    return [NSString stringWithFormat:@"%@%@", self.extensionName, [GPKGCrsWktExtensionVersions suffix:version]];
}

-(void) updateDefinition: (NSString *) definition withSrsId: (NSNumber *) srsId{
    [self.connection exec:[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = %@",
                           GPKG_SRS_TABLE_NAME, self.definitionColumnName, definition, GPKG_SRS_COLUMN_SRS_ID, srsId]];
}

-(NSString *) definitionWithSrsId:(NSNumber *) srsId{
    NSString *definition = (NSString *)[self.connection querySingleResultWithSql:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = ?", self.definitionColumnName, GPKG_SRS_TABLE_NAME, GPKG_SRS_COLUMN_SRS_ID]
                                                                         andArgs:[NSArray arrayWithObjects:srsId, nil]];
    return definition;
}

-(void) updateEpoch: (NSDecimalNumber *) epoch withSrsId: (NSNumber *) srsId{
    NSString *epochValue = epoch != nil ? [NSString stringWithFormat:@"%f", [epoch doubleValue]] : @"null";
    [self.connection exec:[NSString stringWithFormat:@"UPDATE %@ SET %@ = %@ WHERE %@ = %@",
                           GPKG_SRS_TABLE_NAME, self.epochColumnName, epochValue, GPKG_SRS_COLUMN_SRS_ID, srsId]];
}

-(NSDecimalNumber *) epochWithSrsId: (NSNumber *) srsId{
    NSDecimalNumber *epoch = nil;
    NSNumber *epochNumber = (NSNumber *)[self.connection querySingleResultWithSql:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = ?", self.epochColumnName, GPKG_SRS_TABLE_NAME, GPKG_SRS_COLUMN_SRS_ID]
                                                                         andArgs:[NSArray arrayWithObjects:srsId, nil]];
    if(epochNumber != nil){
        epoch = [GPKGUtils decimalNumberFromNumber:epochNumber];
    }
    return epoch;
}

/**
 *  Create the extension definition column
 */
-(void) createDefinitionColumn{
    
    [GPKGAlterTable addColumn:self.definitionColumnName withDefinition:self.definitionColumnDef toTable:GPKG_SRS_TABLE_NAME withConnection:self.connection];
    
    // Update the existing known SRS values
    [self updateDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_063] withSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_ID]];
    [self updateDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_063] withSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_ID]];
    [self updateDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_063] withSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_ID]];
    [self updateDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DEFINITION_12_063] withSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_ID]];
}

/**
 *  Create the extension epoch column
 */
-(void) createEpochColumn{
    [GPKGAlterTable addColumn:self.epochColumnName withDefinition:self.epochColumnDef toTable:GPKG_SRS_TABLE_NAME withConnection:self.connection];
}

-(BOOL) hasDefinitionColumn{
    return [self.connection columnExistsWithTableName:GPKG_SRS_TABLE_NAME andColumnName:self.definitionColumnName];
}

-(BOOL) hasEpochColumn{
    return [self.connection columnExistsWithTableName:GPKG_SRS_TABLE_NAME andColumnName:self.epochColumnName];
}

-(void) removeExtension{
    
    for(int version = 0; version <= [GPKGCrsWktExtensionVersions latest]; version++) {
        [self removeExtension:version];
    }
    
}

-(void) removeExtension: (enum GPKGCrsWktExtensionVersion) version{
    
    if([self.extensionsDao tableExists]){
        NSString *name = [self extensionName:version];
        [self.extensionsDao deleteByExtension:name];
    }
    
}

@end
