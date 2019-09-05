//
//  GPKGTableColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/20/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTableColumn.h"

@interface GPKGTableColumn()

/**
 * Column index
 */
@property (nonatomic) int index;

/**
 * Column name
 */
@property (nonatomic, strong) NSString *name;

/**
 * Column type
 */
@property (nonatomic, strong) NSString *type;

/**
 * Column data type
 */
@property (nonatomic) enum GPKGDataType dataType;

/**
 * Column max value
 */
@property (nonatomic, strong) NSNumber *max;

/**
 * Column not null flag
 */
@property (nonatomic) BOOL notNull;

/**
 * Default value as a string
 */
@property (nonatomic, strong) NSString *defaultValueString;

/**
 * Default value
 */
@property (nonatomic, strong) NSObject *defaultValue;

/**
 * Primary key flag
 */
@property (nonatomic) BOOL primaryKey;

@end

@implementation GPKGTableColumn

-(instancetype) initWithIndex: (int) index andName: (NSString *) name andType: (NSString *) type andDataType: (enum GPKGDataType) dataType andMax: (NSNumber *) max andNotNull: (BOOL) notNull andDefaultValueString: (NSString *) defaultValueString andDefaultValue: (NSObject *) defaultValue andPrimaryKey: (BOOL) primaryKey{
    self = [super self];
    if(self != nil){
        self.index = index;
        self.name = name;
        self.type = type;
        self.dataType = dataType;
        self.max = max;
        self.notNull = notNull;
        self.defaultValueString = defaultValueString;
        self.defaultValue = defaultValue;
        self.primaryKey = primaryKey;
    }
    return self;
}

-(int) index{
    return _index;
}

-(NSString *) name{
    return _name;
}

-(NSString *) type{
    return _type;
}

-(enum GPKGDataType) dataType{
    return _dataType;
}

-(BOOL) isDataType: (enum GPKGDataType) dataType{
    return _dataType == dataType;
}

-(NSNumber *) max{
    return _max;
}

-(BOOL) notNull{
    return _notNull;
}

-(NSString *) defaultValueString{
    return _defaultValueString;
}

-(NSObject *) defaultValue{
    return _defaultValue;
}

-(BOOL) primaryKey{
    return _primaryKey;
}

@end
