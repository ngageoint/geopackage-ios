//
//  GPKGFeatureIndexerIdQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureIndexerIdQuery.h"

@interface GPKGFeatureIndexerIdQuery ()

/**
 * Set of ids
 */
@property (nonatomic, strong) NSMutableSet<NSNumber *> *ids;

@end

@implementation GPKGFeatureIndexerIdQuery

-(instancetype) init{
    self = [super self];
    if(self != nil){
        self.ids = [NSMutableSet set];
    }
    return self;
}

-(void) addArgument: (NSNumber *) id{
    [_ids addObject:id];
}

-(void) addArgumentInt: (int) id{
    [self addArgument:[NSNumber numberWithInt:id]];
}

-(int) count{
    return (int) _ids.count;
}

-(NSSet<NSNumber *> *) ids{
    return _ids;
}

-(BOOL) hasId: (NSNumber *) id{
    return [_ids containsObject:id];
}

-(BOOL) hasIdInt: (int) id{
    return [self hasId:[NSNumber numberWithInt:id]];
}

-(BOOL) aboveMaxArguments{
    return [self aboveMaxArgumentsWithAdditionalArgsCount:0];
}

-(BOOL) aboveMaxArgumentsWithAdditionalArgs: (NSArray *) additionalArgs{
    int additionalArgCount = 0;
    if(additionalArgs != nil){
        additionalArgCount += additionalArgs.count;
    }
    return [self aboveMaxArgumentsWithAdditionalArgsCount:additionalArgCount];
}

-(BOOL) aboveMaxArgumentsWithAdditionalArgsCount: (int) additionalArgs{
    return [self count] + additionalArgs > 999;
}

-(NSString *) sql{
    NSMutableString *sql = [NSMutableString string];
    int count = [self count];
    if(count > 0){
        [sql appendString:@"?"];
        for(int i = 1; i < count; i++){
            [sql appendString:@", ?"];
        }
    }
    return sql;
}

-(NSArray *) args{
    return [NSArray arrayWithArray:[_ids allObjects]];
}

@end
