//
//  GPKGTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGUserTable.h"

@interface GPKGTableCreator : NSObject

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
