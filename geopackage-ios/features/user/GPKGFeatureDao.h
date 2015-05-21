//
//  GPKGFeatureDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGGeometryColumns.h"

@interface GPKGFeatureDao : GPKGUserDao

@property (nonatomic, strong) GPKGGeometryColumns * geometryColumns;

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table andGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

-(NSString *) getGeometryColumnName;

//TODO
//-(WKBGeometryType *) getGeometryType;

@end
