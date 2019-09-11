//
//  GPKGAlterTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTable.h"

@implementation GPKGAlterTable

+(NSString *) alterTable: (NSString *) table{
    return nil; // TODO
}

+(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(NSString *) renameTableSQL: (NSString *) tableName toTable: (NSString *) newTableName{
    return nil; // TODO
}

+(void) renameColumn: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName withConnection: (GPKGConnection *) db{
    // TODO
}

+(NSString *) renameColumnSQL: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName{
    return nil; // TODO
}

+(void) addColumn: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(NSString *) addColumnSQL: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName{
    return nil; // TODO
}

+(void) dropColumn: (NSString *) columnName fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) dropColumn: (NSString *) columnName fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterColumn: (GPKGUserColumn *) column inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterColumn: (GPKGUserCustomColumn *) column inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterColumns: (NSArray<GPKGUserCustomColumn *> *) columns inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterTable: (GPKGUserTable *) newTable withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterTable: (GPKGUserTable *) newTable withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{
    // TODO
}

+(void) alterTableSQL: (NSString *) sql withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{
    // TODO
}

@end
