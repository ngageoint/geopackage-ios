//
//  GPKGTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"
#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"

@implementation GPKGTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db{
    self = [super init];
    if(self){
        self.db = db;
    }
    return self;
}

-(int) createTable: (NSString *) tableName{
    return [self execSQLScript:tableName];
}
    
-(int) execSQLScript: (NSString *) propertyName{
    
    NSString * tablesProperties = [GPKGIOUtils getPropertyListPathWithName:GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    
    NSDictionary *tables = [NSDictionary dictionaryWithContentsOfFile:tablesProperties];
    NSArray *statements = [tables objectForKey:propertyName];
    if(statements == nil){
        [NSException raise:@"SQL Script" format:@"Failed to find SQL statements for property: %@, in resource: %@", propertyName, GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    }
    
    [self execSQLStatements:statements];

    return (int)[statements count];
}

-(void) execSQLStatements: (NSArray *) statements{
    for(NSString * statement in statements){
        [self.db exec:statement];
    }
}

@end
