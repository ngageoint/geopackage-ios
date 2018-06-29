//
//  GPKGLoadGeoPackageTestCase.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestCase.h"

@interface GPKGLoadGeoPackageTestCase : GPKGGeoPackageTestCase

@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *file;

-(instancetype) initWithName: (NSString *) name andFile: (NSString *) file;

@end
