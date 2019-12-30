
import CLibtess2
import simd

public typealias Vector = simd_float3

public enum TessOption: Int {
    case constrainedDelanayTriangulation
    case reverseContours
}

public enum WindingRule: Int {
    case odd
    case nonZero
    case positive
    case negative
    case absGeqTwo
}

public enum ElementType: Int {
    case polygons
    case connectedPolygons
    case boundaryContours
}

public enum VertexSize: Int {
    case size2 = 2
    case size3 = 3
}

public class LibtessSPM {
    
    var tess: UnsafeMutablePointer<TESStesselator>
    
    public init?() {
        guard let tess = tessNewTess(nil) else {
            print("Failed to initialize TESStesselator")
            return nil
        }
        self.tess = tess
    }
    
    deinit {
        tessDeleteTess(tess)
    }
    
    // setOption() - Toggles optional tessellation parameters
    // Parameters:
    //  option - one of TessOption
    //  value - 1 if enabled, 0 if disabled.
    public func setOption(optin: TessOption, value: Int) {
        tessSetOption(tess, Int32(optin.rawValue), Int32(value))
    }
    
    // addContour() - Adds a contour to be tesselated.
    // The type of the vertex coordinates is assumed to be TESSreal.
    // Parameters:
    //   size - number of coordinates per vertex. Must be 2 or 3.
    //   pointer - pointer to the first coordinate of the first vertex in the array.
    //   stride - defines offset in bytes between consecutive vertices.
    //   count - number of vertices in contour.
    open func addContour(size: Int, vertices: UnsafeRawPointer, stride: Int, count: Int) {
        tessAddContour(tess, CInt(size), vertices, CInt(stride), CInt(count))
    }
    
    // tesselate() - tesselate contours.
    // Parameters:
    //   windingRule - winding rules used for tesselation, must be one of TessWindingRule.
    //   elementType - defines the tesselation result element type, must be one of TessElementType.
    //   polySize - defines maximum vertices per polygons if output is polygons.
    //   vertexSize - defines the number of coordinates in tesselation result vertex, must be 2 or 3.
    // Returns:
    // vertices and indices
    open func tesselate(windingRule: WindingRule, elementType: ElementType, polySize: Int, vertexSize: VertexSize) -> (vertices: [Vector], indices: [Int])? {
        
        if tessTesselate(tess, CInt(windingRule.rawValue), CInt(elementType.rawValue), CInt(polySize), CInt(vertexSize.rawValue), nil) == 0 {
            print("Failed to tesselate contours")
            return nil
        }
        
        tessGetElements(tess)
        guard let vertices = tessGetVertices(tess), let elements = tessGetElements(tess) else {
            print("failed return vertices and elements")
            return nil
        }
        let vertexCount = Int(tessGetVertexCount(tess))
        let elementCount = Int(tessGetElementCount(tess))
        let stride = vertexSize.rawValue
        
        var indices: [Int] = []
        
        for i in 0..<elementCount {
            let p = elements.advanced(by: i * polySize)
            for j in 0..<polySize where p[j] != ~TESSindex() {
                indices.append(Int(p[j]))
            }
        }
        
        var vertexArray: [TESSreal] = Array(repeating: 0, count: vertexCount * stride)
        vertexArray.withUnsafeMutableBufferPointer { (body) -> Void in
            body.baseAddress?.assign(from: vertices, count: vertexCount * stride)
        }
        
        var vectors: [Vector] = []
        vectors.reserveCapacity(vertexCount)
        
        for i in 0..<vertexCount {
            let x = vertexArray[i * stride]
            let y = vertexArray[i * stride + 1]
            let z = vertexSize == .size3 ? vertexArray[i * stride + 2] : 0
            
            vectors.append(Vector(x: x, y: y, z: z))
            
        }
        
        return (vectors, indices)
    }
}

