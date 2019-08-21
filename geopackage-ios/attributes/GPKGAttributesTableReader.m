//
//  GPKGAttributesTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesTableReader.h"
#import "GPKGAttributesColumn.h"

@implementation GPKGAttributesTableReader

-(instancetype) initWithTable: (NSString *) tableName{
    self = [super initWithTable:tableName];
    return self;
}

-(GPKGAttributesTable *) readAttributesTableWithConnection: (GPKGConnection *) db{
    return (GPKGAttributesTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGAttributesTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [GPKGAttributesColumn createColumnWithTableColumn:tableColumn];
}

@end
