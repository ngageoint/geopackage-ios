//
//  GPKGSwiftReadmeTest.swift
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

import XCTest

/**
* README example tests
*/
class SFWTSwiftReadmeTest: XCTestCase{
    
    /**
     * README example tests
     */
    func testGeoPackage(){
        GPKGGeoPackageFactory.manager()?.delete(GPKG_TEST_IMPORT_DB_NAME)
        NSURL(fileURLWithPath:Bundle(for: GPKGManagerTestCase.self).resourcePath!).appendingPathComponent(GPKG_TEST_IMPORT_DB_FILE_NAME)
    }
    
    /**
     * Test write
     *
     * @param geometry
     *            geometry
     * @return text
     */
    func testGeoPackage(_ geoPackageFile: String?, _ mapView: MKMapView){
        
    }
    
}
