//
//  GPKGAlterTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTable.h"
#import "GPKGSqlUtils.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGRawConstraint.h"

@implementation GPKGAlterTable

+(NSString *) alterTable: (NSString *) table{
    return [NSString stringWithFormat:@"ALTER TABLE %@", [GPKGSqlUtils quoteWrapName:table]];
}

+(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self renameTableSQL:tableName toTable:newTableName];
    [db exec:sql];
}

+(NSString *) renameTableSQL: (NSString *) tableName toTable: (NSString *) newTableName{
    return [NSString stringWithFormat:@"%@ RENAME TO %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:newTableName]];
}

+(void) renameColumn: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName withConnection: (GPKGConnection *) db{
    NSString *sql = [self renameColumnSQL:columnName inTable:tableName toColumn:newColumnName];
    [db exec:sql];
}

+(NSString *) renameColumnSQL: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName{
    return [NSString stringWithFormat:@"%@ RENAME COLUMN %@ TO %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:columnName], [GPKGSqlUtils quoteWrapName:newColumnName]];
}

+(void) addColumn: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self addColumnSQL:columnName withDefinition:columnDef toTable:tableName];
    [db exec:sql];
}

+(NSString *) addColumnSQL: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName{
    return [NSString stringWithFormat:@"%@ ADD COLUMN %@ %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:columnName], columnDef];
}

+(void) dropColumn: (NSString *) columnName fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    [self dropColumns:[NSArray arrayWithObject:columnName] fromTable:table withConnection:db];
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{

    GPKGUserTable *newTable = [table mutableCopy];
    
    for(NSString *columnName in columnNames){
        [newTable dropColumnWithName:columnName];
    }
    
    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable andDroppedColumns:columnNames];
    
    [self alterTable:newTable withMapping:tableMapping withConnection:db];
    
    for(NSString *columnName in columnNames){
        [table dropColumnWithName:columnName];
    }
}

+(void) dropColumn: (NSString *) columnName fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    [self dropColumns:[NSArray arrayWithObject:columnName] fromTableName:tableName withConnection:db];
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self dropColumns:columnNames fromTable:userTable withConnection:db];
}

+(void) alterColumn: (GPKGUserColumn *) column inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    [self alterColumns:[NSArray arrayWithObject:column] inTable:table withConnection:db];
}

+(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{

    GPKGUserTable *newTable = [table mutableCopy];
    
    for(GPKGUserColumn *column in columns){
        [newTable alterColumn:column];
    }
    
    [self alterTable:newTable withConnection:db];
    
    for(GPKGUserColumn *column in columns){
        [table alterColumn:column];
    }
}

+(void) alterColumn: (GPKGUserCustomColumn *) column inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    [self alterColumns:[NSArray arrayWithObject:column] inTableName:tableName withConnection:db];
}

+(void) alterColumns: (NSArray<GPKGUserCustomColumn *> *) columns inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self alterColumns:columns inTable:userTable withConnection:db];
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    [self copyTable:table toTable:newTableName andTransfer:YES withConnection:db];
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{

    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:table andNewTable:newTableName];
    [tableMapping setTransferContent:transferContent];
    
    [self alterTable:table withMapping:tableMapping withConnection:db];
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    [self copyTableName:tableName toTable:newTableName andTransfer:YES withConnection:db];
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self copyTable:userTable toTable:newTableName andTransfer:transferContent withConnection:db];
}

+(void) alterTable: (GPKGUserTable *) newTable withConnection: (GPKGConnection *) db{

    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable];
    
    [self alterTable:newTable withMapping:tableMapping withConnection:db];
}

+(void) alterTable: (GPKGUserTable *) newTable withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{

    // Update column constraints
    for(GPKGUserColumn * column in [newTable columns]){
        NSArray<GPKGConstraint *> *columnConstraints = [column clearConstraints];
        for(GPKGConstraint * columnConstraint in columnConstraints){
            NSString *updatedSql = [GPKGSqlUtils modifySQL:[columnConstraint buildSql] withName:columnConstraint.name andTableMapping:tableMapping];
            if (updatedSql != nil) {
                [column addConstraint:[[GPKGRawConstraint alloc] initWithType:columnConstraint.type andSql:updatedSql]];
            }
        }
    }
    
    // Update table constraints
    NSArray<GPKGConstraint *> *tableContraints = [newTable clearConstraints];
    for(GPKGConstraint * tableConstraint in tableContraints){
        NSString *updatedSql = [GPKGSqlUtils modifySQL:[tableConstraint buildSql] withName:tableConstraint.name andTableMapping:tableMapping];
        if (updatedSql != nil) {
            [newTable addConstraint:[[GPKGRawConstraint alloc] initWithType:tableConstraint.type andSql:updatedSql]];
        }
    }
    
    // Build the create table sql
    NSString *sql = [GPKGSqlUtils createTableSQL:newTable];
    
    [self alterTableSQL:sql withMapping:tableMapping withConnection:db];
}

+(void) alterTableSQL: (NSString *) sql withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{
    // TODO
}

@end
