-- create table
CREATE TABLE IF NOT EXISTS `user_info`(
	`uid` int(11) NOT NULL AUTO_INCREMENT,
	`uname` varchar(64) NOT NULL,
	`upass` varchar(64) NOT NULL,
	`reg_time` int(11),
	PRIMARY KEY(uid)
) ENGINE= InnoDB AUTO_INCREMENT =10000 DEFAULT CHARSET = UTF8;
//
--  update
DROP PROCEDURE IF EXISTS server_update;
CREATE PROCEDURE server_update()
BEGIN
	DECLARE result int(4);
	DECLARE uDbName varchar(128);
	select database() into uDbName;
	SET result = 0;
	IF NOT EXISTS (select * from information_schema.columns where table_schema = uDbName and table_name = 'user_info' and column_name = 'login_time') THEN
		ALTER TABLE `user_info` ADD COLUMN  `login_time` int(11) DEFAULT 0 AFTER `reg_time`;
	END IF;
	SET result = 1;
	SELECT result;
END;
CALL server_update();
DROP PROCEDURE IF EXISTS server_update;
//

-- proc
DROP PROCEDURE IF EXISTS get_user_info;
CREATE PROCEDURE get_user_info(IN in_uid int(11))
BEGIN
	DECLARE result int(4);
	SET result =0;
	SELECT uname,upass,reg_time,login_time FROM user_info WHERE uid = in_uid;
	SET result =1;
	SELECT result;
END;
//

DROP PROCEDURE IF EXISTS check_user;
CREATE PROCEDURE check_user(IN in_uname varchar(50),IN in_pass varchar(64))
BEGIN
	DECLARE result int(4);
	DECLARE userId int(11);
	SET result =0;
	SET userId =0;
	SELECT count(uname),uid INTO result,userId FROM user_info WHERE uname = in_uname AND upass = in_pass;
	SELECT result,userId;
END;
//

DROP PROCEDURE IF EXISTS create_user;
CREATE PROCEDURE create_user(IN in_uname varchar(64),IN in_pass varchar(64))
BEGIN
	DECLARE result int(4);
	DECLARE status int(4);
	SET status =0;
	SET result =0;
	SELECT count(uname) into status FROM user_info WHERE uname = in_uname;
	IF status <> 0 THEN
		SET result = -1;
	ELSE
	 INSERT INTO user_info(uname,upass,reg_time,login_time)
	 VALUES(in_uname,in_pass,UNIX_TIMESTAMP(),UNIX_TIMESTAMP());
	END IF;
	SELECT result,LAST_INSERT_ID() AS userId;
END;
//

DROP PROCEDURE IF EXISTS get_top_user;
CREATE PROCEDURE get_top_user()
BEGIN
	DECLARE result int(4);
	SET result =0;
	SELECT uid,uname,upass,login_time from user_info ORDER BY login_time DESC LIMIT 10;
	SET result =1;
	SELECT result;
END;
//