//
//  GPKGGeometryData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryData.h"

@implementation GPKGGeometryData

// TODO

-(instancetype) initWithSrsId: (NSNumber *) srsId
{
    self = [super init];
    if(self != nil){
        self.srsId = srsId;
    }
    return self;
}

-(instancetype) initWithData: (NSData *) bytes
{
    self = [super init];
    if(self != nil){
        [self fromData:bytes];
    }
    return self;
}

-(void) fromData: (NSData *) bytes
{
    self.bytes = bytes;
    
    // TODO
}

-(NSData *) toData
{
    // TODO
    return nil;
}

-(NSData *) getHeaderData
{
    // TODO
    return nil;
}

-(NSData *) getWkbData
{
    // TODO
    return nil;
}

@end
