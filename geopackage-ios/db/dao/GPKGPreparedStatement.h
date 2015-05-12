//
//  GPKGPreparedStatement.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGPreparedStatement : NSObject

@property (nonatomic, strong) NSMutableArray *select;

@property (nonatomic, strong) NSMutableDictionary *where;

@end
