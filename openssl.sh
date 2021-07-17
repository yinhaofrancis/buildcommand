root=`pwd`
# darwin64-arm64-cc 
# darwin64-x86_64-cc
platforms=(ios64-xcrun ios-xcrun iossimulator-xcrun)

download(){
    curl https://www.openssl.org/source/openssl-1.1.1k.tar.gz --output openssl.tar.gz
    tar -zxvf openssl.tar.gz 
}


build(){
    ./Configure ${1}  --prefix=${root}/openssl_${1} -fembed-bitcode
    make 
    make install
    make clean
}

makelib(){
    mkdir -p openssl/lib
    outfiles=(libssl.a libcrypto.a)
    for j in ${!outfiles[@]}
    do
        new=platforms
        for i in ${!platforms[@]}
        do
            new[i]=./openssl_${platforms[$i]}/lib/${outfiles[$j]}
        done
        lipo -create ${new[@]} -output openssl/lib/${outfiles[$j]}
    done
    cp -R ./openssl_${platforms[0]}/include openssl/
}
buildAll(){
    cd openssl*
    for i in ${!platforms[@]}
    do
        build ${platforms[$i]}
    done
    cd ..
}
framework(){

    new=platforms
    for i in ${!platforms[@]}
    do            
        new[i]="-library ./openssl_${platforms[$i]}/lib/libssl.a -headers ./openssl_${platforms[$i]}/include"
    done
    xcodebuild -create-xcframework ${new[@]} -output ssl.xcframework
    for i in ${!platforms[@]}
    do            
        new[i]="-library ./openssl_${platforms[$i]}/lib/libcrypto.a -headers ./openssl_${platforms[$i]}/include"
    done
    xcodebuild -create-xcframework ${new[@]} -output crypto.xcframework
}
frameworksim(){
    xcodebuild -create-xcframework -library openssl/lib/libopenssl.a -headers openssl/include -output openssl.xcframework
}
# makelibsim(){
#     # mkdir -p openssl/lib
#     # outfiles=(libssl.a libcrypto.a)
#     # for j in ${!outfiles[@]}
#     # do
#     #     new=platforms
#     #     for i in ${!platforms[@]}
#     #     do
#     #         new[i]=./openssl_${platforms[$i]}/lib/${outfiles[$j]}
#     #     done
#     #     lipo -create ${new[@]} -output openssl/lib/${outfiles[$j]}
#     # done
#     # cp -R ./openssl_${platforms[0]}/include openssl/
#     new=platforms
#     for i in ${!platforms[@]}
#     do
#         ar -x ./openssl_${platforms[$i]}/lib/libssl.a
#         ar -x ./openssl_${platforms[$i]}/lib/libcrypto.a
#         ar -cr ./openssl_${platforms[$i]}/lib/libopenssl.a *.o
#         rm *.o
#         new[i]=./openssl_${platforms[$i]}/lib/libopenssl.a
#     done
#     lipo -create ${new[@]} -output openssl/lib/libopenssl.a
#     cp -R ./openssl_${platforms[0]}/include openssl/
# }
download
buildAll
# framework
makelib
# frameworksim
# makelibsim