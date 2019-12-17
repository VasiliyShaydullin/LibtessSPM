import XCTest
@testable import LibtessSPM

final class LibtessSPMTests: XCTestCase {
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//        XCTAssertEqual(LibtessSPM().text, "Hello, World!")
//    }
//
//    static var allTests = [
//        ("testExample", testExample),
//    ]
    
    func testLibtessSPM() {
        let tess = LibtessSPM()
        
        XCTAssert(tess != nil, "LibtessSPM = nil")
    }
    
//    switch(option) {
//    case TESS_CONSTRAINED_DELAUNAY_TRIANGULATION:
//        tess->processCDT = value > 0 ? 1 : 0;
//    case TESS_REVERSE_CONTOURS:
//        tess->reverseContours = value > 0 ? 1 : 0;
//    }
    
    func testSetOption() {
        let tessOpt = LibtessSPM()
        
        guard let tess = tessOpt else {
            XCTAssertNil(tessOpt, "LibtessSPM = nil")
            return
        }
        
        let defaultProcessCDT = tess.tess.pointee.processCDT
        let defaultReverseContours = tess.tess.pointee.reverseContours
        
        tess.setOption(optin: .constrainedDelanayTriangulation, value: 1)
        XCTAssert(defaultProcessCDT < tess.tess.pointee.processCDT, "set optional processCDT \(tess.tess.pointee.processCDT)")
        
        tess.setOption(optin: .reverseContours, value: 1)
        XCTAssert(defaultReverseContours < tess.tess.pointee.reverseContours, "set optional processCDT \(tess.tess.pointee.reverseContours)")
        
    }
    
    func testAddContourTesselate() {
        let tessOpt = LibtessSPM()
        
        guard let tess = tessOpt else {
            XCTAssertNil(tessOpt, "LibtessSPM = nil")
            return
        }
        
        var vertices: [Vertex] = []
        vertices.append(Vertex(x: 0.0, y: 0.0))
        vertices.append(Vertex(x: 0.0, y: 10.0))
        vertices.append(Vertex(x: 10.0, y: 10.0))
        vertices.append(Vertex(x: 0.0, y: 10.0))
        //vertices.append(Vertex(x: 0.0, y: 0.0))
        
        tess.addContour(size: 2, vertices: vertices, stride: MemoryLayout<Vertex>.size, count: vertices.count)
        
        let polygonIndexCount = 3; // triangles only
        let result = tess.tesselate(windingRule: .odd, elementType: .polygons, polySize: polygonIndexCount, vertexSize: .size2)
        print("result = ", result?.vertices.count ?? "nil", result?.indices.count ?? "nil")
        XCTAssert(result != nil, "Result tesselate = nil")
        
    }
    
    static var allTests = [
        ("testLibtessSPM", testLibtessSPM),
        ("testSetOption", testSetOption),
        ("testAddContourTesselate", testAddContourTesselate)
    ]
    
}

struct Vertex {
    let x: Float
    let y: Float
}
