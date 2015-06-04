//
//  GPKGContentValues.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/3/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContentValues.h"
#import "GPKGUtils.h"

@implementation GPKGContentValues

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.values = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void) putKey: (NSString *) key withValue: (NSObject *) value{
    [GPKGUtils setObject:value forKey:key inDictionary:self.values];
}

-(void) putNullValueForKey: (NSString *) key{
    [GPKGUtils setObject:nil forKey:key inDictionary:self.values];
}

-(int) size{
    return (int)[self.values count];
}

-(NSObject *) getValueForKey: (NSString *) key{
    return [GPKGUtils objectForKey:key inDictionary:self.values];
}

-(NSArray *) keySet{
    return [self.values allKeys];
}

-(NSString *) getKeyAsString: (NSString *) key{
    NSObject * value = [self getValueForKey:key];
    return value != nil ? [value description] : nil;
}

- (NSString *)description {
    NSMutableString * descriptionString = [[NSMutableString alloc]init];
    for(NSString * name in [self keySet]){
        NSString * value = [self getKeyAsString:name];
        if([descriptionString length] > 0){
            [descriptionString appendString:@" "];
        }
        [descriptionString appendFormat:@"%@=%@", name, value];
    }
    return descriptionString;
}

@end
