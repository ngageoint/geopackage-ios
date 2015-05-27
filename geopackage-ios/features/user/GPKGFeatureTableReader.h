//
//  GPKGFeatureTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGGeometryColumns.h"
#import "GPKGFeatureTable.h"

@interface GPKGFeatureTableReader : GPKGUserTableReader

@property (nonatomic, strong) GPKGGeometryColumns * geometryColumns;

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

-(GPKGFeatureTable *) readFeatureTableWithConnection: (GPKGConnection *) db;

@end
