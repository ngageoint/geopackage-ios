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

NSString * const GPKG_CRS_WKT_EXTENSION_NAME = @"crs_wkt";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION = @"geopackage.extensions.crs_wkt";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_COLUMN_NAME = @"geopackage.extensions.crs_wkt.column_name";
NSString * const GPKG_PROP_CRS_WKT_EXTENSION_COLUMN_DEF = @"geopackage.extensions.crs_wkt.column_def";

@interface GPKGCrsWktExtension()

@property (nonatomic, strong)  GPKGConnection * connection;

@end

@implementation GPKGCrsWktExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.connection = geoPackage.database;
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_CRS_WKT_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_DEFINITION];
        self.columnName = [GPKGProperties getValueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_COLUMN_NAME];
        self.columnDef = [GPKGProperties getValueOfProperty:GPKG_PROP_CRS_WKT_EXTENSION_COLUMN_DEF];
    }
    return self;
}

-(GPKGExtensions *) getOrCreate{
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:nil andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    
    if(![self hasColumn]){
        [self createColumn];
    }
    
    return extension;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:nil andColumnName:nil];
    
    if(exists){
        exists = [self hasColumn];
    }
    
    return exists;
}

-(void) updateDefinitionWithSrsId:(NSNumber *) srsId andDefinition:(NSString *) definition{
    [self.connection exec:[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = %@",
                           GPKG_SRS_TABLE_NAME, self.columnName, definition, GPKG_SRS_COLUMN_SRS_ID, srsId]];
}

-(NSString *) getDefinitionWithSrsId:(NSNumber *) srsId{
    NSString *definition = (NSString *)[self.connection querySingleResultWithSql:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = ?", self.columnName, GPKG_SRS_TABLE_NAME, GPKG_SRS_COLUMN_SRS_ID]
                                                                    andArgs:[NSArray arrayWithObjects:srsId, nil]];
    return definition;
}

-(void) removeExtension{
    
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }
    
}

/**
 *  Create the extension column
 */
-(void) createColumn{
    
    [GPKGAlterTable addColumn:self.columnName withDefinition:self.columnDef toTable:GPKG_SRS_TABLE_NAME withConnection:self.connection];
    
    // Update the existing known SRS values
    [self updateDefinitionWithSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_ID]
                      andDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [self updateDefinitionWithSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_ID]
                      andDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [self updateDefinitionWithSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_ID]
                      andDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [self updateDefinitionWithSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_ID]
                      andDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
}

/**
 *  Determine if the GeoPackage SRS table has the extension column
 *
 *  @return true if has column
 */
-(BOOL) hasColumn{
    BOOL exists = [self.connection columnExistsWithTableName:GPKG_SRS_TABLE_NAME andColumnName:self.columnName];
    return exists;
}

@end
