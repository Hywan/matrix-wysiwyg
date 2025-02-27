all: android ios web

# The gradle plugin will take care of building the bindings too
android:
	cd platforms/android && \
		./gradlew :library:assembleRelease && \
		mkdir -p out && \
		cp library/build/outputs/aar/library-release.aar out/wysiwyg-release.aar

android-bindings: android-bindings-armv7 android-bindings-aarch64 android-bindings-x86_64

android-bindings-armv7:
	cd bindings/wysiwyg-ffi && \
		cargo build --release --target armv7-linux-androideabi

android-bindings-aarch64:
	cd bindings/wysiwyg-ffi && \
		cargo build --release --target aarch64-linux-android

android-bindings-x86_64:
	cd bindings/wysiwyg-ffi && \
		cargo build --release --target x86_64-linux-android
	# Not copying into the Android project here, since the gradle plugin
	# actually performs this build itself.


IOS_PACKAGE_DIR := ../../platforms/ios/lib/WysiwygComposer
IOS_GENERATION_DIR := .generated/ios

ios:
	cd bindings/wysiwyg-ffi && \
	cargo build --release --target aarch64-apple-ios && \
	cargo build --release --target aarch64-apple-ios-sim && \
	cargo build --release --target x86_64-apple-ios && \
	mkdir -p ../../target/ios-simulator && \
	lipo -create \
	  ../../target/x86_64-apple-ios/release/libuniffi_wysiwyg_composer.a \
	  ../../target/aarch64-apple-ios-sim/release/libuniffi_wysiwyg_composer.a \
	  -output ../../target/ios-simulator/libuniffi_wysiwyg_composer.a && \
	rm -rf ${IOS_PACKAGE_DIR}/WysiwygComposerFFI.xcframework && \
	rm -f ${IOS_PACKAGE_DIR}/Sources/WysiwygComposer/WysiwygComposer.swift && \
	rm -rf ${IOS_GENERATION_DIR} && \
	mkdir -p ${IOS_GENERATION_DIR} && \
	uniffi-bindgen \
		generate src/wysiwyg_composer.udl \
		--language swift \
		--config uniffi.toml \
		--out-dir ${IOS_GENERATION_DIR} && \
	mkdir -p ${IOS_GENERATION_DIR}/headers && \
	mv ${IOS_GENERATION_DIR}/*.h         ${IOS_GENERATION_DIR}/headers/ && \
	mv ${IOS_GENERATION_DIR}/*.modulemap ${IOS_GENERATION_DIR}/headers/module.modulemap && \
	mv ${IOS_GENERATION_DIR}/*.swift     ${IOS_PACKAGE_DIR}/Sources/WysiwygComposer/ && \
	xcodebuild -create-xcframework \
	  -library ../../target/aarch64-apple-ios/release/libuniffi_wysiwyg_composer.a \
	  -headers ${IOS_GENERATION_DIR}/headers \
	  -library ../../target/ios-simulator/libuniffi_wysiwyg_composer.a \
	  -headers ${IOS_GENERATION_DIR}/headers \
	  -output ${IOS_PACKAGE_DIR}/WysiwygComposerFFI.xcframework
web:
	cd bindings/wysiwyg-wasm && \
	npm install && \
	npm run build && \
	mkdir -p ../../platforms/web/example/generated && \
	mkdir -p ../../platforms/web/src/generated && \
	cp \
		pkg/wysiwyg_bg.wasm \
		pkg/wysiwyg_bg.wasm.d.ts \
		pkg/wysiwyg.d.ts \
		pkg/wysiwyg.js \
		../../platforms/web/example/generated/ && \
	cp \
		pkg/wysiwyg_bg.wasm \
		pkg/wysiwyg_bg.wasm.d.ts \
		pkg/wysiwyg.d.ts \
		pkg/wysiwyg.js \
		../../platforms/web/src/generated/ 

clean:
	cargo clean
	rm -rf bindings/wysiwyg-wasm/node_modules
	rm -rf bindings/wysiwyg-wasm/pkg
	rm -rf bindings/wysiwyg-ffi/src/generated
	rm -rf platforms/android/out
	cd platforms/android && ./gradlew clean


test:
	cargo test

coverage:
	@echo "Requires `rustup component add llvm-tools-preview`"
	@echo "Requires `cargo install cargo-llvm-cov`"
	cargo llvm-cov --open
	