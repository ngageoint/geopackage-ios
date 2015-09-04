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

/**
 Map Point initializer protocol to perform point additional initialization when a point is added to a map view
 */
@protocol GPKGMapPointInitializer <NSObject>

/**
 *  Initialize the map annotation
 *
 *  @param annotation annotation
 */
-(void) initializeAnnotation: (NSObject<MKAnnotation> *) annotation;

@end

#endif
