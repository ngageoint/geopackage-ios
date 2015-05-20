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

@interface GPKGDataTypes : NSObject

+(NSString *) name: (enum GPKGDataType) dataType;

@end
