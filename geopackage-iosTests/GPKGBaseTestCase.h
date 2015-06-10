//
//  GPKGBaseTestCase.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface GPKGBaseTestCase : XCTestCase

-(void)assertNil:(id) value;

-(void)assertNotNil:(id) value;

-(void)assertTrue: (BOOL) value;

-(void)assertFalse: (BOOL) value;

-(void)assertEqualWithValue:(NSObject *) value andValue2: (NSObject *) value2;

-(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2;

-(void)assertEqualIntWithValue:(int) value andValue2: (int) value2;

@end
