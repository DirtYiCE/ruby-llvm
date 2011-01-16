require 'llvm'
require 'llvm/core'

module LLVM
  module C
    # Bitcode reader
    attach_function :LLVMParseBitcode, [:pointer, :pointer, :pointer], :bool
    attach_function :LLVMParseBitcodeInContext, [:pointer, :pointer, :pointer, :pointer], :bool
    attach_function :LLVMGetBitcodeModuleInContext, [:pointer, :pointer, :pointer, :pointer], :bool
    attach_function :LLVMGetBitcodeModule, [:pointer, :pointer, :pointer], :bool


    # Bitcode writer
    attach_function :LLVMWriteBitcodeToFile, [:pointer, :string], :int
    attach_function :LLVMWriteBitcodeToFD, [:pointer, :int, :int, :int], :int
  end

  class Module
    def self.read_bitcode file, lazy = false
      errptr = FFI::MemoryPointer.new :string
      bufptr = FFI::MemoryPointer.new :pointer
      if C.LLVMCreateMemoryBufferWithContentsOfFile file, bufptr, errptr
        raise RuntimeError, errptr.read_pointer.read_string
      end

      modptr = FFI::MemoryPointer.new :pointer
      ret = if lazy
              C.LLVMGetBitcodeModule bufptr.get_pointer(0), modptr, errptr
            else
              C.LLVMParseBitcode bufptr.get_pointer(0), modptr, errptr
            end
      C.LLVMDisposeMemoryBuffer bufptr.get_pointer(0)
      if ret
        mod.dispose
        raise RuntimeError, errptr.read_pointer.read_string
      end
      new modptr.get_pointer(0)
    end

    def write_bitcode file
      ret = if file.is_a? String
              C.LLVMWriteBitcodeToFile self, file
            elsif file.is_a? IO
              C.LLVMWriteBitcodeToFD self, file.to_i, 0, 1
            else
              raise ArgumentError, "expected #{file.inspect} to be a String or IO"
            end
      raise RuntimeError if ret != 0
    end
  end
end
