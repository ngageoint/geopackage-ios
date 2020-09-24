//
//  GPKGSimpleAttributesTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGSimpleAttributesTableMetadata.h"
#import "GPKGSimpleAttributesTable.h"

@implementation GPKGSimpleAttributesTableMetadata

+(GPKGSimpleAttributesTableMetadata *) create{
    return [[GPKGSimpleAttributesTableMetadata alloc] init];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andColumns:nil];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAutoincrement:autoincrement andColumns:nil];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andColumns:columns];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAutoincrement:autoincrement andColumns:columns];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andColumns:columns];
}

+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [[GPKGSimpleAttributesTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andAutoincrement:autoincrement andColumns:columns];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.idColumnName = idColumnName;
        self.additionalColumns = columns;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.idColumnName = idColumnName;
        self.autoincrement = autoincrement;
        self.additionalColumns = columns;
    }
    return self;
}

-(NSString *) defaultDataType{
    return nil;
}

-(NSArray<GPKGUserColumn *> *) buildColumns{

    NSArray<GPKGUserColumn *> *simpleAttributeColumns = [self columns];

    if (simpleAttributeColumns == nil) {

        NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
        [columns addObjectsFromArray:[GPKGSimpleAttributesTable createRequiredColumnsWithIdColumnName:self.idColumnName andAutoincrement:self.autoincrement]];

        NSArray<GPKGUserColumn *> *additional = [self additionalColumns];
        if (additional != nil) {
            [columns addObjectsFromArray:additional];
        }
        simpleAttributeColumns = columns;

    }

    return simpleAttributeColumns;
}

@end
