# trigger 1  
# if you insert a song without referring an existing artist 
# the trigger will create a new artist for you, you could 
# later change the name of that artist by modifying artists table.              
DROP TRIGGER IF EXISTS Insert_songs;
 
DELIMITER |
CREATE TRIGGER Insert_songs
BEFORE INSERT ON songs
FOR EACH ROW
BEGIN 
	INSERT IGNORE INTO artists(artist_id, artist_name, birthday, country_origin, headshot, gender, is_band) 
    values(new.artist_id, 'unknown artist',  NULL, NULL, NULL, NULL, 0);
                
END; | 
DELIMITER ;


# trigger 2 - 
# preventing a user from favoriting a song twice

DROP TRIGGER IF EXISTS Insert_favorites;
 
DELIMITER |
CREATE TRIGGER Insert_favorites
BEFORE INSERT ON favorites
FOR EACH ROW
BEGIN 
DECLARE last_fav_date date;
DECLARE msg varchar(100);
    SET last_fav_date = (select favorite_date from favorites where user_id = new.user_id and song_id = new.song_id);
 
    IF last_fav_date is not NULL THEN 
        set msg = CONCAT('USER ', new.user_id, ' HAS FAVORITED SONG_ID ', new.song_id, ' BEFORE ON ', last_fav_date);
        signal sqlstate '45000' set message_text = msg;
	END IF;
END; | 
DELIMITER ;



# trigger 3 
# I created a table to record how many tuples other tables contains,
# this trigger updates the number of songs that table songs contains
# automatically. 

DROP TRIGGER IF EXISTS update_stats;
 
DELIMITER |
CREATE TRIGGER update_stats
AFTER INSERT ON songs
FOR EACH ROW
BEGIN 
     UPDATE stats SET tuples = ( select count(*) from songs ) where table_name = 'songs';

END; | 
DELIMITER ;


