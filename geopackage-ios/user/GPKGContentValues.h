//
//  GPKGContentValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/3/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGContentValues : NSObject

@property (nonatomic, strong) NSMutableDictionary *values;

-(instancetype) init;

-(void) putKey: (NSString *) key withValue: (NSObject *) value;

-(void) putNullValueForKey: (NSString *) key;

-(int) size;

-(NSObject *) getValueForKey: (NSString *) key;

-(NSArray *) keySet;

-(NSString *) getKeyAsString: (NSString *) key;

@end
