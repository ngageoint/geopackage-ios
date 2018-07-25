//
//  GPKGPropertiesExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/23/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGPropertiesExtension.h"
#import "GPKGProperties.h"
#import "GPKGAttributesColumn.h"
#import "GPKGNGAExtensions.h"

NSString * const GPKG_EXTENSION_PROPERTIES_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_PROPERTIES_NAME_NO_AUTHOR = @"properties";
NSString * const GPKG_PROP_EXTENSION_PROPERTIES_DEFINITION = @"geopackage.extensions.properties";
NSString * const GPKG_EXTENSION_PROPERTIES_TABLE_NAME = @"nga_properties";
NSString * const GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY = @"property";
NSString * const GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE = @"value";

@interface GPKGPropertiesExtension ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;

@end

@implementation GPKGPropertiesExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_PROPERTIES_AUTHOR andExtensionName:GPKG_EXTENSION_PROPERTIES_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_PROPERTIES_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) getOrCreate{
    
    // Create the attributes table
    if(![self.geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]){
        
        GPKGAttributesColumn *propertyColumn = [GPKGAttributesColumn createColumnWithIndex:1 andName:GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY andDataType:GPKG_DT_TEXT andNotNull:YES andDefaultValue:nil];
        GPKGAttributesColumn *valueColumn = [GPKGAttributesColumn createColumnWithIndex:2 andName:GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil];
        
        NSMutableArray *additionalColumns = [[NSMutableArray alloc] init];
        [additionalColumns addObject:propertyColumn];
        [additionalColumns addObject:valueColumn];
        
        NSArray<GPKGUserUniqueConstraint *> *uniqueConstraints = [[NSArray alloc] initWithObjects:[[GPKGUserUniqueConstraint alloc] initWithColumns:additionalColumns], nil];
        
        [self.geoPackage createAttributesTableWithTableName:GPKG_EXTENSION_PROPERTIES_TABLE_NAME andAdditionalColumns:additionalColumns andUniqueConstraints:uniqueConstraints];
    }
    
    GPKGExtensions *extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:GPKG_EXTENSION_PROPERTIES_TABLE_NAME andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName andTableName:GPKG_EXTENSION_PROPERTIES_TABLE_NAME andColumnName:nil] && [self.geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME];
}

-(GPKGAttributesDao *) dao{
    return [self.geoPackage getAttributesDaoWithTableName:GPKG_EXTENSION_PROPERTIES_TABLE_NAME];
}

-(GPKGAttributesRow *) newRow{
    return [[self dao] newRow];
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(int) numProperties{
    return (int)[self properties].count;
}

-(NSArray<NSString *> *) properties{
    NSArray<NSString *> *properties = nil;
    if([self has]){
        properties = [[self dao] querySingleColumnStringResultsWithSql:[NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@", GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY, GPKG_EXTENSION_PROPERTIES_TABLE_NAME] andArgs:nil];
    }else{
        properties = [[NSArray alloc] init];
    }
    return properties;
}

-(BOOL) hasProperty: (NSString *) property{
    return [self hasValuesWithProperty:property];
}

-(int) numValues{
    int count = 0;
    if([self has]){
        count = [[self dao] count];
    }
    return count;
}

-(int) numValuesOfProperty: (NSString *) property{
    int count = 0;
    if([self has]){
        GPKGResultSet *result = [self queryForValuesWithProperty:property];
        @try {
            count = result.count;
        }@finally {
            [result close];
        }
    }
    return count;
}

-(BOOL) hasSingleValueWithProperty: (NSString *) property{
    return [self numValuesOfProperty:property] == 1;
}

-(BOOL) hasValuesWithProperty: (NSString *) property{
    return [self numValuesOfProperty:property] > 0;
}

-(NSString *) valueOfProperty: (NSString *) property{
    NSString *value = nil;
    NSArray<NSString *> *values = [self valuesOfProperty:property];
    if (values.count > 0) {
        value = [values objectAtIndex:0];
    }
    return value;
}

-(NSArray<NSString *> *) valuesOfProperty: (NSString *) property{
    return [self valueswithResults:[self queryForValuesWithProperty:property]];
}

-(BOOL) hasValue: (NSString *) value withProperty: (NSString *) property{
    BOOL hasValue = NO;
    if([self has]){
        GPKGColumnValues *fieldValues = [self buildFieldValuesWithProperty:property andValue:value];
        GPKGResultSet *result = [[self dao] queryForFieldValues:fieldValues];
        @try{
            hasValue = result.count > 0;
        }@finally{
            [result close];
        }
    }
    return hasValue;
}

-(BOOL) addValue: (NSString *) value withProperty: (NSString *) property{
    if(![self has]){
        [self getOrCreate];
    }
    BOOL added = NO;
    if (![self hasValue:value withProperty:property]) {
        GPKGAttributesRow *row = [self newRow];
        [row setValueWithColumnName:GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY andValue:property];
        [row setValueWithColumnName:GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE andValue:value];
        [[self dao] insert:row];
        added = YES;
    }
    return added;
}

-(int) deleteProperty: (NSString *) property{
    int count = 0;
    if([self has]){
        GPKGAttributesDao *dao = [self dao];
        NSString *where = [dao buildWhereWithField:GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY andValue:property];
        NSArray *whereArgs = [dao buildWhereArgsWithValue:property];
        count = [dao deleteWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

-(int) deleteValue: (NSString *) value withProperty: (NSString *) property{
    int count = 0;
    if([self has]){
        GPKGColumnValues *fieldValues = [self buildFieldValuesWithProperty:property andValue:value];
        count = [[self dao] deleteByFieldValues:fieldValues];
    }
    return count;
}

-(int) deleteAll{
    int count = 0;
    if([self has]){
        count = [self.dao deleteAll];
    }
    return count;
}

-(void) removeExtension{
    [GPKGNGAExtensions deletePropertiesExtensionWithGeoPackage:self.geoPackage];
}

/**
 * Build field values from the property and value
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return field values mapping
 */
-(GPKGColumnValues *) buildFieldValuesWithProperty: (NSString *) property andValue: (NSString *) value{
    GPKGColumnValues *fieldValues = [[GPKGColumnValues alloc] init];
    [fieldValues addColumn:GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY withValue:property];
    [fieldValues addColumn:GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE withValue:value];
    return fieldValues;
}

/**
 * Query for the property values
 *
 * @param property
 *            property name
 * @return result
 */
-(GPKGResultSet *) queryForValuesWithProperty: (NSString *) property{
    GPKGResultSet *result = nil;
    if([self has]){
        result = [[self dao] queryForEqWithField:GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY andValue:property];
    }
    return result;
}

/**
 * Get the values from the results and close the results
 *
 * @param results
 *            results
 * @return list of values
 */
-(NSArray<NSString *> *) valueswithResults: (GPKGResultSet *) results{
    
    NSArray<NSString *> *values = nil;
    if(results != nil){
        @try {
            if (results.count > 0) {
                int columnIndex = [results getColumnIndexWithName:GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE];
                values = [self columnResultsAtIndex:columnIndex withResults:results];
            } else {
                values = [[NSArray alloc] init];
            }
        }@finally {
            [results close];
        }
    }else{
        values = [[NSArray alloc] init];
    }
    
    return values;
}

/**
 * Get the results of a column at the index and close the results
 *
 * @param columnIndex
 *            column index
 * @param results
 *            results
 * @return list of column index values
 */
-(NSArray<NSString *> *) columnResultsAtIndex: (int) columnIndex withResults: (GPKGResultSet *) results{

    NSMutableArray<NSString *> *values = [[NSMutableArray alloc] init];
    while ([results moveToNext]) {
        [values addObject:[results getString:columnIndex]];
    }
    
    return values;
}

@end
