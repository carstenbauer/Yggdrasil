version = v"9.0.1"

include("../common.jl")

name = "LLVM"
sources = []
products = [
    LibraryProduct(["LTO", "libLTO"], :liblto, dont_dlopen=true),
    ExecutableProduct("opt", :opt, "tools"),
    ExecutableProduct("llc", :llc, "tools"),
]
platforms = expand_cxxstring_abis(supported_platforms())
script = raw"""
cd ${prefix}

# First, find (true) LLVM library directory in ~/.artifacts somewhere
LLVM_ARTIFACT_DIR=$(dirname $(dirname $(realpath $(ls ${libdir}/*LLVM*.${dlext} | head -1))))

# Clear out our `${prefix}`
rm -rf ${prefix}

# Copy over `opt`, `llc`
mkdir -p ${prefix}/include ${prefix}/tools ${libdir}
cp -a ${LLVM_ARTIFACT_DIR}/include/clang* ${prefix}/include/
cp -a ${LLVM_ARTIFACT_DIR}/tools/opt* ${prefix}/tools/
cp -a ${LLVM_ARTIFACT_DIR}/tools/llc* ${prefix}/tools/
cp -a ${LLVM_ARTIFACT_DIR}/$(basename ${libdir})/libclang*.${dlext}* ${libdir}
"""
dependencies = [
    # Depend explicitly upon a certain version of LLVM_full_jll
    BuildDependency(get_addable_spec("LLVM_full_jll", v"9.0.1+2")),

    # We will definitely want libLLVM at runtime
    Dependency(PackageSpec(name="libLLVM_jll", version=v"9.0.1")),
]

build_tarballs(ARGS, name, version, sources, script,
               platforms, products, dependencies)