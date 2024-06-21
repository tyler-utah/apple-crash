import Metal

let devices = MTLCopyAllDevices();
print("Available devices: \(devices)");
let device = devices[0];
print("Running on '\(device.name)'")

let liburl = NSURL.fileURL(withPath: "kernel-crash.metallib");
let lib = try! device.makeLibrary(URL: liburl);
let crash_func = lib.makeFunction(name: "crash")!;
let queue = device.makeCommandQueue()!;

func runInvocation() {
    let commands = queue.makeCommandBuffer()!;
    let encoder = commands.makeComputeCommandEncoder()!;
    let state = try! device.makeComputePipelineState(function: crash_func);
    encoder.setComputePipelineState(state);

    let groups = MTLSize(width: 64, height: 1, depth: 1);
    let threads = MTLSize(width: 3, height: 1, depth: 1);
    encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: threads);
    encoder.endEncoding();

    commands.commit();
    commands.waitUntilCompleted();
}

for i in 1...500 {
    print("Running invocation \(i)...")
    Task { 
        runInvocation();
    }
}

while(true) {}

print("Finished execution!");
