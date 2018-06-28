//
//  GPKGUserCustomRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"

@implementation GPKGUserCustomRow

-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    if(self != nil){
        self.userCustomTable = table;
    }
    return self;
}

-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table{
    self = [super initWithTable:table];
    if(self != nil){
        self.userCustomTable = table;
    }
    return self;
}

-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow{
    self = [super initWithRow:userCustomRow];
    if(self != nil){
        self.userCustomTable = (GPKGUserCustomTable *) self.table;
    }
    return self;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserCustomRow *userCustomRow = [super mutableCopyWithZone:zone];
    userCustomRow.userCustomTable = _userCustomTable;
    return userCustomRow;
}

@end
