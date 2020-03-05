//
//  GPKGTileBoundingBoxUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGBoundingBox.h"
#import "GPKGTileGrid.h"
#import "SFPProjection.h"
#import "GPKGTileMatrix.h"
#import "SFPoint.h"

/**
 *  Tile Bounding Box utility methods
 */
@interface GPKGTileBoundingBoxUtils : NSObject

/**
 *  Get the overlapping bounding box between the two bounding boxes
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

/**
 *  Get the overlapping bounding box between the two bounding boxes
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *  @param allowEmpty   allow empty latitude and/or longitude ranges when determining overlap
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 andAllowEmpty: (BOOL) allowEmpty;

/**
 *  Get the overlapping bounding box between the two bounding boxes adjusting the second box to an Anti-Meridian complementary version based upon the max longitude
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *  @param maxLongitude max longitude of the world for the current bounding box units
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 withMaxLongitude: (double) maxLongitude;

/**
 *  Get the overlapping bounding box between the two bounding boxes adjusting the second box to an Anti-Meridian complementary version based upon the max longitude
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *  @param maxLongitude max longitude of the world for the current bounding box units
 *  @param allowEmpty   allow empty latitude and/or longitude ranges when determining overlap
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 withMaxLongitude: (double) maxLongitude andAllowEmpty: (BOOL) allowEmpty;

/**
 *  Determine if the point is within the bounding box
 *
 *  @param point  bounding box
 *  @param boundingBox bounding box
 *
 *  @return YES if within the bounding box
 */
+(BOOL) isPoint: (SFPoint *) point inBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Determine if the point is within the bounding box
 *
 *  @param point  bounding box
 *  @param boundingBox bounding box
 *  @param maxLongitude max longitude of the world for the current bounding box units
 *
 *  @return YES if within the bounding box
 */
+(BOOL) isPoint: (SFPoint *) point inBoundingBox: (GPKGBoundingBox *) boundingBox withMaxLongitude: (double) maxLongitude;

/**
 *  Get the union bounding box combining the two bounding boxes
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) unionWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

/**
 *  Get the X pixel for where the longitude fits into the bounding box
 *
 *  @param width       width
 *  @param boundingBox bounding box
 *  @param longitude   longitude
 *
 *  @return x pixel
 */
+(double) xPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andLongitude: (double) longitude;

/**
 *  Get the longitude from the pixel location, bounding box, and image width
 *
 *  @param width       width
 *  @param boundingBox bounding box
 *  @param pixel       x pixel
 *
 *  @return longitude
 */
+(double) longitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

/**
 *  Get the longitude from the pixel location, bounding box, tile bounding
 *  box (when different from bounding box), and image width
 *
 *  @param width           width
 *  @param boundingBox     bounding box
 *  @param tileBoundingBox tile bounding box
 *  @param pixel           x pixel
 *
 *  @return longitude
 */
+(double) longitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andPixel: (double) pixel;

/**
 *  Get the Y pixel for where the latitude fits into the bounding box
 *
 *  @param height      height
 *  @param boundingBox bounding box
 *  @param latitude    latitude
 *
 *  @return y pixel
 */
+(double) yPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andLatitude: (double) latitude;

/**
 *  Get the latitude from the pixel location, bounding box, and image height
 *
 *  @param height      height
 *  @param boundingBox bounding box
 *  @param pixel       y pixel
 *
 *  @return latitude
 */
+(double) latitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

/**
 *  Get the latitude from the pixel location, bounding box, tile bounding
 *  box (when different from bounding box), and image height
 *
 *  @param height          height
 *  @param boundingBox     bounding box
 *  @param tileBoundingBox tile bounding box
 *  @param pixel           y pixel
 *
 *  @return latitude
 */
+(double) latitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andPixel: (double) pixel;

/**
 * Get the tile bounding box from the XYZ tile coordinates and zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Web Mercator tile bounding box from the XYZ tile coordinates and zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) webMercatorBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Web Mercator tile bounding box from the XYZ tile grid and zoom level
 *
 *  @param tileGrid tile grid
 *  @param zoom     zoom
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) webMercatorBoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile coordinates and zoom level
 *
 *  @param epsg epsg code
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithEpsg: (NSNumber *) epsg andX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile coordinates and zoom level
 *
 *  @param authority projection authority
 *  @param code      authority code
 *  @param x         x
 *  @param y         y
 *  @param zoom      zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithAuthority: (NSString *) authority andCode: (NSNumber *) code andX:(int)x andY:(int)y andZoom:(int)zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile coordinates and zoom level
 *
 *  @param projection     projection
 *  @param x              x
 *  @param y              y
 *  @param zoom           zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithProjection: (SFPProjection *) projection andX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile tileGrid and zoom level
 *
 *  @param epsg     epsg code
 *  @param tileGrid tile grid
 *  @param zoom     zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithEpsg: (NSNumber *) epsg andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile tileGrid and zoom level
 *
 *  @param authority projection authority
 *  @param code      authority code
 *  @param tileGrid tile grid
 *  @param zoom     zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithAuthority: (NSString *) authority andCode: (NSNumber *) code andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the XYZ tile tileGrid and zoom level
 *
 *  @param projection projection
 *  @param tileGrid   tile grid
 *  @param zoom       zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) projectedBoundingBoxWithProjection: (SFPProjection *) projection andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 *  Get the tile grid for the location specified as WGS84
 *
 *  @param point  WGS84 point
 *  @param zoom   zoom level
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) tileGridFromWGS84Point: (SFPoint *) point andZoom: (int) zoom;

/**
 *  Get the tile grid for the location specified as the projection
 *
 *  @param point        point
 *  @param zoom         zoom level
 *  @param projection   point projection
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) tileGridFromPoint: (SFPoint *) point andZoom: (int) zoom andProjection: (SFPProjection *) projection;

/**
 *  Get the tile grid that includes the entire tile bounding box
 *
 *  @param webMercatorBoundingBox web mercator bounding box
 *  @param zoom                   zoom level
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) tileGridWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andZoom: (int) zoom;

/**
 *  Convert the bounding box coordinates to a new web mercator bounding box
 *
 *  @param boundingBox bounding box
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) toWebMercatorWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Get the tile size in meters
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return meters
 */
+(double) tileSizeWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the zoom level from the tile size in meters
 *
 *  @param tileSize tile size in meters
 *
 *  @return zoom level
 */
+(double) zoomLevelOfTileSize: (double) tileSize;

/**
 *  Get the tile width in degrees
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return degrees
 */
+(double) tileWidthDegreesWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tile height in degrees
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return degrees
 */
+(double) tileHeightDegreesWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tiles per side, width and height, at the zoom level
 *
 *  @param zoom zoom level
 *
 *  @return tiles per side
 */
+(int) tilesPerSideWithZoom: (int) zoom;

/**
 *  Get the tile size in meters at the zoom level
 *
 *  @param zoom zoom level
 *
 *  @return tile size in meters
 */
+(double) tileSizeWithZoom: (int) zoom;

/**
 *  Get the tolerance distance in meters for the zoom level and pixels length
 *
 *  @param zoom zoom level
 *  @param pixels pixel length
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceWithZoom: (int) zoom andPixels: (int) pixels;

/**
 *  Get the tolerance distance in meters for the zoom level and pixels length
 *
 *  @param zoom zoom level
 *  @param pixelWidth pixel width
 *  @param pixelHeight pixel height
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceWithZoom: (int) zoom andPixelWidth: (int) pixelWidth andPixelHeight: (int) pixelHeight;

/**
 *  Get the standard y tile location as TMS or a TMS y location as standard
 *
 *  @param zoom zoom
 *  @param y    y
 *
 *  @return opposite y format
 */
+(int) yAsOppositeTileFormatWithZoom: (int) zoom andY: (int) y;

/**
 *  Get the zoom level from the tiles per side
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return zoom level
 */
+(int) zoomFromTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tile grid
 *
 *  @param totalBox               total bounding box
 *  @param matrixWidth            matrix width
 *  @param matrixHeight           matrix height
 *  @param boundingBox            bounding box
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) tileGridWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixWidth: (int) matrixWidth andMatrixHeight: (int) matrixHeight andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Get the tile column of the longitude in constant units
 *
 *  @param totalBox            total bounding box
 *  @param matrixWidth         matrix width
 *  @param longitude           longitude in constant units
 *
 *  @return tile column
 */
+(int) tileColumnWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixWidth: (int) matrixWidth andLongitude: (double) longitude;

/**
 *  Get the tile row of the latitude in constant units
 *
 *  @param totalBox total bounding box
 *  @param matrixHeight        matrix height
 *  @param latitude            latitude in constant units
 *
 *  @return tile row
 */
+(int) tileRowWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixHeight: (int) matrixHeight andLatitude: (double) latitude;

/**
 *  Get the bounding box of the tile column and row in the tile
 *  matrix using the total bounding box
 *
 *  @param totalBox            total bounding box
 *  @param tileMatrix          tile matrix
 *  @param tileColumn          tile column
 *  @param tileRow             tile row
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileColumn: (int) tileColumn andTileRow: (int) tileRow;

/**
 *  Get the bounding box of the tile column and row in the tile
 *  width and height bounds using the total bounding box
 *
 *  @param totalBox            total bounding box
 *  @param tileMatrixWidth     matrix width
 *  @param tileMatrixHeight    matrix height
 *  @param tileColumn          tile column
 *  @param tileRow             tile row
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrixWidth: (int) tileMatrixWidth andTileMatrixHeight: (int) tileMatrixHeight andTileColumn: (int) tileColumn andTileRow: (int) tileRow;

/**
 *  Get the bounding box of the tile grid in the tile matrix
 *  using the total bounding box
 *
 *  @param totalBox            total bounding box
 *  @param tileMatrix          tile matrix
 *  @param tileGrid            tile grid
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileGrid: (GPKGTileGrid *) tileGrid;

/**
 *  Get the bounding box of the tile grid in the tile width and
 *  height bounds using the total bounding box
 *
 *  @param totalBox            total bounding box
 *  @param tileMatrixWidth     matrix width
 *  @param tileMatrixHeight    matrix height
 *  @param tileGrid            tile grid
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrixWidth: (int) tileMatrixWidth andTileMatrixHeight: (int) tileMatrixHeight andTileGrid: (GPKGTileGrid *) tileGrid;

/**
 * Get the zoom level of where the web mercator bounding box fits into the
 * complete world
 *
 *  @param webMercatorBoundingBox web mercator bounding box
 *
 *  @return zoom level
 */
+(int) zoomLevelWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox;

/**
 *  Get the location bearing a distance from a current location
 *
 *  @param bearing  bearing
 *  @param meters   meters
 *  @param location from location
 *
 *  @return to location
 */
+(CLLocationCoordinate2D) locationWithBearing: (double) bearing andDistance: (double) meters fromLocation: (CLLocationCoordinate2D) location;

/**
 *  Get the bearing from a location to a location
 *
 *  @param from from location
 *  @param to   to location
 *
 *  @return bearing
 */
+(double) bearingFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

/**
 *  Get the distance between two locations
 *
 *  @param location1 location 1
 *  @param location2 location 2
 *
 *  @return distance in meters
 */
+(double) distanceBetweenLocation: (CLLocationCoordinate2D) location1 andLocation: (CLLocationCoordinate2D) location2;

/**
 *  Get the location point between two locations
 *
 *  @param from from location
 *  @param to   to location
 *
 *  @return between point
 */
+(CLLocationCoordinate2D) pointBetweenFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

/**
 * Bound the web mercator bounding box within the limits
 *
 * @param boundingBox
 *            web mercator bounding box
 * @return bounding box
 */
+(GPKGBoundingBox *) boundWebMercatorBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Bound the upper and lower bounds of the WGS84 bounding box with web mercator limits
 *
 *  @param boundingBox wgs84 bounding box
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundWgs84BoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox;

/**
 *  Bound the upper and lower bounds of the degrees bounding box with web mercator limits
 *
 *  @param boundingBox degrees bounding box
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundDegreesBoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox;

/**
 *  Get a rectangle using the tile width, height, bounding box, and the
 *  bounding box section within the outer box to build the rectangle from
 *
 *  @param width              width
 *  @param height             height
 *  @param boundingBox        full bounding box
 *  @param boundingBoxSection rectangle bounding box section
 *
 *  @return rectangle
 */
+(CGRect) rectangleWithWidth: (int) width andHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andSection: (GPKGBoundingBox *) boundingBoxSection;

/**
 *  Get a rectangle with rounded point boundaries using the tile
 *  width, height, bounding box, and the bounding box section within the
 *  outer box to build the rectangle from
 *
 *  @param width              width
 *  @param height             height
 *  @param boundingBox        full bounding box
 *  @param boundingBoxSection rectangle bounding box section
 *
 *  @return rectangle
 */
+(CGRect) roundedRectangleWithWidth: (int) width andHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andSection: (GPKGBoundingBox *) boundingBoxSection;

/**
 *  Get the tile grid that includes the entire tile bounding box
 *
 *  @param wgs84BoundingBox    wgs84 bounding box
 *  @param zoom                zoom level
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) tileGridWithWgs84BoundingBox: (GPKGBoundingBox *) wgs84BoundingBox andZoom: (int) zoom;

/**
 * Get the WGS84 tile bounding box from the tile grid and zoom level
 *
 *  @param tileGrid tile grid
 *  @param zoom     zoom
 *
 *  @return wgs84 bounding box
 */
+(GPKGBoundingBox *) wgs84BoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 *  Get the tiles per latitude side at the zoom level
 *
 *  @param zoom zoom level
 *
 *  @return tiles per latitude side
 */
+(int) tilesPerWgs84LatSideWithZoom: (int) zoom;

/**
 *  Get the tiles per longitude side at the zoom level
 *
 *  @param zoom zoom level
 *
 *  @return tiles per longitude side
 */
+(int) tilesPerWgs84LonSideWithZoom: (int) zoom;

/**
 *  Get the tile height in degrees latitude
 *
 *  @param tilesPerLat tiles per latitude side
 *
 *  @return degrees
 */
+(double) tileSizeLatWithWgs84TilesPerSide: (int) tilesPerLat;

/**
 *  Get the tile height in degrees longitude
 *
 *  @param tilesPerLon tiles per longitude side
 *
 *  @return degrees
 */
+(double) tileSizeLonWithWgs84TilesPerSide: (int) tilesPerLon;

/**
 * Get the tile grid starting from the tile grid and current zoom to the new
 * zoom level
 *
 * @param tileGrid
 *            current tile grid
 * @param fromZoom
 *            current zoom level
 * @param toZoom
 *            new zoom level
 * @return tile grid at new zoom level
 */
+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomFrom: (int) fromZoom to: (int) toZoom;

/**
 * Get the tile grid starting from the tile grid and zooming in / increasing
 * the number of levels
 *
 * @param tileGrid
 *            current tile grid
 * @param zoomLevels
 *            number of zoom levels to increase by
 * @return tile grid at new zoom level
 */
+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomIncrease: (int) zoomLevels;

/**
 * Get the tile grid starting from the tile grid and zooming out /
 * decreasing the number of levels
 *
 * @param tileGrid
 *            current tile grid
 * @param zoomLevels
 *            number of zoom levels to decrease by
 * @return tile grid at new zoom level
 */
+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomDecrease: (int) zoomLevels;

/**
 * Get the new tile grid min value starting from the tile grid min and
 * zooming in / increasing the number of levels
 *
 * @param min
 *            tile grid min value
 * @param zoomLevels
 *            number of zoom levels to increase by
 * @return tile grid min value at new zoom level
 */
+(int) tileGridMin: (int) min zoomIncrease: (int) zoomLevels;

/**
 * Get the new tile grid max value starting from the tile grid max and
 * zooming in / increasing the number of levels
 *
 * @param max
 *            tile grid max value
 * @param zoomLevels
 *            number of zoom levels to increase by
 * @return tile grid max value at new zoom level
 */
+(int) tileGridMax: (int) max zoomIncrease: (int) zoomLevels;

/**
 * Get the new tile grid min value starting from the tile grid min and
 * zooming out / decreasing the number of levels
 *
 * @param min
 *            tile grid min value
 * @param zoomLevels
 *            number of zoom levels to decrease by
 * @return tile grid min value at new zoom level
 */
+(int) tileGridMin: (int) min zoomDecrease: (int) zoomLevels;

/**
 * Get the new tile grid max value starting from the tile grid max and
 * zooming out / decreasing the number of levels
 *
 * @param max
 *            tile grid max value
 * @param zoomLevels
 *            number of zoom levels to decrease by
 * @return tile grid max value at new zoom level
 */
+(int) tileGridMax: (int) max zoomDecrease: (int) zoomLevels;

@end
