FROM debian:bookworm AS builder
# install dependencies
RUN apt-get update && \
   apt-get install -y git zlib1g-dev gcc binutils make g++ autoconf automake cmake

RUN git clone https://github.com/chhylp123/hifiasm && \
   cd hifiasm && \
   sed -i '/^CXXFLAGS/s/$/ -static-libgcc -static-libstdc++/' Makefile && \
   sed -i '/^LDFLAGS/s/$/ -static -lpthread -lz -ldl/' Makefile && \
   make -j && \
   git clone https://github.com/upx/upx.git && \
    cd upx && \
    git submodule init && \
    git submodule update && \
    make -j && \
    cp build/release/upx /usr/local/bin/upx && \
    cd .. && \
    upx -9 hifiasm 
   


FROM gcr.io/distroless/base

COPY --from=builder /hifiasm/hifiasm /usr/local/bin/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libz.so.1.2.13 /lib/x86_64-linux-gnu/libz.so.1



ENTRYPOINT ["/usr/local/bin/hifiasm"]/
