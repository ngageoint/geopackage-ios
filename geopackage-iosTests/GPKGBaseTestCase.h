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

@end
