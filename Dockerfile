FROM cinterloper/lash
ADD build.sh /
ADD workflow /workflow
CMD bats workflow/main.bats
