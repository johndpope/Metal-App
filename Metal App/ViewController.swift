import Cocoa
import MetalKit

let shader = """
#include <metal_stdlib> \n
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
    return vertex_in.position;
}

fragment float4 fragment_main() {
    return float4(1, 0, 0, 1);
}
"""

class ViewController: NSViewController {
    private var clearColor  = PhasedColor()
    private var primitive: PrimitiveModel? {
        didSet {
            guard let device = self.device else {
                return
            }
            do {
                mesh = try primitive?.mesh(device: device)
            } catch {
                print(error)
            }
        }
    }
    
    private var mesh: MTKMesh? {
        didSet {
            if let mesh = mesh {
                do {
                    pipelineState = try pipelineState(for: mesh)
                } catch {
                    print(error)
                }
            }
        }
    }
    private var pipelineState: MTLRenderPipelineState?

    func pipelineState(for mesh: MTKMesh, shader source: String = shader, vertexNamed vertex: String = "vertex_main", fragmentNamed fragment: String = "fragment_main") throws -> MTLRenderPipelineState? {
        guard let library = try device?.load(shader: source) else {
            return nil
        }
        let functions = (
            vertex: library.makeFunction(name: vertex)
            , fragment: library.makeFunction(name: fragment)
        )
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        descriptor.vertexFunction   = functions.vertex
        descriptor.fragmentFunction = functions.fragment
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        return try device?.pipelineState(for: descriptor)
    }

    private(set) var device: Device? {
        didSet {
            device?.attach(to: view as! MTKView, delegate: self)
            
            // Copy the current primitive over to the new device.
            if let device = device, let primitive = primitive {
                mesh = try? primitive.mesh(device: device)
            }
        }
    }
    
    var colorPixelFormat: MTLPixelFormat {
        return (view as! MTKView).colorPixelFormat
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        changeDevice(nil)
        changePrimitive(nil)
    }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let buffer     = device?.commandBuffer()
            , let descriptor = view.currentRenderPassDescriptor
            , let encoder    = buffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                return
        }
        
        defer {
            encoder.endEncoding()
            buffer.present(view.currentDrawable!)
            buffer.commit()
        }

        if let pipelineState = pipelineState {
            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(mesh?.vertexBuffers[0].buffer, offset: 0, index: 0)
            
            guard let submesh = mesh?.submeshes.first else {
                return
            }
            
            encoder.setTriangleFillMode(.lines)
            encoder.drawIndexedPrimitives(
                type: .triangle
              , indexCount: submesh.indexCount
              , indexType: submesh.indexType
              , indexBuffer: submesh.indexBuffer.buffer
              , indexBufferOffset: 0
            )
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}

extension ViewController {
    @IBAction func changeDevice(_ sender: Any?) {
        defer {
            print("Setting device: \(device!.name)")
            NSApp.mainWindow?.title = device!.name
        }

        guard let registryID = self.device?.registryID else {
            return self.device = Device()
        }
        device = Device(DeviceQuery.device(after: registryID))
        changePrimitive(sender)
    }
    
    private static let primitives: [PrimitiveModel] = [
        .capsule(extent: [0.75, 0.75, 0.75], cylinderSegments: [100, 100], hemisphereSegments: 4, inwardNormals: false)
        , .cone(extent: [0.75, 0.75, 0.75], segments: [10, 10], inwardNormals: false, cap: true)
        , .cube(extent: [0.75, 0.75, 0.75], segments: [100, 100, 100], inwardNormals: false)
        , .cylinder(extent: [0.75, 0.75, 0.75], segments: [100, 100], inwardNormals: false, topCap: true, bottomCap: true)
        , .icosahedron(extent: [0.75, 0.75, 0.75], inwardNormals: false)
        , .plane(extent: [0.75, 0.75, 0.75], segments: [100, 100])
        , .sphere(extent: [0.75, 0.75, 0.75], segments: [100, 100], inwardNormals: false)
    ]

    @IBAction func changePrimitive(_ sender: Any?) {
        primitive = ViewController.primitives.randomElement()
    }
}
