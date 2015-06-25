//
//  GPKGGeoPackageTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/25/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"

@interface GPKGGeoPackageTableCreator : GPKGTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db;

-(int) createSpatialReferenceSystem;

-(int) createContents;

-(int) createGeometryColumns;

-(int) createTileMatrixSet;

-(int) createTileMatrix;

-(int) createDataColumns;

-(int) createDataColumnConstraints;

-(int) createMetadata;

-(int) createMetadataReference;

-(int) createExtensions;

-(void) createUserTable: (GPKGUserTable *) table;

-(void) createRequired;

@end
