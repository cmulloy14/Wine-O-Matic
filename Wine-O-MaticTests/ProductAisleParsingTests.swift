//
//  ProductAisleParsingTests.swift
//  Wine-O-MaticTests
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import XCTest
@testable import Wine_O_Matic


class ProductAisleParsingTests: XCTestCase {

    var aisleData: Data!

    override func setUp() {
        super.setUp()
        createData()
    }

    private func createData() {
        guard let fileURL = Bundle.main.url(forResource: "aisle", withExtension: "json"), let data = try? Data(contentsOf: fileURL) else {
            XCTFail("Unable to get data from aisle.json")
            return
        }
        aisleData = data
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDataParsing() {
        do {
            let aisle = try ProductProvider.parseAisleData(data: aisleData)

            XCTAssertEqual("Red Wine", aisle.title)
            XCTAssertFalse(aisle.groups.isEmpty, "Groups in Aisle should not be empty")

            for group in aisle.groups {
                XCTAssertFalse(group.products.isEmpty, "Products in each \(group.name) should not be empty")
            }
        }
        catch {
            XCTFail("Failed Creating Product Aisle Object: \(error.localizedDescription)")
        }
    }

}
