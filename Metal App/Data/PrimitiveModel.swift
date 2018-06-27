import ModelIO
import MetalKit

enum PrimitiveModel {
    case capsule(extent: simd_float3, cylinderSegments: simd_uint2, hemisphereSegments: Int32, inwardNormals: Bool)
    case cone(extent: simd_float3, segments: simd_uint2, inwardNormals: Bool, cap: Bool)
    case cube(extent: simd_float3, segments: simd_uint3, inwardNormals: Bool)
    case cylinder(extent: simd_float3, segments: simd_uint2, inwardNormals: Bool, topCap: Bool, bottomCap: Bool)
    case sphere(extent: simd_float3, segments: simd_uint2, inwardNormals: Bool)
    case plane(extent: simd_float3, segments: simd_uint2)
    case icosahedron(extent: simd_float3, inwardNormals: Bool)
    
    func mesh(device: Device) throws -> MTKMesh {
        let allocator = device.allocator()
        var modelMesh: MDLMesh!
        
        switch self {
        case .capsule(let extent, let cylinderSegments, let hemisphereSegments, let inwardNormals):
            modelMesh = MDLMesh(
                capsuleWithExtent: extent
                , cylinderSegments: cylinderSegments
                , hemisphereSegments: hemisphereSegments
                , inwardNormals: inwardNormals
                , geometryType: .triangles
                , allocator: allocator
            )
        case .cone(let extent, let segments, let inwardNormals, let cap):
            modelMesh = MDLMesh(
                coneWithExtent: extent
                , segments: segments
                , inwardNormals: inwardNormals
                , cap: cap
                , geometryType: .triangles
                , allocator: allocator
            )
        case .cube(let extent, let segments, let inwardNormals):
            modelMesh = MDLMesh(
                boxWithExtent: extent
                , segments: segments
                , inwardNormals: inwardNormals
                , geometryType: .triangles
                , allocator: allocator
            )
        case .sphere(let extent, let segments, let inwardNormals):
            modelMesh = MDLMesh(
                sphereWithExtent: extent
                , segments: segments
                , inwardNormals: inwardNormals
                , geometryType: .triangles
                , allocator: allocator
            )
        case .cylinder(let extent, let segments, let inwardNormals, let topCap, let bottomCap):
            modelMesh = MDLMesh(
                cylinderWithExtent: extent
                , segments: segments
                , inwardNormals: inwardNormals
                , topCap: topCap
                , bottomCap: bottomCap
                , geometryType: .triangles
                , allocator: allocator
            )
        case .plane(let extent, let segments):
            modelMesh = MDLMesh(
                planeWithExtent: extent
                , segments: segments
                , geometryType: .triangles
                , allocator: allocator
            )
        case .icosahedron(let extent, let inwardNormals):
            modelMesh = MDLMesh(
                icosahedronWithExtent: extent
                , inwardNormals: inwardNormals
                , geometryType: .triangles
                , allocator: allocator
            )
        }
        
        
        return try device.mesh(for: modelMesh)
    }
}

