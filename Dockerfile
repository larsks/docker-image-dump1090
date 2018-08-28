FROM ubuntu:bionic AS build

RUN apt-get update; \
	apt-get -y install \
		build-essential \
		dpkg-dev \
		git \
		librtlsdr-dev

RUN apt-get -y install devscripts
RUN apt-get -y install equivs

RUN mkdir -p /src
WORKDIR /src

RUN git clone https://github.com/Nuand/bladeRF
WORKDIR /src/bladeRF
RUN mk-build-deps -i \
		-t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y"

RUN dpkg-buildpackage -b

WORKDIR /src
RUN dpkg -i *.deb; apt-get -y install -f

RUN git clone -b bug/bladerf_frequency_type https://github.com/larsks/dump1090/ 
WORKDIR /src/dump1090
RUN cd dump1090; \
	mk-build-deps -i \
		-t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y"
RUN dpkg-buildpackage -b

WORKDIR /src

FROM ubuntu:bionic
RUN apt-get update; apt-get -y upgrade; \
	apt-get -y install \
		libterm-readline-gnu-perl \
		lighttpd \
		&& \
	apt-get clean
RUN mkdir -p /packages
COPY --from=build /src/*.deb /packages/
RUN dpkg -i /packages/*.deb; apt-get -y install -f

RUN lighty-enable-mod dump1090-fa || :
COPY run-dump1090.sh /usr/bin/run-dump1090
ENTRYPOINT ["/usr/bin/run-dump1090"]
