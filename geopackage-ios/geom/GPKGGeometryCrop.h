//
//  GPKGGeometryCrop.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/8/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFGeometryEnvelope.h"
#import "SFGeometry.h"
#import "PROJProjection.h"
#import "GPKGGeometryData.h"

/**
 * Geometry Crop utilities
 */
@interface GPKGGeometryCrop : NSObject

/**
 * Crop the geometry data with a world map envelope, defined in the provided
 * projection
 *
 * @param projection
 *            geometry data and envelope projection
 * @param geometryData
 *            geometry data
 */
+(void) cropGeometryData: (GPKGGeometryData *) geometryData inProjection: (PROJProjection *) projection;

/**
 * Crop the geometry data with the envelope, both in the provided projection
 *
 * @param projection
 *            geometry data and envelope projection
 * @param geometryData
 *            geometry data
 * @param envelope
 *            geometry envelope
 */
+(void) cropGeometryData: (GPKGGeometryData *) geometryData withEnvelope: (SFGeometryEnvelope *) envelope inProjection: (PROJProjection *) projection;

/**
 * Crop the geometry with a world map envelope, defined in the provided
 * projection
 *
 * @param projection
 *            geometry and envelope projection
 * @param geometry
 *            geometry
 * @return cropped geometry
 */
+(SFGeometry *) cropGeometry: (SFGeometry *) geometry inProjection: (PROJProjection *) projection;

/**
 * Crop the geometry with the envelope, both in the provided projection
 *
 * @param projection
 *            geometry and envelope projection
 * @param geometry
 *            geometry
 * @param envelope
 *            geometry envelope
 * @return cropped geometry
 */
+(SFGeometry *) cropGeometry: (SFGeometry *) geometry withEnvelope: (SFGeometryEnvelope *) envelope inProjection: (PROJProjection *) projection;

/**
 * Get a geometry envelope for the projection
 *
 * @param projection
 *            projection
 * @return envelope
 */
+(SFGeometryEnvelope *) envelopeForProjection: (PROJProjection *) projection;

@end
