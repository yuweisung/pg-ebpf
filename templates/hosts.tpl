[all]
%{ for ip in default_hosts ~}
${ip}
%{ endfor ~}