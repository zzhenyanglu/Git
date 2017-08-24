# scenario 1 - favorite_a_song         
# please run the following query and remember the first record
      select * from favorites order by user_id, song_id;
# then let's run the procedure to favor the same song with the 
# same user again, the favorite_date field should be modified
# to the current date.

# favorite_a_song(IN user_id_in int, IN song_id_in int)
call favorite_a_song(1, 2);

# let's call the procedure again, only this time user_id 1
# has never favored song_id 3 before. so table favorites
# shoudld have a more field 

# favorite_a_song(IN user_id_in int, IN song_id_in int)
call favorite_a_song(1, 3);

# use the same query to check that user_id 1 now has 
# favored song_id 3
       select * from favorites where user_id=1 and song_id=3;




# procedure 2  
# create a regular user 
# create_user(IN user_name_in VARCHAR(50) ,
#            IN psw_in VARCHAR(20) ,
#            IN birthday_in date)

# try to create a user with a user name already exists
# you should see an error msg pops up
call create_user('felixthecat', '1234', '2015-01-01');

# try again with a non-existing user name
call create_user('1hahahaha', '1234', '2015-01-01');

# check the results by 
select * from users where user_name = '1hahahaha';



# procedure 3  
# upgrade a user from regular to premium

# CREATE PROCEDURE upgrade_user(
#   user_name_in varchar(50),
#   card_no_in varchar(16),
#   address_1_in VARCHAR(50), 
#   address_2_in VARCHAR(20),
#   first_name_in VARCHAR(30),
#   last_name_in VARCHAR(20),
#   zip_in VARCHAR(6),
#   state_in VARCHAR(20),
#   city_in VARCHAR(20),
#   expiration_date_in date,
#   security_code_in varchar(4))

# let's upgrade a user that's not exists
# you should see error msg
call upgrade_user('somebody','1234567890', '930 Northbrook Blvd', 'APT 309','donald','trump','60301','IL','Oak Park','2020-08-23','1099');


# Let's upgrade user '1hahahaha' we just created to premium users
# before we do, run this query to see this user's profile before action by
select * from users where user_name = '1hahahaha';

# now let's upgrade this user to premium
call upgrade_user('1hahahaha','1234567890', '930 Northbrook Blvd', 'APT 309','donald','trump','60301','IL','Oak Park','2020-08-23','1099');

# try to run this query again and you will see the payment_id 
# has been modified and account_type_id has been set to 1, which
# is premium user type.
select * from users where user_name = '1hahahaha';

# also see the payment_profiles table
# there is a new record inserted into it, 
# whose index is '1234567890'
select * from payment_profiles where card_no = '1234567890';

# procedure 4  
# create a station by either genre, language, artist, albums

# CREATE PROCEDURE create_station(
#    IN by_in VARCHAR(20) ,
#    IN keyword_in VARCHAR(20))

# try to create a valid station
call create_station('artist', 'Drake');
call create_station('album', 'X&Y');


# try to create a station by genre 'R&B'
# you will see error message
call create_station('genre', 'R&B');



# procedure 5  
# add a album to database        

#CREATE PROCEDURE add_album(
#    IN artist_name_in VARCHAR(20),
#    IN issue_date_in date,
#    IN album_name_in VARCHAR(100))

# create an album whose artist is on the artists DB
call add_album('Drake','2016-11-17','1hahaha');

# check the result by 
select * from albums where album_name = '1hahaha';


# create an album whose artist is not on the artists DB
call add_album('1hahaha','2016-11-17','2hahaha');

# check the result by 
select * from albums where album_name = '2hahaha';

# notice there is an artist called '1hahaha' on artist table 
select * from artists where artist_name = '1hahaha';



# procedure 6 
call show_artists();



# procedure 7  
call show_genres();



# procedure 8  
call show_languages();



# procedure 9  
call show_public_playlists();


# procedure 10  
call show_albums();


# procedure 11
# first get all the public playlists (procedure 9) and then run procedure 10
# with a playlist name as argument 
call listen_to_a_playlist('Exotic');
# try it with a non existing playlist
call listen_to_a_playlist('ha');



# procedure 12
# first get all the public playlists (procedure 9) and then run procedure 10
# with a playlist name as argument 
call listen_to_a_album('Views');

# try it with a non existing album
call listen_to_a_album('ha');



# procedure 13
# show last month's top favored songs 
call show_top_hits();


# procedure 14
# fetch all songs by artist name
call listen_to_an_artist('Drake');

# try a non existing artist
call listen_to_an_artist('haha');




# procedure 15
# fetch all songs by artist name
call user_account_setting('felixthecat');

# try a non existing artist
call user_account_setting('haha');



# procedure 16
# fetch all songs by artist name
call show_schema('users');

# try a non existing artist
call show_schema('haha');



# procedure 17
call show_counts();