//
//  GPKGFeatureShapes.h
//  Pods
//
//  Created by Brian Osborn on 9/14/17.
//
//

#import <Foundation/Foundation.h>
#import "GPKGMapShape.h"

@interface GPKGFeatureShapes : NSObject

-(instancetype) init;

-(void) addMapShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database andTable: (NSString *) table;

-(NSArray<GPKGMapShape *> *) mapShapesWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database andTable: (NSString *) table;

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView;

@end
