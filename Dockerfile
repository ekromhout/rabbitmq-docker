FROM centos:latest
MAINTAINER  ethan@unc.edu ekromhout@gmail.com
RUN yum -y install epel-release && yum -y update && yum -y install pwgen rabbitmq-server supervisor wget
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-
RUN /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
RUN /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_tracing
RUN sed -i s/'%% {load_definitions, .*"},'/'{load_definitions, "\/etc\/rabbitmq\/rabbitmq.json"}'/ /etc/rabbitmq/rabbitmq.config
ENV JAVA_VERSION=8u162 
ENV BUILD_VERSION=b12 
ENV JAVA_BUNDLE_ID=0da788060d494f5095bf8624735fa2f1
#     ==> By uncommenting these next 6 lines, you agree to the Oracle Binary Code License Agreement for Java SE (http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
RUN wget -nv --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/$JAVA_BUNDLE_ID/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-$JAVA_VERSION-$BUILD_VERSION-linux-x64.rpm && \
     yum -y install /tmp/jdk-$JAVA_VERSION-$BUILD_VERSION-linux-x64.rpm && \
     rm -f /tmp/jdk-$JAVA_VERSION-$BUILD_VERSION-linux-x64.rpm && \
     alternatives --install /usr/bin/java jar $JAVA_HOME/bin/java 200000 && \
     alternatives --install /usr/bin/javaws javaws $JAVA_HOME/bin/javaws 200000 && \
     alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 200000

RUN sed -i s/'nodaemon=false'/'nodaemon=true'/ /etc/supervisord.conf
COPY rabbitmqctl.sh /root/
COPY rabbittrace-0.1-jar-with-dependencies.jar /root/
COPY trace.ini /etc/supervisord.d/
COPY rabbitmq.ini /etc/supervisord.d/
COPY rabbitmqctl.ini /etc/supervisord.d/
COPY rabbitmq.json /etc/rabbitmq/
COPY rabbittrace-0.1-jar-with-dependencies.jar /root/
EXPOSE 5672 15672 4369 25672
CMD ["supervisord","-c","/etc/supervisord.conf"]
