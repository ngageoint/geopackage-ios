//
//  GPKGTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"
#import "GPKGGeometryColumns.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileMatrix.h"
#import "GPKGDataColumns.h"
#import "GPKGDataColumnConstraints.h"
#import "GPKGMetadata.h"
#import "GPKGMetadataReference.h"
#import "GPKGExtensions.h"

@interface GPKGTableCreator()

@property (nonatomic) GPKGConnection *db;

@end

@implementation GPKGTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db{
    self = [super init];
    if(self){
        self.db = db;
    }
    return self;
}

-(int) createSpatialReferenceSystem{
    return [self createTable:GPKG_SRS_TABLE_NAME];
}

-(int) createContents{
    return [self createTable:GPKG_CON_TABLE_NAME];
}

-(int) createGeometryColumns{
    return [self createTable:GPKG_GC_TABLE_NAME];
}

-(int) createTileMatrixSet{
    return [self createTable:GPKG_TMS_TABLE_NAME];
}

-(int) createTileMatrix{
    return [self createTable:GPKG_TM_TABLE_NAME];
}

-(int) createDataColumns{
    return [self createTable:GPKG_DC_TABLE_NAME];
}

-(int) createDataColumnConstraints{
    return [self createTable:GPKG_DCC_TABLE_NAME];
}

-(int) createMetadata{
    return [self createTable:GPKG_M_TABLE_NAME];
}

-(int) createMetadataReference{
    return [self createTable:GPKG_MR_TABLE_NAME];
}

-(int) createExtensions{
    return [self createTable:GPKG_EX_TABLE_NAME];
}

-(int) createTable: (NSString *) tableName{
    
    NSString * resource = [NSString stringWithFormat:@"%@/%@", GPKG_GEO_PACKAGE_BUNDLE_NAME, GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    NSString *tablesPlistPath = [[NSBundle mainBundle] pathForResource:resource ofType:GPKG_GEO_PACKAGE_RESOURCES_TABLES_TYPE];
    if(tablesPlistPath == nil){
        resource = GPKG_GEO_PACKAGE_RESOURCES_TABLES;
        tablesPlistPath = [[NSBundle mainBundle] pathForResource:resource ofType:GPKG_GEO_PACKAGE_RESOURCES_TABLES_TYPE];
    }
    if(tablesPlistPath == nil){
        [NSException raise:@"Table Creation" format:@"Failed to read tables resource: %@, type: %@", GPKG_GEO_PACKAGE_RESOURCES_TABLES, GPKG_GEO_PACKAGE_RESOURCES_TABLES_TYPE];
    }
    NSDictionary *tables = [NSDictionary dictionaryWithContentsOfFile:tablesPlistPath];
    NSArray *statements = [tables objectForKey:tableName];
    if(statements == nil){
        [NSException raise:@"Table Creation" format:@"Failed to find table creation statements for table: %@, in resource: %@", tableName, resource];
    }
    
    for(NSString * statement in statements){
        [self.db exec:statement];
    }
    return (int)[statements count];
}

-(void) createUserTable: (GPKGUserTable *) table{
    
    // Verify the table does not already exist
    if([self.db tableExists:table.tableName]){
        [NSException raise:@"Table Creation" format:@"Table already exists and can not be created: %@", table.tableName];
    }
    
    // Build the create table sql
    NSMutableString * sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"create table %@ (", table.tableName];
    
    // Add each column to the sql
    NSArray * columns = [table columns];
    for(int i = 0; i < [columns count]; i++){
        GPKGUserColumn *column = [columns objectAtIndex:i];
        if(i > 0){
            [sql appendString:@","];
        }
        [sql appendFormat:@"\n %@ %@", column.name, [GPKGDataTypes name:column.dataType]];
        if(column.max != nil){
            [sql appendFormat:@"(%@)", column.max];
        }
        if(column.notNull){
            [sql appendString:@" not null"];
        }
        if(column.primaryKey){
            [sql appendString:@" primary key autoincrement"];
        }
    }
    
    // Add unique constraints
    NSArray * uniqueConstraints = [table uniqueConstraints];
    for(int i = 0; i < [uniqueConstraints count]; i++){
        GPKGUserUniqueConstraint *uniqueConstraint = [uniqueConstraints objectAtIndex:i];
        [sql appendString:@",\n unique ("];
        NSArray * uniqueColumns = uniqueConstraint.columns;
        for(int j = 0; j < [uniqueColumns count]; j++){
            GPKGUserColumn *uniqueColumn = [uniqueColumns objectAtIndex:j];
            if(j > 0){
                [sql appendString:@", "];
            }
            [sql appendFormat:@"%@", uniqueColumn.name];
        }
        [sql appendString:@")"];
    }

    [sql appendString:@"\n"];
    
    // Create the table
    [self.db exec:sql];
}

-(void) createRequired{

    // Create the Spatial Reference System table (spec Requirement 10)
    [self createSpatialReferenceSystem];
    
    // Create the Contents table (spec Requirement 13)
    [self createContents];
    
    // Create the required Spatial Reference Systems (spec Requirement
    // 11)
    GPKGSpatialReferenceSystemDao * dao =[[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.db];
    [dao createWgs84];
    [dao createUndefinedCartesian];
    [dao createUndefinedGeographic];

}

@end
