//
//  GPKGAuthorityProjections.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/19/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGAuthorityProjections.h"

@interface GPKGAuthorityProjections()

/**
 *  Coordinate authority
 */
@property (nonatomic, strong) NSString *authority;

/**
 * Projections by code
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGProjection *> *projections;

@end

@implementation GPKGAuthorityProjections

-(instancetype) initWithAuthority: (NSString *) authority{
    self = [super init];
    if(self != nil){
        self.projections = [[NSMutableDictionary alloc] init];
        self.authority = authority;
    }
    return self;
}

-(NSString *) authority{
    return _authority;
}

-(GPKGProjection *) projectionForCode: (NSString *) code{
    return [_projections objectForKey:code];
}

-(void) addProjection: (GPKGProjection *) projection{
    [_projections setObject:projection forKey:projection.code];
}

-(void) clear{
    [_projections removeAllObjects];
}

-(void) clearNumberCode: (NSNumber *) code{
    [self clearCode:[code stringValue]];
}

-(void) clearCode: (NSString *) code{
    [_projections removeObjectForKey:code];
}

@end
