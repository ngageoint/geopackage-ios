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
    
    NSArray<NSString *> *statements = [self readSQLScript:propertyName];
    
    [self execSQLStatements:statements];

    return (int)[statements count];
}

-(void) execSQLStatements: (NSArray *) statements{
    for(NSString * statement in statements){
        [self.db exec:statement];
    }
}

-(NSArray<NSString *> *) readSQLScript: (NSString *) name{
    
    NSString * propertiesFile = [GPKGIOUtils getPropertyListPathWithName:GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:propertiesFile];
    NSArray<NSString *> *statements = [properties objectForKey:name];
    if(statements == nil){
        [NSException raise:@"SQL Script" format:@"Failed to find SQL statements for name: %@, in resource: %@", name, GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    }
    
    return statements;
}

@end
