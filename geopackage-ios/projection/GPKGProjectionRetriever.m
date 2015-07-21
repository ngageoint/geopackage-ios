//
//  GPKGProjectionRetriever.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionRetriever.h"

@implementation GPKGProjectionRetriever

+(NSString *) getProjectionWithNumber: (NSNumber *) epsg{
    
    NSString * parameters = nil;
    
    // TODO replace with config
    switch ([epsg intValue]) {
        case 4326:
        case 0:
        case -1:
            parameters = @"+proj=longlat +datum=WGS84 +no_defs";
            break;
        case 3857:
            parameters = @"+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs";
            break;
        case 3395:
            parameters = @"+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs";
            break;
        case 3994:
            parameters = @"+proj=merc +lon_0=100 +lat_ts=-41 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs";
            break;
        case 32631:
            parameters = @"+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs";
            break;
        case 27700:
            parameters = @"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs";
            break;
        default:
            [NSException raise:@"Projection not supported" format:@"Projection for EPSG %d not supported", [epsg intValue]];
            break;
    }
    
    return parameters;
}

@end
