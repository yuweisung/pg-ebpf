sudo -u postgres /usr/local/pgsql/bin/createdb mybench
sudo -u postgres /usr/local/pgsql/bin/pgbench -i -s 20 mybench
sudo -u postgres /usr/local/pgsql/bin/pgbench -c 10 -j 2 -t 10000 mybench