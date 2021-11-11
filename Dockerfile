FROM python:3.7

LABEL maintainer="Yi Zhang <asxzy@asxzy.net>"

ENV LC_ALL="C"

RUN apt-get update

RUN apt-get install --no-install-recommends -y \
    build-essential \
    vim \
    curl \
    git

# Install local Chinese language environment
RUN apt install -y locales ttf-wqy-zenhei \ 
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo Asia/Shanghai > /etc/timezone \
    && sed -i "s/# zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/" /etc/locale.gen \
    && locale-gen

# ta-lib
RUN cd /tmp \
    && wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
    && tar -xzf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib \
    && ./configure  --prefix=/usr\
    && make -j 1 \
    && make install \
    && rm -rf /tmp/ta-lib*

# install vnpy
RUN python -m pip install -U pip

ADD https://raw.githubusercontent.com/vnpy/vnpy/master/requirements.txt .
RUN sed -i "s/vnpy_leveldb/# vnpy_leveldb/" requirements.txt

RUN python -m pip install -r requirements.txt

# install vnpy master
RUN python -m pip install git+https://github.com/vnpy/vnpy.git

# reinstall ta-lib
RUN python -m pip install -U -I ta-lib

WORKDIR /app

# cleanup
RUN apt-get purge -y build-essential wget\
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/

