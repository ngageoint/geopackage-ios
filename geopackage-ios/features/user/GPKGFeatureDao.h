//
//  GPKGFeatureDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGGeometryColumns.h"
#import "GPKGFeatureRow.h"
#import "WKBGeometryTypes.h"

@interface GPKGFeatureDao : GPKGUserDao

@property (nonatomic, strong) GPKGGeometryColumns * geometryColumns;

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGFeatureTable *) table andGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

-(GPKGFeatureTable *) getFeatureTable;

-(GPKGFeatureRow *) getFeatureRow: (GPKGResultSet *) results;

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

-(GPKGFeatureRow *) newRow;

-(NSString *) getGeometryColumnName;

-(enum WKBGeometryType) getGeometryType;

@end
