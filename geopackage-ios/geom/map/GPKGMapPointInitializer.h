//
//  GPKGMapPointInitializer.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGMapPointInitializer_h
#define geopackage_ios_GPKGMapPointInitializer_h

@import MapKit;

@protocol GPKGMapPointInitializer <NSObject>

-(void) initializeAnnotation: (NSObject<MKAnnotation> *) annotation;

@end

#endif
