//
//  GPKGColumnValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/4/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGColumnValues : NSObject

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSMutableArray *columns;

-(instancetype) init;

-(int) count;

-(void) addColumn: (NSString *) column withValue:(NSObject *) value;

-(NSObject *) getValue: (NSString *) column;

@end
