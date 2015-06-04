//
//  GPKGColumnValue.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGColumnValue : NSObject

@property (nonatomic, strong) NSObject *value;
@property (nonatomic) NSNumber *tolerance;

@end
