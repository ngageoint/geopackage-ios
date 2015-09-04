//
//  GPKGMetadataScope.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Metadata Scopes as defined in spec Table 16. Metadata Scopes
 */
@interface GPKGMetadataScope : NSObject

/**
 *  Name (md_scope)
 */
@property (nonatomic, strong) NSString *name;

/**
 *  Scope code
 */
@property (nonatomic, strong) NSString *code;

/**
 *  Definition
 */
@property (nonatomic, strong) NSString *definition;

@end
