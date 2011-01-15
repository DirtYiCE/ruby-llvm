require 'ffi'

module LLVM
  module C
    extend ::FFI::Library

    # load required libraries
    begin
      ffi_lib `llvm-config --libdir`.strip + '/libLLVM-2.8.so'
    rescue LoadError
      ffi_lib `llvm-config --libdir`.strip + '/libLLVM-2.7.so'
    end
  end

  NATIVE_INT_SIZE = case FFI::Platform::ARCH
    when "x86_64" then 64
    # PPC, other arches?
    else 32
  end
end
