//
//  GPKGFeatureShape.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/15/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureShape.h"

@interface GPKGFeatureShape ()

@property (nonatomic) int featureId;
@property (nonatomic, strong) NSMutableArray<GPKGMapShape *> *shapes;
@property (nonatomic, strong) NSMutableArray<GPKGMapShape *> *metadataShapes;

@end

@implementation GPKGFeatureShape

-(instancetype) initWithId: (int) featureId{
    self = [super init];
    if(self != nil){
        self.featureId = featureId;
        self.shapes = [[NSMutableArray alloc] init];
        self.metadataShapes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(int) featureId{
    return _featureId;
}

-(NSMutableArray<GPKGMapShape *> *) shapes{
    return _shapes;
}

-(NSMutableArray<GPKGMapShape *> *) metadataShapes{
    return _metadataShapes;
}

-(void) addShape: (GPKGMapShape *) shape{
    [self.shapes addObject:shape];
}

-(void) addMetadataShape: (GPKGMapShape *) shape{
    [self.metadataShapes addObject:shape];
}

-(int) count{
    return (int)self.shapes.count;
}

-(BOOL) hasShapes{
    return self.shapes.count > 0;
}

-(int) countMetadataShapes{
    return (int)self.metadataShapes.count;
}

-(BOOL) hasMetadataShapes{
    return self.metadataShapes.count > 0;
}

-(void) removeFromMapView: (MKMapView *) mapView{
    [self removeMetadataShapesFromMapView:mapView];
    [self removeShapesFromMapView:mapView];
}

-(void) removeShapesFromMapView: (MKMapView *) mapView{
    for(GPKGMapShape *shape in self.shapes){
        [shape removeFromMapView:mapView];
    }
    [self.shapes removeAllObjects];
}

-(void) removeMetadataShapesFromMapView: (MKMapView *) mapView{
    for(GPKGMapShape *metadataShape in self.metadataShapes){
        [metadataShape removeFromMapView:mapView];
    }
    [self.metadataShapes removeAllObjects];
}

@end
