[postgres]
%{ for ip in postgres_hosts ~}
${ip}
%{ endfor ~}
[prometheus]
%{ for ip in prometheus_hosts ~}
${ip}
%{ endfor ~}