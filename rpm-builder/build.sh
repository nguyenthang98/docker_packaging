#!/bin/bash

BUILD_VERSION=$1

if [ -z "$BUILD_VERSION" ]; then
    echo "Invalid build version!!!"
    echo "Usage: ./build.sh [BUILD_VERSION]"
    exit 1
fi

echo "Packaging source..."
cp -r test test-$BUILD_VERSION
tar -czvf test-$BUILD_VERSION.tgz test-$BUILD_VERSION
rm -rf test-$BUILD_VERSION

echo "Building RPM file"
echo "Generating Spec file..."
cat <<EOF >test.spec
Name:           test
Version:        $BUILD_VERSION
Release:        1%{?dist}
Summary:        A hello world program

License:        GPLv3+
URL:            https://blog.packagecloud.io
Source0:        test-$BUILD_VERSION.tgz

Requires(post): info
Requires(preun): info

%description
A helloworld program from the packagecloud.io blog!

%prep
%setup

%build
make PREFIX=/usr %{?_smp_mflags}

%install
make PREFIX=/usr DESTDIR=%{?buildroot} install

%clean
rm -rf %{buildroot}

%files
%{_bindir}/helloworld
EOF

chown -R 1000:1000 *

docker run --rm -it \
    -v $(pwd)/test.spec:/home/builder/test.spec \
    -v $(pwd)/built:/home/builder/rpm/x86_64 \
    -v $(pwd)/test-$BUILD_VERSION.tgz:/home/builder/rpm/test-$BUILD_VERSION.tgz \
    rpm-builder:1.0.0 rpmbuild -ba /home/builder/test.spec

rm -f test.spec test-$BUILD_VERSION.tgz
