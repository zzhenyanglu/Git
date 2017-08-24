DROP TABLE IF EXISTS song_in_playlist;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS song_from_album;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS payment_profiles;
DROP TABLE IF EXISTS account_types;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS languages;
DROP TABLE IF EXISTS stats;
DROP VIEW IF EXISTS songs_info;

CREATE TABLE stats (
Table_name varchar(20) primary key,
tuples int
);

CREATE TABLE languages(
   language_ID smallint primary key auto_increment,
   language_name VARCHAR(20) NOT NULL unique
);

CREATE TABLE genres(
   genre_ID smallint primary key auto_increment,
   genre_name VARCHAR(20) NOT NULL unique 
);

CREATE TABLE account_types(
   type_ID smallint primary key auto_increment,
   type_name VARCHAR(20) NOT NULL unique,
   type_description VARCHAR(50) NOT NULL,
   price decimal(3,2)
);

CREATE TABLE payment_profiles(
   # credit card no is unique, so it's the PK
   card_no varchar(16) primary key,
   address_1 VARCHAR(50) NOT NULL, 
   address_2 VARCHAR(20),
   first_name VARCHAR(30) not null,
   last_name VARCHAR(20) not null,
   zip VARCHAR(6) not null,
   state VARCHAR(20) not null,
   city VARCHAR(20) not null,
   expiration_date date not null,
   security_code varchar(4) not null
);


CREATE TABLE users(
   user_id int primary key auto_increment,
   user_name VARCHAR(50) not null unique,
   passcode VARCHAR(20) not null,
   birthday date,
   signup_date date not null,
   account_type_id smallint not null,
   payment_id varchar(16), 
   
   foreign key  (account_type_id)
   references account_types (type_id) 
   on delete restrict
   on update cascade,
   
   foreign key  (payment_id)
   references payment_profiles (card_no) 
   on delete set null
   on update cascade
);

CREATE TABLE artists(
   artist_ID int primary key auto_increment, 
   artist_name VARCHAR(20) not null unique,
   birthday date,
   country_origin varchar(20),
   headshot varchar(200),
   # Not applicable is for BAND ! 
   gender ENUM('Female','Male','Unknown','Not Applicable'),
   # True or False
   is_band bool not null

);

CREATE TABLE albums(
   album_ID int primary key auto_increment, 
   album_name VARCHAR(100) not null,
   issue_date date,
   # since each album belongs only to one singer, so 
   # I'm not going to make an independent relationship
   # table for singer and album. INSTEAD just attach  
   # singer ID to each album.
   artist_id int, 
   headshot varchar(200),

   foreign key  (artist_id)
   references artists (artist_id) 
   on delete set null
   on update cascade
);

# since one song can only belong to one singer and
# featuring is represented as another column in 
# song table, so I will not create an independent 
# relationship table between a song and artist. 

CREATE TABLE songs(
   song_id int primary key auto_increment, 
   song_name VARCHAR(80) not null,
   link VARCHAR(100), 
   genre_id smallint not null, 
   language_id smallint not null, 
   artist_id int, 
   featuring_1 int, 
   featuring_2 int,
   play_times int DEFAULT 0, 

   foreign key  (featuring_1)
   references artists (artist_id) 
   on delete restrict
   on update cascade,

   foreign key  (featuring_2)
   references artists (artist_id) 
   on delete restrict
   on update cascade,
   
   foreign key  (artist_id)
   references artists (artist_id) 
   on delete restrict
   on update cascade, 
   
   foreign key  (genre_id)
   references genres (genre_id) 
   on delete restrict
   on update cascade,
   
   foreign key  (language_id)
   references languages (language_id) 
   on delete restrict
   on update cascade
);

# song_from_album is a weak entity
# which is supported both by song_id
# and album_id, each song can be contained
# by many album, and each album contains
# many songs. 

CREATE TABLE song_from_album(

   song_id int,  
   album_id int,
   
   primary key(song_id, album_id),
   
   foreign key  (song_id)
   references songs (song_id) 
   on delete cascade
   on update cascade,
   
   foreign key  (album_id)
   references albums (album_id) 
   on delete cascade
   on update cascade
);

# each playlist can be created by only one 
# user so I will not create an independent 
# table to show relationship between user
# and playlist INSTEAD just append to whom
# each playlist belongs to the records.

CREATE TABLE playlists( 
   playlist_id int auto_increment primary key,
   playlist_name varchar(50),
   is_public bool,
   user_id int,
   
   foreign key  (user_id)
   references users (user_id) 
   on delete cascade
   on update cascade
);

CREATE TABLE song_in_playlist( 
   playlist_id int,
   song_id int,
   
   primary key(song_id, playlist_id),
   
   foreign key (song_id)
   references songs (song_id) 
   on delete cascade
   on update cascade,

   foreign key  (playlist_id)
   references playlists (playlist_id) 
   on delete cascade
   on update cascade
);

CREATE TABLE favorites( 
   favorite_date date not null,
   user_id int not null,
   song_id int not null,	
   
   primary key (user_id, song_id),
   
   foreign key  (user_id)
   references users (user_id) 
   on delete cascade
   on update cascade,
   
   foreign key  (song_id)
   references songs (song_id) 
   on delete cascade
   on update cascade
);

create view songs_info as 
   select songs.song_id, song_name, album_name, a2.artist_name as featuring, 
          a3.artist_name as featuring2, genre_name, language_name, 
          a1.artist_name as artist, a1.headshot, link
   from songs natural join genres 
              natural join languages 
              natural join artists a1 
              right join song_from_album on songs.song_id = song_from_album.song_id 
              left join albums on albums.album_ID = song_from_album.album_id
              left join artists a2 on songs.featuring_1 = a2.artist_ID 
              left join artists a3 on songs.featuring_2 = a3.artist_ID;