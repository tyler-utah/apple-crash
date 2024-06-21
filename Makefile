all: kernel-crash.run

kernel-crash.run: kernel-crash.metallib kernel-crash.swift
	xcrun -sdk macosx swiftc kernel-crash.swift -o kernel-crash.run

kernel-crash.metallib: kernel-crash.metal
	xcrun -sdk macosx metal -c -frecord-sources kernel-crash.metal
	xcrun -sdk macosx metal -frecord-sources -o kernel-crash.metallib kernel-crash.air

clean: 
	rm *.air *.metallib *.run