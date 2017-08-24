# scenario 1 - Insert_songs
####################################################################
# if you insert the following line and then you do  
 select * from artists;  
# you will not see any difference on table artists before and after 
insert into songs (song_name, link, genre_id, language_id, artist_id, featuring_1,featuring_2) 
	values('hahaha','default',4,1,1,NULL,NULL);


# if you insert the following line again and then you do  
# you will see on table artists a artist with artist_id as 200 
# whose name is unknown artist. 

insert into songs (song_name, link, genre_id, language_id, artist_id, featuring_1,featuring_2) 
	values('xixixi','default',4,1,200,NULL,NULL);


# check the new created artist on artists table
     select * from artists where artist_id = 200;  


# scenario 2 - Insert_favorites
####################################################################
# please run the following query and remember the first record
      select * from favorites order by user_id, song_id;
# then let's run the following DML query

# suppose yesterday user with user_id as 1 favorited a song with song_id as 2 
# and today user_id 1 forgot, and tries to favorite the same song again, by 
# the following query. The trigger will pop up a message to remind that this 
# user has favorite the song before and stop the action. 
INSERT INTO favorites(favorite_date, song_id, user_id) VALUE('2016-11-17',2,1);

# if user_id 1 instead favorite another song with song_id as 1 then the user will
# not see any error message 

INSERT INTO favorites(favorite_date, song_id, user_id) VALUE('2016-11-17',1,1);

# check the results
select * from favorites where user_id = 1 and song_id =1 ;



# scenario 3 - update_stats
######################################################################
# Basically every time a new song is inserted into table songs, the stats 
# will get updated. Please run the following query and remember the 4st tuple,
# which is how many songs are there on table songs. 
     select * from stats order by Table_name desc;
# Then run the following DML query

insert into songs (song_name, link, genre_id, language_id, artist_id, featuring_1,featuring_2) 
values('Oops..',NULL,26,11,1,NULL,NULL);

# rerun the following query and see the difference of the 4st tuple, which should 
# be 1 more now.
     select * from stats order by Table_name desc;


# Now, let's try a DML query that's not triggering update_stats trigger
delete from songs where song_name = 'Oops..';

# rerun the following query and observe that the 4st tuple is still the same
# though it should be 1 less now. 

     select * from stats order by Table_name desc;