//
//  GPKGUserColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDataTypes.h"

@interface GPKGUserColumn : NSObject

@property (nonatomic) int index;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *max;
@property (nonatomic) BOOL notNull;
@property (nonatomic, strong) NSObject *defaultValue;
@property (nonatomic) BOOL primaryKey;
@property (nonatomic) enum GPKGDataType dataType;

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                      andDataType: (enum GPKGDataType) dataType
                      andMax: (NSNumber *) max
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue
                      andPrimaryKey: (BOOL) primaryKey;

-(NSString *) getTypeName;

@end
