FROM cinterloper/lash
ADD build.sh /
ADD build_containers.sh /
ADD workflow /workflow
CMD bats workflow/main.bats
