//
//  GPKGFeatureTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGFeatureColumn.h"

@interface GPKGFeatureTable : GPKGUserTable

@property (nonatomic) int geometryIndex;

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

-(GPKGFeatureColumn *) getGeometryColumn;

@end
