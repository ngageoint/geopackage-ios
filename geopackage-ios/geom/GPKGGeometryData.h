//
//  GPKGGeometryData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGGeometryData : NSObject

@property (nonatomic, strong) NSData * bytes;
@property (nonatomic) BOOL extended;
@property (nonatomic) BOOL empty;
//TODO
//@property (nonatomic, strong) WKBByteOrder * byteOrder;
@property (nonatomic, strong) NSNumber * srsId;
//TODO
//@property (nonatomic, strong) WKBEnvelope * envelope;
@property (nonatomic) int wkbGeometryIndex;
//TODO
//@property (nonatomic, strong) WKBGeometry * geometry;

-(instancetype) initWithSrsId: (NSNumber *) srsId;

-(instancetype) initWithData: (NSData *) bytes;

-(void) fromData: (NSData *) bytes;

-(NSData *) toData;

//TODO
//-(void) setGeometry:(WKBGeometry *) geometry;

-(NSData *) getHeaderData;

-(NSData *) getWkbData;

//TODO
//+(int) getIndicatorWithEnvelope: (WKBEnvelope *) envelope;

@end
