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

NSString * const GPKG_RESOURCES_TABLES = @"geopackage.tables";

@implementation GPKGTableCreator

-(instancetype) initWithDatabase: (GPKGConnection *) db{
    self = [super init];
    if(self){
        self.db = db;
    }
    return self;
}

-(NSString *) properties{
    return nil;
}

-(int) createTable: (NSString *) tableName{
    return [self execSQLForProperty:tableName];
}

-(int) createTable: (NSString *) tableName fromProperties: (NSString *) properties{
    return [self execSQLForProperty:tableName fromProperties:properties];
}

-(int) execSQLForProperty: (NSString *) propertyName{
    return [self execSQLForProperty:propertyName fromProperties:[self properties]];
}
    
-(int) execSQLForProperty: (NSString *) propertyName fromProperties: (NSString *) properties{
    
    NSArray<NSString *> *statements = [GPKGTableCreator readProperty:propertyName fromProperties:properties];
    
    [self execSQLStatements:statements];

    return (int)[statements count];
}

-(void) execSQLStatements: (NSArray *) statements{
    for(NSString *statement in statements){
        [self.db execResettable:statement];
    }
}

+(NSArray<NSString *> *) readProperty: (NSString *) propertyName{
    return [self readProperty:propertyName fromProperties:nil];
}

+(NSArray<NSString *> *) readProperty: (NSString *) propertyName fromProperties: (NSString *) properties{
    NSMutableString *propertiesFile = [NSMutableString stringWithString:GPKG_RESOURCES_TABLES];
    if(properties != nil){
        [propertiesFile appendFormat:@".%@", properties];
    }
    return [self readProperty:propertyName fromFile:propertiesFile];
}

+(NSArray<NSString *> *) readProperty: (NSString *) propertyName fromFile: (NSString *) propertiesFile{
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:propertiesFile];
    NSArray<NSString *> *statements = [properties objectForKey:propertyName];
    if(statements == nil){
        [NSException raise:@"SQL Property" format:@"Failed to find SQL statements for property: %@, in resource: %@", propertyName, propertiesFile];
    }
    return statements;
}

@end
