//
//  GPKGUserCustomTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomTableReader.h"

@implementation GPKGUserCustomTableReader

-(instancetype) initWithTable: (NSString *) tableName{
    self = [super initWithTable:tableName];
    return self;
}

-(GPKGUserCustomTable *) readUserCustomTableWithConnection: (GPKGConnection *) db{
    return (GPKGUserCustomTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGUserCustomTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [GPKGUserCustomColumn createColumnWithTableColumn:tableColumn];
}

+(GPKGUserCustomTable *) readTableWithConnection: (GPKGConnection *) db andTableName: (NSString *) tableName{
    GPKGUserCustomTableReader *tableReader = [[GPKGUserCustomTableReader alloc] initWithTable:tableName];
    GPKGUserCustomTable *customTable = [tableReader readUserCustomTableWithConnection:db];
    return customTable;
}

@end
