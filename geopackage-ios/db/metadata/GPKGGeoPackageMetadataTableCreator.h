//
//  GPKGGeoPackageMetadataTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/25/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"

@interface GPKGGeoPackageMetadataTableCreator : GPKGTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db;

-(int) createGeoPackageMetadata;

-(int) createTableMetadata;

-(int) createGeometryMetadata;

-(void) createAll;

@end
