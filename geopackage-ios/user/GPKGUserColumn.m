//
//  GPKGUserColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"

@implementation GPKGUserColumn

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey{
    
    self = [super init];
    if(self != nil){
        self.index = index;
        self.name = name;
        self.dataType = dataType;
        self.max = max;
        self.notNull = notNull;
        self.defaultValue = defaultValue;
        self.primaryKey = primaryKey;
        [self validateMax];
    }
    return self;
}

-(NSString *) getTypeName{
    NSString * type = nil;
    if(self.dataType != GPKG_DT_GEOMETRY){
        type = [GPKGDataTypes name:self.dataType];
    }
    return type;
}

-(void) validateMax{
    
    if(self.max != nil && self.dataType != GPKG_DT_TEXT && self.dataType != GPKG_DT_BLOB){
        [NSException raise:@"Illegal State" format:@"Column max is only supported for TEXT and BLOB columns. column: %@, max: %@, type: %@", self.name, self.max, [GPKGDataTypes name:self.dataType]];
    }
}

@end
