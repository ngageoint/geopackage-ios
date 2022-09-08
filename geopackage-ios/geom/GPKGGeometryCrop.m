//
//  GPKGGeometryCrop.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/8/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGGeometryCrop.h"
#import "SFGeometryUtils.h"
#import "PROJProjectionConstants.h"

@implementation GPKGGeometryCrop

+(void) cropGeometryData: (GPKGGeometryData *) geometryData inProjection: (PROJProjection *) projection{
    SFGeometryEnvelope *envelope = [self envelopeForProjection:projection];
    [self cropGeometryData:geometryData withEnvelope:envelope inProjection:projection];
}

+(void) cropGeometryData: (GPKGGeometryData *) geometryData withEnvelope: (SFGeometryEnvelope *) envelope inProjection: (PROJProjection *) projection{
    
    if(geometryData != nil && !geometryData.empty){
        
        SFGeometry *geometry = geometryData.geometry;
        SFGeometry *bounded = [self cropGeometry:geometry withEnvelope:envelope inProjection:projection];
        
        [geometryData setGeometry:bounded];
    }
    
}

+(SFGeometry *) cropGeometry: (SFGeometry *) geometry inProjection: (PROJProjection *) projection{
    SFGeometryEnvelope *envelope = [self envelopeForProjection:projection];
    return [self cropGeometry:geometry withEnvelope:envelope inProjection:projection];
}

+(SFGeometry *) cropGeometry: (SFGeometry *) geometry withEnvelope: (SFGeometryEnvelope *) envelope inProjection: (PROJProjection *) projection{
    
    SFPGeometryTransform *transform = nil;
    
    if(![projection isUnit:PROJ_UNIT_METERS]){
        transform = [SFPGeometryTransform transformFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        [SFGeometryUtils boundWGS84TransformableGeometry:geometry];
        geometry = [transform transformGeometry:geometry];
        envelope = [transform transformGeometryEnvelope:envelope];
    }
    
    SFGeometry *cropped = [SFGeometryUtils cropGeometry:geometry withEnvelope:envelope];
    
    if(transform != nil){
        transform = [transform inverseTransformation];
        cropped = [transform transformGeometry:cropped];
        [SFGeometryUtils minimizeWGS84Geometry:cropped];
    }
    
    return cropped;
}

+(SFGeometryEnvelope *) envelopeForProjection: (PROJProjection *) projection{
    SFGeometryEnvelope *envelope = nil;
    if([projection isUnit:PROJ_UNIT_METERS]){
        envelope = [SFGeometryUtils webMercatorEnvelope];
    }else{
        envelope = [SFGeometryUtils wgs84EnvelopeWithWebMercator];
    }
    return envelope;
}

@end
