FROM alpine:3.21

LABEL Maitainer: Eric Daras <eric@daras.family>

RUN apk --no-cache add bash tinyproxy curl ruby

ADD tinyproxycmd.rb /

RUN chmod +x /tinyproxycmd.rb

EXPOSE 8888

ENTRYPOINT ["/tinyproxycmd.rb"]
