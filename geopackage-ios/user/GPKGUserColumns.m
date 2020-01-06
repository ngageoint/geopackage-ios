//
//  GPKGUserColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"

@interface GPKGUserColumns()

/**
 *  Array of column names
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *columnNames;

/**
 *  Array of columns
 */
@property (nonatomic, strong) NSMutableArray<GPKGUserColumn *> *columns;

/**
 *  Mapping between column names and their index
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *nameToIndex;

/**
 *  Primary key column index
 */
@property (nonatomic) int pkIndex;

@end

@implementation GPKGUserColumns

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.columns = [NSMutableArray arrayWithArray:columns];
        self.custom = custom;
        self.nameToIndex = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype) initWithUserColumns: (GPKGUserColumns *) userColumns{
    self = [super init];
    if(self != nil){
        self.tableName = userColumns.tableName;
        self.columnNames = [NSMutableArray arrayWithArray:userColumns.columnNames];
        self.columns = [[NSMutableArray alloc] init];
        for(GPKGUserColumn *column in userColumns.columns){
            GPKGUserColumn *copiedColumn = [column mutableCopy];
            [_columns addObject:copiedColumn];
        }
        self.nameToIndex = [NSMutableDictionary dictionaryWithDictionary:userColumns.nameToIndex];
        self.pkIndex = userColumns.pkIndex;
    }
    return self;
}

-(void) updateColumns{
    // TODO
}

// TODO

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserColumns *userColumns = [[[self class] allocWithZone:zone] initWithUserColumns:self];
    return userColumns;
}

@end
