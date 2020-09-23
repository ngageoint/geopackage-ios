//
//  GPKGMediaTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGMediaTableMetadata.h"
#import "GPKGMediaTable.h"

@implementation GPKGMediaTableMetadata

+(GPKGMediaTableMetadata *) create{
    return [[GPKGMediaTableMetadata alloc] init];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAdditionalColumns:nil];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAutoincrement:autoincrement andAdditionalColumns:nil];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAdditionalColumns:additionalColumns];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:nil andAutoincrement:autoincrement andAdditionalColumns:additionalColumns];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andAdditionalColumns:nil];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andAutoincrement:autoincrement andAdditionalColumns:nil];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andAdditionalColumns:additionalColumns];
}

+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    return [[GPKGMediaTableMetadata alloc] initWithTable:tableName andIdColumnName:idColumnName andAutoincrement:autoincrement andAdditionalColumns:additionalColumns];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.idColumnName = idColumnName;
        self.additionalColumns = additionalColumns;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.idColumnName = idColumnName;
        self.autoincrement = autoincrement;
        self.additionalColumns = additionalColumns;
    }
    return self;
}

-(NSString *) defaultDataType{
    return nil;
}

-(NSArray<GPKGUserColumn *> *) buildColumns{

    NSArray<GPKGUserColumn *> *mediaColumns = [self columns];

    if (mediaColumns == nil) {

        NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
        [columns addObjectsFromArray:[GPKGMediaTable createRequiredColumnsWithIdColumnName:self.idColumnName andAutoincrement:self.autoincrement]];

        NSArray<GPKGUserColumn *> *additional = [self additionalColumns];
        if (additional != nil) {
            [columns addObjectsFromArray:additional];
        }
        mediaColumns = columns;

    }

    return mediaColumns;
}

@end
