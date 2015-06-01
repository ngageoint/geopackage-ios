//
//  GPKGGeometryData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKBGeometryEnvelope.h"
#import "WKBGeometry.h"

@interface GPKGGeometryData : NSObject

@property (nonatomic, strong) NSData * bytes;
@property (nonatomic) BOOL extended;
@property (nonatomic) BOOL empty;
@property (nonatomic) CFByteOrder byteOrder;
@property (nonatomic, strong) NSNumber * srsId;
@property (nonatomic, strong) WKBGeometryEnvelope * envelope;
@property (nonatomic) int wkbGeometryIndex;
@property (nonatomic, strong) WKBGeometry * geometry;

-(instancetype) initWithSrsId: (NSNumber *) srsId;

-(instancetype) initWithData: (NSData *) bytes;

-(void) fromData: (NSData *) bytes;

-(NSData *) toData;

-(void) setGeometry:(WKBGeometry *) geometry;

-(NSData *) getHeaderData;

-(NSData *) getWkbData;

+(int) getIndicatorWithEnvelope: (WKBGeometryEnvelope *) envelope;

@end
