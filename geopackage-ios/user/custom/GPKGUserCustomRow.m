//
//  GPKGUserCustomRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"

@implementation GPKGUserCustomRow

-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table andColumns: (GPKGUserCustomColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
    return self;
}

-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow{
    self = [super initWithRow:userCustomRow];
    return self;
}

-(GPKGUserCustomTable *) userCustomTable{
    return (GPKGUserCustomTable *) super.table;
}

-(GPKGUserCustomColumns *) userCustomColumns{
    return (GPKGUserCustomColumns *) super.columns;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserCustomRow *userCustomRow = [super mutableCopyWithZone:zone];
    return userCustomRow;
}

@end
