//
//  GPKGFeatureRowData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeometryData.h"

@interface GPKGFeatureRowData : NSObject

-(instancetype) initWithValues: (NSDictionary *) values andGeometryColumnName: (NSString *) geometryColumn;

-(NSDictionary *) getValues;

-(NSString *) getGeometryColumn;

-(GPKGGeometryData *) getGeometryData;

-(WKBGeometry *) getGeometry;

-(NSObject *) jsonCompatible;

@end
