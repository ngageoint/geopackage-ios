//
//  GPKGCompositeOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/9/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBoundedOverlay.h"

/**
 * Composite overlay comprised of multiple overlays, checking each in order for a tile
 */
@interface GPKGCompositeOverlay : GPKGBoundedOverlay

/**
 *  Initialize
 *
 *  @return new composite overlay
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param overlay first overlay
 *
 *  @return new composite overlay
 */
-(instancetype) initWithOverlay: (GPKGBoundedOverlay *) overlay;

/**
 *  Initialize
 *
 *  @param overlays ordered overlays
 *
 *  @return new composite overlay
 */
-(instancetype) initWithOverlays: (NSArray<GPKGBoundedOverlay *> *) overlays;

/**
 * Add an overlay
 *
 * @param overlay bounded overlay
 */
-(void) addOverlay: (GPKGBoundedOverlay *) overlay;

/**
 * Add overlays
 *
 * @param overlays ordered overlays
 */
-(void) addOverlays: (NSArray<GPKGBoundedOverlay *> *) overlays;

/**
 * Clear the overlays
 */
-(void) clearOverlays;

@end
