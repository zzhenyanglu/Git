# procedure 1  
# perform an action of favoring a song           
DROP PROCEDURE IF EXISTS favorite_a_song;
 
DELIMITER |
CREATE PROCEDURE favorite_a_song(
    IN user_name_in varchar(20),
    IN song_name_in varchar(20))
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    IF EXISTS (select favorite_date from favorites 
    	       where user_id = (select user_id from users where user_name = user_name_in) and song_id = 
             (select song_id from songs where song_name = song_name_in)) 
    then
        UPDATE favorites SET favorite_date = curdate() where 
                        user_id = (select user_id from users where user_name = user_name_in) 
                        and song_id = (select song_id from songs where song_name = song_name_in);

    # if a user favors a song for the first time, insert a tuple.
	  ELSE
	      INSERT INTO favorites(favorite_date, song_id, user_id) 
                 VALUE(curdate(), (select song_id from songs where song_name = song_name_in), 
                                  (select user_id from users where user_name = user_name_in));
    END IF;            
END; | 
DELIMITER ;



# procedure 2  
# create a regular user 
# NOTICE: MY IDEA IS TO CREATE A REGULAR USER
#         FIRST AND IF A USER WANTS TO UPGRADE
#         TO A FEE-PAYING USER, HE/SHE HAS TO
#         UPGRADE LATER.          
DROP PROCEDURE IF EXISTS create_user;
 
DELIMITER |
CREATE PROCEDURE create_user(
    IN user_name_in VARCHAR(50) ,
    IN psw_in VARCHAR(20) ,
    IN birthday_in date
    )

BEGIN 
    DECLARE msg varchar(100);
 
    # if a user name already exists in DB,  give out a 
    # error message
    IF EXISTS (select user_name from users 
             where user_name = user_name_in) then
       set msg = CONCAT('USER NAME ', user_name_in, ' HAS BEEN USED, PICK ANOTHER ONE');
       signal sqlstate '45000' set message_text = msg;

    ELSEIF user_name_in = '' then 
     set msg = CONCAT('USER NAME CAN NOT BE EMPTY');
       signal sqlstate '45000' set message_text = msg;
  # otherwise set up a user 
  ELSE
     INSERT INTO users(user_name, passcode, birthday, Signup_date, account_type_id, payment_id) 
                 VALUE(user_name_in, psw_in, birthday_in, curdate(), 2, NULL);
    END IF;            
END; | 
DELIMITER ;



# procedure 3  
# upgrade a user from regular to premium
# for now, let's just ignore the other
# type of user (student premium) that I 
# have on account_type table  
          
DROP PROCEDURE IF EXISTS upgrade_user;
 
DELIMITER |
CREATE PROCEDURE upgrade_user(
   user_name_in varchar(50),
   card_no_in varchar(16),
   address_1_in VARCHAR(50), 
   address_2_in VARCHAR(20),
   first_name_in VARCHAR(30),
   last_name_in VARCHAR(20),
   zip_in VARCHAR(6),
   state_in VARCHAR(20),
   city_in VARCHAR(20),
   expiration_date_in date,
   security_code_in varchar(4)
    )

BEGIN
    DECLARE msg varchar(100);
    DECLARE current_type int;

    select account_type_id into current_type from users 
                       where user_name =  user_name_in;

    # if user not exists
    IF NOT EXISTS(select user_name from users where user_name = user_name_in) THEN
       set msg = CONCAT('USER NAME ', user_name_in, ' DOES NOT EXIST');
       signal sqlstate '45000' set message_text = msg;
   
    # if the user is already a premium user
    ELSEIF (current_type = 1) THEN
       set msg = CONCAT('USER NAME ', user_name_in, ' HAS ALREADY BEEN A PREMIUM USER');
       signal sqlstate '45000' set message_text = msg;
   
    # if the credit card is already in the system
    ELSEIF EXISTS (select card_no from payment_profiles 
    	            where card_no = card_no_in) then
       UPDATE users set payment_id = card_no_in where user_name  = user_name_in;
	   UPDATE users set account_type_id = 1 where user_name  = user_name_in;

    # if the credit card is not in our database
	  ELSE
	   INSERT INTO payment_profiles VALUE(card_no_in, address_1_in, address_2_in, 
	   	                                 first_name_in, last_name_in, zip_in, state_in, 
	   	                                 city_in, expiration_date_in, security_code_in);
	   UPDATE users set payment_id = card_no_in where user_name  = user_name_in;
	   UPDATE users set account_type_id = 1 where user_name  = user_name_in;

    END IF;            
END; | 
DELIMITER ;





# procedure 4  
# create a station by either genre, language, artist, albums
# maybe it's a good idea to create another table which contains 
# fields such as headshots, station_name and some parameters which
# can work with the following procedure together dynamically 

DROP PROCEDURE IF EXISTS create_station;
 
DELIMITER |
CREATE PROCEDURE create_station(
	# by_in can only be artist, or album
	# otherwise you will see a error msg
    IN by_in VARCHAR(20) ,
    IN keyword_in VARCHAR(20) 
)


BEGIN
    DECLARE msg varchar(100);

    # if create station by artist
    IF by_in = 'artist' THEN 
       IF exists(select artist_id from artists where artist_name = keyword_in) then 
          select song_name, artist, album_name, headshot, link 
          from songs_info 
          where artist = keyword_in
          group by song_name;
       ELSE 
          set msg = CONCAT('ARTIST ', keyword_in,' DOES NOT EXIST!');
          signal sqlstate '45000' set message_text = msg;
       END IF;

    # if create station by album
	ELSEIF by_in = 'album' THEN 
       IF exists(select album_id from albums where album_name = keyword_in) then 
          select song_name, artist, album_name, headshot, link 
          from songs_info 
          where album_name = keyword_in
          group by song_name;
       ELSE 
          set msg = CONCAT('ALBUM ', keyword_in, ' DOES NOT EXIST!');
          signal sqlstate '45000' set message_text = msg;
       END IF;
    
    # if by_in is not based on 'album' or 'artist'
	ELSE        
	   set msg = CONCAT('STATION CAN ONLY BE CREATED BASED ON ARTIST OR ALBUM');
       signal sqlstate '45000' set message_text = msg;
    
    END IF;            
END; | 
DELIMITER ;




# procedure 5  
# add a album to database        
DROP PROCEDURE IF EXISTS add_album;
 
DELIMITER |
CREATE PROCEDURE add_album(
    IN artist_name_in VARCHAR(20),
    IN issue_date_in date,
    IN album_name_in VARCHAR(100)
)
BEGIN
    DECLARE artist_id_in int;
 
    IF EXISTS(select artist_id from artists where artist_name = artist_name_in) THEN
       set artist_id_in = (select artist_id from artists where artist_name = artist_name_in);
       INSERT INTO albums(album_name, issue_date,artist_id) VALUE(album_name_in, issue_date_in, artist_id_in);

    ELSE 
       insert into artists(artist_name) value(artist_name_in);
       set artist_id_in = (select artist_id from artists where artist_name = artist_name_in);
       INSERT INTO albums(album_name, issue_date,artist_id) VALUE(album_name_in, issue_date_in, artist_id_in);

    END IF;            
END; | 
DELIMITER ;


# procedure 6           
DROP PROCEDURE IF EXISTS show_artists;
 
DELIMITER |
CREATE PROCEDURE show_artists()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT artist_name FROM artists;         
END; | 
DELIMITER ;


# procedure 7          
DROP PROCEDURE IF EXISTS show_genres;
 
DELIMITER |
CREATE PROCEDURE show_genres()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT genre_name FROM genres;         
END; | 
DELIMITER ;



# procedure 8         
DROP PROCEDURE IF EXISTS show_languages;
 
DELIMITER |
CREATE PROCEDURE show_languages()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT language_name FROM languages;         
END; | 
DELIMITER ;




# procedure 9         
DROP PROCEDURE IF EXISTS show_public_playlists;
 
DELIMITER |
CREATE PROCEDURE show_public_playlists()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT playlist_id, playlist_name FROM playlists;         
END; | 
DELIMITER ;




# procedure 10         
DROP PROCEDURE IF EXISTS show_albums;
 
DELIMITER |
CREATE PROCEDURE show_albums()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT distinct album_name FROM albums;         
END; | 
DELIMITER ;



# procedure 11          
# retrieve all songs from a playlist by name         
DROP PROCEDURE IF EXISTS listen_to_a_playlist;
 
DELIMITER |
CREATE PROCEDURE listen_to_a_playlist(
  IN playlist_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select playlist_id from playlists where playlist_name = playlist_name_in) THEN
       set msg = CONCAT('NO PLAYLIST NAMES ', playlist_name_in, '!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
       select song_name, album_name, featuring, featuring2, genre_name,language_name, artist, headshot, link 
     from song_in_playlist 
       natural join songs_info  
       where playlist_id = (select playlist_id from playlists where playlist_name = playlist_name_in) 
       group by song_name;

    END IF;         
END; | 
DELIMITER ;



# procedure 12          
# retrieve songs by album name         
DROP PROCEDURE IF EXISTS listen_to_a_album;
 
DELIMITER |
CREATE PROCEDURE listen_to_a_album(
  IN album_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select album_id from albums where album_name = album_name_in) THEN
       set msg = CONCAT('NO ALBUM NAMES ', album_name_in, '!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
       select song_name, album_name, featuring, featuring2, genre_name,language_name, artist, headshot, link 
       from songs_info 
       where album_name = album_name_in
       group by song_name;

    END IF;         
END; | 
DELIMITER ;



# procedure 13     
# show top 10 most favored songs of last months    
DROP PROCEDURE IF EXISTS show_top_hits;
 
DELIMITER |
CREATE PROCEDURE show_top_hits()
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    select * from last_month_tops natural join songs_info group by song_name;
      
END; | 
DELIMITER ;





# procedure 14          
# retrieve all songs by an artist         
DROP PROCEDURE IF EXISTS listen_to_an_artist;
 
DELIMITER |
CREATE PROCEDURE listen_to_an_artist(
  IN artist_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select artist_id from artists where artist_name = artist_name_in) THEN
       set msg = CONCAT('NO ARTIST NAMES ', artist_name_in, '!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
       select song_name, album_name, featuring, featuring2, genre_name,language_name, artist, headshot, link 
       from songs_info
       where artist = artist_name_in
       group by song_name;

    END IF;         
END; | 
DELIMITER ;




# procedure 15          
# review user-related information 
# user_name is argument      
DROP PROCEDURE IF EXISTS user_account_setting;
 
DELIMITER |
CREATE PROCEDURE user_account_setting(
  IN user_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select user_id from users where user_name = user_name_in) THEN
       set msg = CONCAT('USER ', user_name_in, ' NOT EXIST!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
       select user_name, birthday, signup_date, card_no, address_1, address_2, 
              first_name, last_name, zip, state, city, expiration_date, type_name as user_type
       from users 
       left join payment_profiles on users.payment_id = payment_profiles.card_no 
       left join account_types on account_types.type_id = users.account_type_id
       where user_name = user_name_in;
    END IF;         
END; | 
DELIMITER ;



# procedure 16          
# show table schema 
# table_name is argument      
DROP PROCEDURE IF EXISTS show_schema;
 
DELIMITER |
CREATE PROCEDURE show_schema(
  IN table_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select column_name, data_type
                  from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = table_name_in) THEN
       set msg = CONCAT('TABLE ', table_name_in, ' NOT EXIST!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
      select column_name, column_type
      from INFORMATION_SCHEMA.COLUMNS 
      where TABLE_NAME = table_name_in;

    END IF;         
END; | 
DELIMITER ;



# procedure 17          
# show counts of all tables     
DROP PROCEDURE IF EXISTS show_counts;
 
DELIMITER |
CREATE PROCEDURE show_counts()
BEGIN 

    # QUERY 1 - counts of DB
    (SELECT "TOTAL AMOUNT OF RECORDS IN song_in_playlist TABLE" as table_name, COUNT(*) FROM song_in_playlist)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN favorites TABLE" as table_name, COUNT(*) FROM favorites)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN playlists TABLE" as table_name, COUNT(*) FROM playlists)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN song_from_album TABLE" as table_name, COUNT(*) FROM song_from_album)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN songs TABLE" as table_name, COUNT(*) FROM songs)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN albums TABLE" as table_name, COUNT(*) FROM albums)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN artists TABLE" as table_name, COUNT(*) FROM artists)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN users TABLE" as table_name, COUNT(*) FROM users)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN payment_profiles TABLE" as table_name, COUNT(*) FROM payment_profiles)
    UNION
    (SELECT "tTOTAL AMOUNT OF RECORDS IN account_types TABLE" as table_name, COUNT(*) FROM account_types)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN genres TABLE" as table_name, COUNT(*) FROM genres)
    UNION
    (SELECT "TOTAL AMOUNT OF RECORDS IN languages TABLE" as table_name, COUNT(*) FROM languages);
       
END; | 
DELIMITER ;



# procedure 18          
# log in. return true if credential is correct
# otherwise false    

DROP PROCEDURE IF EXISTS login;
 
DELIMITER |
CREATE PROCEDURE login(
    IN username_in int,
    IN password_in int)
BEGIN 
    DECLARE msg varchar(100);
    DECLARE psw VARCHAR(20) ;
    
    IF EXISTS (select user_name, passcode from users 
             where user_name = username_in and passcode = password_in) then
        select true; 
    ELSE
        select false;  
    END IF;            
END; | 
DELIMITER ;



# procedure 18          
# log in. return true if credential is correct
# otherwise false    
DROP PROCEDURE IF EXISTS fetch_a_song;
 
DELIMITER |
CREATE PROCEDURE fetch_a_song(
  IN song_name_in VARCHAR(50)
  )
BEGIN 
DECLARE msg varchar(100);

    # if playlist not exists
    IF NOT EXISTS(select song_name from songs where song_name = song_name_in) THEN
       set msg = CONCAT('NO SONG NAMES ', song_name_in, '!');
       signal sqlstate '45000' set message_text = msg;
   
    ELSE
       select song_name, album_name, featuring, featuring2, genre_name,language_name, artist, headshot, link 
       from songs_info
       where song_name = song_name_in
       group by song_name;

    END IF;         
END; | 
DELIMITER ;


# procedure 20         
DROP PROCEDURE IF EXISTS show_public_playlists;
 
DELIMITER |
CREATE PROCEDURE show_user_playlists(
    user_name_in varchar(100))
BEGIN 
    # if a user tries to favorite a song that he/she 
    # has favored before, change the favorite_date to 
    # the current date, and don't insert duplicate tuple.
    SELECT playlist_id, playlist_name FROM playlists 
    where user_id = (select user_id from users where user_name = user_name_in);         
END; | 
DELIMITER ;



# procedure 21         
DROP PROCEDURE IF EXISTS add_to_playlist;
 
DELIMITER |
CREATE PROCEDURE add_to_playlist(
    playlist_name_in varchar(100),
    song_name_in varchar(100))
BEGIN 
    INSERT IGNORE INTO song_in_playlist 
           value((select playlist_id from playlists where playlist_name = playlist_name_in),
            (select song_id from songs where song_name = song_name_in));
END; | 
DELIMITER ;




# procedure 21         
DROP PROCEDURE IF EXISTS add_new_playlist;
 
DELIMITER |
CREATE PROCEDURE add_new_playlist(
    playlist_name_in varchar(100),
    user_name_in varchar(100))
BEGIN 
DECLARE msg varchar(100);



    IF EXISTS(select playlist_name_in from playlists where playlist_name = playlist_name_in) THEN
       set msg = CONCAT('PLAYLIST ', playlist_name_in, ' ALREADY EXISTS!');
       signal sqlstate '45000' set message_text = msg;

    ELSEIF playlist_name_in = '' then  
       set msg = CONCAT('PLAYLIST NAME CAN NOT BE NULL!');
       signal sqlstate '45000' set message_text = msg;


    ELSE 
       INSERT IGNORE INTO playlists(playlist_name, is_public, user_id) 
           value(playlist_name_in, 1, (select user_id from users where user_name = user_name_in));
END IF; 
END; | 
DELIMITER ;



# procedure 21         
DROP PROCEDURE IF EXISTS update_psw;
 
DELIMITER |
CREATE PROCEDURE update_psw(
    user_name_in varchar(100),
    new_psw_in varchar(100))
BEGIN 
    INSERT IGNORE INTO song_in_playlist 
           value((select playlist_id from playlists where playlist_name = playlist_name_in),
            (select song_id from songs where song_name = song_name_in));
END; | 
DELIMITER ;




# procedure 22
DROP PROCEDURE IF EXISTS change_payment;
 
DELIMITER |
CREATE PROCEDURE change_payment(
   user_name_in varchar(50),
   card_no_in varchar(16),
   address_1_in VARCHAR(50), 
   address_2_in VARCHAR(20),
   first_name_in VARCHAR(30),
   last_name_in VARCHAR(20),
   zip_in VARCHAR(6),
   state_in VARCHAR(20),
   city_in VARCHAR(20),
   expiration_date_in date,
   security_code_in varchar(4)
    )

BEGIN
    DECLARE msg varchar(100);
    DECLARE current_type int;

    select account_type_id into current_type from users 
                       where user_name =  user_name_in;

    # if user not exists
    IF NOT EXISTS(select user_name from users where user_name = user_name_in) THEN
       set msg = CONCAT('USER NAME ', user_name_in, ' DOES NOT EXIST');
       signal sqlstate '45000' set message_text = msg;
   
   
    # if the credit card is already in the system
    ELSEIF EXISTS (select card_no from payment_profiles 
                  where card_no = card_no_in) then
       UPDATE users set payment_id = card_no_in where user_name  = user_name_in;
       UPDATE users set account_type_id = 1 where user_name  = user_name_in;

    # if the credit card is not in our database
    ELSE
       INSERT INTO payment_profiles VALUE(card_no_in, address_1_in, address_2_in, 
                                       first_name_in, last_name_in, zip_in, state_in, 
                                       city_in, expiration_date_in, security_code_in);
       UPDATE users set payment_id = card_no_in where user_name  = user_name_in;
       UPDATE users set account_type_id = 1 where user_name  = user_name_in;

    END IF;            
END; | 
DELIMITER ;





# procedure 22         
DROP PROCEDURE IF EXISTS remove_from_playlist;
 
DELIMITER |
CREATE PROCEDURE remove_from_playlist(
    playlist_name_in varchar(100),
    song_name_in varchar(100))
BEGIN 
    DELETE IGNORE FROM song_in_playlist 
            where playlist_id = (select playlist_id from playlists where playlist_name = playlist_name_in) and 
            song_id = (select song_id from songs where song_name = song_name_in);
END; | 
DELIMITER ;