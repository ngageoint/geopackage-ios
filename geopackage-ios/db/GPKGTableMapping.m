//
//  GPKGTableMapping.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTableMapping.h"

@interface GPKGTableMapping ()

/**
 * Mapping between column names and mapped columns
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGMappedColumn *> *columns;

/**
 * Dropped columns from the previous table version
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *droppedColumns;

@end

@implementation GPKGTableMapping

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.columns = [[NSMutableDictionary alloc] init];
        self.droppedColumns = [[NSMutableSet alloc] init];
    }
    return self;
}

-(instancetype) initWithTableName: (NSString *) tableName andColumns: (NSArray<GPKGUserColumn *> *) columns{
    self = [self init];
    if(self != nil){
        self.fromTable = tableName;
        self.toTable = tableName;
        for(GPKGUserColumn *column in columns){
            [self addColumn:[[GPKGMappedColumn alloc] initWithUserColumn:column]];
        }
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserTable *) table{
    return [self initWithTableName:table.tableName andColumns:table.columns];
}

-(instancetype) initWithTable: (GPKGUserTable *) table andDroppedColumns: (NSArray<NSString *> *) droppedColumnNames{
    self = [self initWithTable:table];
    if(self != nil){
        for(NSString *droppedColumnName in droppedColumnNames){
            [self addDroppedColumn:droppedColumnName];
        }
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserTable *) table andNewTable: (NSString *) newTableName{
    self = [self initWithTable:table];
    if(self != nil){
        self.toTable = newTableName;
    }
    return self;
}

-(instancetype) initWithTableInfo: (GPKGTableInfo *) tableInfo{
    self = [self init];
    if(self != nil){
        self.fromTable = [tableInfo tableName];
        self.toTable = [tableInfo tableName];
        for(GPKGTableColumn *column in [tableInfo columns]){
            [self addColumn:[[GPKGMappedColumn alloc] initWithTableColumn:column]];
        }
    }
    return self;
}

-(instancetype) initWithTableName: (NSString *) tableName andConnection: (GPKGConnection *) db{
    return [self initWithTableInfo:[GPKGTableInfo infoWithConnection:db andTable:tableName]];
}

-(BOOL) isNewTable{
    return self.toTable != nil && ![self.toTable isEqualToString:self.fromTable];
}

-(void) addColumn: (GPKGMappedColumn *) column{
    [self.columns setObject:column forKey:column.toColumn];
}

-(void) addColumnName: (NSString *) columnName{
    [self.columns setObject:[[GPKGMappedColumn alloc] initWithToColumn:columnName] forKey:columnName];
}

-(GPKGMappedColumn *) removeColumn: (NSString *) columnName{
    GPKGMappedColumn *column = [self columnForName:columnName];
    if(column != nil){
        [self.columns removeObjectForKey:columnName];
    }
    return column;
}

-(NSArray<NSString *> *) columnNames{
    return [self.columns allKeys];
}

-(NSArray<GPKGMappedColumn *> *) mappedColumns{
    return [self.columns allValues];
}

-(GPKGMappedColumn *) columnForName: (NSString *) columnName{
    return [self.columns objectForKey:columnName];
}

-(void) addDroppedColumn: (NSString *) columnName{
    [_droppedColumns addObject:columnName];
}

-(BOOL) removeDroppedColumn: (NSString *) columnName{
    BOOL removed = [self isDroppedColumn:columnName];
    if(removed){
        [_droppedColumns removeObject:columnName];
    }
    return removed;
}

-(NSSet<NSString *> *) droppedColumns{
    return _droppedColumns;
}

-(BOOL) isDroppedColumn: (NSString *) columnName{
    return [_droppedColumns containsObject:columnName];
}

-(BOOL) hasWhere{
    return self.where != nil;
}

@end
