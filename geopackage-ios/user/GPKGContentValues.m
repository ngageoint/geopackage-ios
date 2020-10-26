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
        self.values = [NSMutableDictionary dictionary];
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

-(NSObject *) valueForKey: (NSString *) key{
    return [GPKGUtils objectForKey:key inDictionary:self.values];
}

-(NSArray *) keySet{
    return [self.values allKeys];
}

-(NSString *) keyAsString: (NSString *) key{
    NSObject * value = [self valueForKey:key];
    return value != nil ? [value description] : nil;
}

- (NSString *)description {
    NSMutableString * descriptionString = [NSMutableString string];
    for(NSString * name in [self keySet]){
        NSString * value = [self keyAsString:name];
        if([descriptionString length] > 0){
            [descriptionString appendString:@" "];
        }
        [descriptionString appendFormat:@"%@=%@", name, value];
    }
    return descriptionString;
}

@end
