//
//  GPKGDataTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GPKGDataType{
    BOOLEAN,
    TINYINT,
    SMALLINT,
    MEDIUMINT,
    INT,
    INTEGER,
    FLOAT,
    DOUBLE,
    REAL,
    TEXT,
    BLOB,
    DATE,
    DATETIME
};

extern NSString * const DT_BOOLEAN;
extern NSString * const DT_TINYINT;
extern NSString * const DT_SMALLINT;
extern NSString * const DT_MEDIUMINT;
extern NSString * const DT_INT;
extern NSString * const DT_INTEGER;
extern NSString * const DT_FLOAT;
extern NSString * const DT_DOUBLE;
extern NSString * const DT_REAL;
extern NSString * const DT_TEXT;
extern NSString * const DT_BLOB;
extern NSString * const DT_DATE;
extern NSString * const DT_DATETIME;

@interface GPKGDataTypes : NSObject

+(NSString *) name: (enum GPKGDataType) dataType;

+(Class) classType: (enum GPKGDataType) dataType;

@end
