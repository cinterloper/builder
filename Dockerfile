FROM cinterloper/lash
ADD run.sh /
ADD build.sh /
ADD build_containers.sh /
ADD workflow /workflow
CMD bash /run.sh
ENV BUILDER_VER=1.4
