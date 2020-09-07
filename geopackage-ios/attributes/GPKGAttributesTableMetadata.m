//
//  GPKGAttributesTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGAttributesTableMetadata.h"
#import "GPKGContentsDataTypes.h"

@implementation GPKGAttributesTableMetadata

+(GPKGAttributesTableMetadata *) create{
    return [[GPKGAttributesTableMetadata alloc] init];
}

+(GPKGAttributesTableMetadata *) createWithAutoincrement: (BOOL) autoincrement{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:nil andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAdditionalColumns:nil andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:idColumnName andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:idColumnName andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:tableName andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithColumns: (GPKGAttributesColumns *) columns{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:columns.tableName andColumns:(NSArray<GPKGAttributesColumn *> *)[columns columns] andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithColumns: (GPKGAttributesColumns *) columns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:columns.tableName andColumns:(NSArray<GPKGAttributesColumn *> *)[columns columns] andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithAttributesTable: (GPKGAttributesTable *) table{
    return [[GPKGAttributesTableMetadata alloc] initWithTable:[table tableName] andColumns:(NSArray<GPKGAttributesColumn *> *)[table columns] andConstraints:[table constraints]];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAdditionalColumns:nil andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:nil andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:idColumnName andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:idColumnName andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:tableName andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andColumns: (GPKGAttributesColumns *) columns{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:columns.tableName andColumns:(NSArray<GPKGAttributesColumn *> *)[columns columns] andConstraints:nil];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andColumns: (GPKGAttributesColumns *) columns andConstraints: (GPKGConstraints *) constraints{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:columns.tableName andColumns:(NSArray<GPKGAttributesColumn *> *)[columns columns] andConstraints:constraints];
}

+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andAttributesTable: (GPKGAttributesTable *) table{
    return [[GPKGAttributesTableMetadata alloc] initWithDataType:dataType andTable:[table tableName] andColumns:(NSArray<GPKGAttributesColumn *> *)[table columns] andConstraints:[table constraints]];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [self initWithDataType:nil andTable:tableName andIdColumn:idColumnName andAdditionalColumns:additionalColumns andConstraints:constraints];
}

-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    self = [super init];
    if(self != nil){
        [self setDataType:dataType];
        [self setTableName:tableName];
        [self setIdColumnName:idColumnName];
        [self setAdditionalColumns:additionalColumns];
        [self setConstraints:constraints];
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    return [self initWithDataType:nil andTable:tableName andIdColumn:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns andConstraints:constraints];
}

-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints{
    self = [super init];
    if(self != nil){
        [self setDataType:dataType];
        [self setTableName:tableName];
        [self setIdColumnName:idColumnName];
        [self setAutoincrement:autoincrement];
        [self setAdditionalColumns:additionalColumns];
        [self setConstraints:constraints];
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGAttributesColumn *> *) columns andConstraints: (GPKGConstraints *) constraints{
    return [self initWithDataType:nil andTable:tableName andColumns:columns andConstraints:constraints];
}

-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andColumns: (NSArray<GPKGAttributesColumn *> *) columns andConstraints: (GPKGConstraints *) constraints{
    self = [super init];
    if(self != nil){
        [self setDataType:dataType];
        [self setTableName:tableName];
        [self setColumns:columns];
        [self setConstraints:constraints];
    }
    return self;
}

-(NSString *) defaultDataType{
    return [GPKGContentsDataTypes name:GPKG_CDT_ATTRIBUTES];
}

-(NSArray<GPKGUserColumn *> *) buildColumns{
    
    NSArray<GPKGUserColumn *> *attributesColumns = [self columns];
    
    if(attributesColumns == nil){
        
        NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
        [columns addObject:[GPKGAttributesColumn createPrimaryKeyColumnWithName:[self idColumnName] andAutoincrement:[self autoincrement]]];
        
        NSArray<GPKGUserColumn *> *additional = [self additionalColumns];
        if(additional != nil){
            [columns addObjectsFromArray:additional];
        }
        
        attributesColumns = columns;
    }
    
    return attributesColumns;
}

@end
