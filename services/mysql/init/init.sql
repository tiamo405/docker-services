-- Allow root to connect from any host with native password authentication
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Also update the app user to use native password
ALTER USER 'quanlyluhanhdb'@'%' IDENTIFIED WITH mysql_native_password BY '9r0~1Mo2z@#';
GRANT ALL PRIVILEGES ON quanlyluhanhdb.* TO 'quanlyluhanhdb'@'%';

FLUSH PRIVILEGES;
