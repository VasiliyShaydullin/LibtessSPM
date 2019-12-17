
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

public enum TessError: Error {
    /// Error when a tessTesselate() call fails.
    case tesselationFailed
    /// Error thrown by TessC.tesselate static method when TessC initialization
    /// failed.
    case tessCInitFailed
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
    
    open func addContour(size: Int, vertices: UnsafeRawPointer, stride: Int, count: Int) { //MemoryLayout<Vector>.size
        tessAddContour(tess, CInt(size), vertices, CInt(stride), CInt(count))
    }
    
    open func tesselate(windingRule: WindingRule, elementType: ElementType, polySize: Int, vertexSize: VertexSize)-> (vertices: [Vector], indices: [Int])? {
        
        if tessTesselate(tess, CInt(windingRule.rawValue), CInt(elementType.rawValue), CInt(polySize), CInt(vertexSize.rawValue), nil) == 0 {
            print("Error")
            return nil
        }
        
        tessGetElements(tess)
        guard let vertices = tess.pointee.vertices, let elements = tess.pointee.elements else {
            print("Error")
            return nil
        }
        let vertexCount = Int(tess.pointee.vertexCount)
        let elementCount = Int(tess.pointee.elementCount)
        let stride = vertexSize.rawValue
        
        var verts: [TESSreal] = Array(repeating: 0, count: vertexCount * stride)
        verts.withUnsafeMutableBufferPointer { (body) -> Void in
            body.baseAddress?.assign(from: vertices, count: vertexCount * stride)
        }
        
        var indicesOut: [Int] = []
        
        for i in 0..<elementCount {
            let p = elements.advanced(by: i * polySize)
            for j in 0..<polySize where p[j] != ~TESSindex() {
                indicesOut.append(Int(p[j]))
            }
        }
        
//        verticesRaw = output
//        vertexCount = nverts
//        elementCount = nelems
//
//        elements = indicesOut
        
        //return (verts, indicesOut)
        
        var output: [Vector] = []
        output.reserveCapacity(vertexCount)
        
        //let stride: Int = vertexSize.rawValue
        for i in 0..<vertexCount {
            let x = verts[i * stride]
            let y = verts[i * stride + 1]
            let z = vertexSize == .size3 ? verts[i * stride + 2] : 0
            
            output.append(Vector(x: x, y: y, z: z))
            
        }
        
        //vertices = output
        
        return (output, indicesOut)
        
    }
    
    
    
}

