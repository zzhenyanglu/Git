***********************************;
* THE PROC FORMAT FOR CACdirect 3.0;
***********************************;

***********************************;
* STATUS;
*  ETECH ADDED MWM 4/13/2012;
*  MACTCHMAKER QC VARAIBLES ADDED JDS 4/23/2012
***********************************;

proc format;
value cac_le_a
    .='Unknown - New to File'
    0='No'
    1='Yes'
;

value cac_le_b
    .='Unknown - New to File'
    0='No'
    1='Decrease'
    2='Increase'
;  

value $cac_le_c
    ''='Unknown - New to File'
    'newer home' = 'Newer Home'
    'older home' = 'Older Home'
;  

value match
    0='No'
    1='Yes';
;

value geo_match
    1='Match @ Zip+2'
    2='Match @ Zip'
    3='Match @ State'
;
value $cac_cdi
   'A' = 'Top 20 MSAs, approx. 35% of US households'
   'B' = 'Next 55 MSAs, approx. 21% of US households'
   'C' = 'Counties with density greater than 44 hh/mile'
   'D' = 'Counties with density less than 44 hh/mile'
    other='Unknown'
;

value prod_act
    1='Production Active'
    2='Supplemental Active'
    3='Inactive'
;

value cac_act
    0='Inactive'
    1='Active'
;
value cac_prod
    0='Supplemental'
    1='Production'
;

value cac_kids
   0='No Children'
   1='Children Present'  
   other='Unknown'
; 

value cac_mar
   1 = 'At Least 1 Married'
   2 = 'At Least 1 Single'
   3 = 'Both Married and single'
   other='Unknown'
;

value cac_age
   1 = '18-24 Years Old'
   2 = '25-34 Years Old'
   3 = '35-44 Years Old'
   4 = '45-54 Years Old'
   5 = '55-64 Years Old'
   6 = '65-74 Years Old'
   7 = '75+ Years Old'
   other = 'Unknown'
;

value $cac_inc
   '1'='$0 - $14,999'
   '2'='$15,000 - $19,999'
   '3'='$20,000 - $29,999'
   '4'='$30,000 - $39,999'
   '5'='$40,000 - $49,999'
   '6'='$50,000 - $74,999'
   '7'='$75,000 - $99,999'
   '8'='$100,000 - $124,999'
   '9'='$125,000 - $149,999'
   'A'='$150,000 - $174,999'
   'B'='$175,000 - $199,999'
   'C'='$200,000 - $249,999'
   'D'='$250,000 or More'
   other='Unknown'
;

value $cac_ninc
'0'= '$0 - $14,999'
'1'= '$15,000 - $19,999'
'2'= '$20,000 - $24,999'
'3'= '$25,000 - $29,999'
'4'= '$30,000 - $34,999'
'5'= '$35,000 - $39,999'
'6'= '$40,000 - $44,999'
'7'= '$45,000 - $49,999'
'8'= '$50,000 - $54,999'
'9'= '$55,000 - $59,999'
'A'= '$60,000 - $64,999'
'B'= '$65,000 - $69,999'
'C'= '$70,000 - $74,999'
'D'= '$75,000 - $79,999'
'E'= '$80,000 - $84,999'
'F'= '$85,000 - $89,999'
'G'= '$90,000 - $94,999'
'H'= '$95,000 - $99,999'
'I'= '$100,000 - $104,999'
'J'= '$105,000 - $109,999'
'K'= '$110,000 - $114,999'
'L'= '$115,000 - $119,999'
'M'= '$120,000 - $124,999'
'N'= '$125,000 - $129,999'
'O'= '$130,000 - $134,999'
'P'= '$135,000 - $139,999'
'Q'= '$140,000 - $144,999'
'R'= '$145,000 - $149,999'
'S'= '$150,000 - $159,999'
'T'= '$160,000 - $169,999'
'U'= '$170,000 - $174,999'
'V'= '$175,000 - $189,999'
'W'= '$190,000 - $199,999'
'X'= '$200,000 - $224,999'
'Y'= '$225,000 - $249,999'
'Z'= '$250,000 or More'
other = 'Unknown'
;

value $silh_ld
   'A' = 'Rough Beginnings'
   'B' = 'Rustic Life'
   'C' = 'Wheels of the City'
   'D' = 'On Their Way'
   'E' = 'All About Town'
   'F' = 'Business Life'
   'G' = 'Flying Solo'
   'H' = 'White Picket Fence'
   'I' = 'Down Home'
   'J' = 'Good Times'
   'K' = 'Privileged Providers'
   'L' = 'County Seat'
   'M' = 'Make it Somehow'
   'N' = 'Power Players'
   'O' = 'Securing the Nest'
   'P' = 'Rocky Retirement'
   'Q' = 'Golden Sunset'
   other = 'Unscored'
;

value $silh_super
   'A' = 'Rough Beginnings'
   'B' = 'White Picket Fence'
   'C' = 'On Their Way'
   'D' = 'Rustic Life'
   'E' = 'Privileged Providers'
   'F' = 'Good Times'
   'G' = 'Power Players'
   'H' = 'Down Home'
   'I' = 'Securing the Nest'
   'J' = 'Make it Somehow'
   'K' = 'Rocky Retirement'
   'L' = 'Golden Sunset'
   other = 'Unscored'
;

value $silh
'A1'='Shes in the Now'
'A2'='Hes Starting Out'
'A3'='Shes Still Here'
'A4'='Hes Still Here'
'A5'='Shes Left Behind'
'A6'='Hes Settling In'
'B1'='Starting Out Families'
'B2'='Americana Families'
'B3'='Emerging Wealthy'
'B4'='Young Neighbors'
'C1'='Wall Street Dreaming'
'C2'='Execs on the Move'
'C3'='Successful Social Techies'
'C4'='The Culturally Connected '
'C5'='New Luxury'
'D1'='Outskirts '
'D2'='Shes a Little Bit Country'
'D3'='Country Gals'
'D4'='Growin up Country'
'D5'='NASCAR Country'
'E1'='Suburban Family'
'E2'='Suburban Bourgeoisie'
'E3'='Executive Families'
'E4'='Successful Providers'
'F1'='Midlife Survivor'
'F2'='Alone in the City'
'F3'='Solo in Style'
'F4'='Emerging Urban Executives'
'F5'='Cultural Singles'
'F6'='Comfortable Singles'
'F7'='The Intellectual'
'G1'='Downtown Success'
'G2'='Power Elite'
'G3'='Arrived'
'H1'='Rustic Families'
'H2'='Small Town Providers'
'H3'='Neighborly Families'
'H4'='Established Families'
'H5'='Cultured Elite'
'I1'='Metro Couples'
'I2'='In The Now'
'I3'='Settling by the Fire'
'I4'='Metro Nesters'
'I5'='Rural Empty Nesters'
'J1'='Retiring Needy'
'J2'='Her Hometown'
'J3'='The Retiring'
'J4'='Simple Life Retirees'
'K1'='Hanging On'
'K2'='Rustic Retired'
'K3'='Settled In Seniors'
'K4'='Living Off the Land'
'L1'='The Cultural Estate'
'L2'='Settled in the Suburbs'
'L3'='Settled in the Country'
'L4'='Social Seniors'
'L5'='Single Seniors'
'L6'='Cultured Alone'
'XX'='Unscored'
other='Unscored'
;

value pofaage
 .,0='None Present or Not Available'
   1='Male present'
   2='Female present'
   3='Male and Female present'
   4='Unknown Gender present'
   5='Male and Unknown Gender present'
   6='Female and Unknown Gender present'
   7='Male, Female and Unknown Gender present'
;

value pofaagi
   0='Not Available'
   1='Adult Present'
;

value cac_edu
0='Unknown'
1='Some high school or less'
2='High school'
3='Some college'
4='College'
5='Graduate school'
;

value cac_occ
0="Unknown/No Data"
1="Physician/Dentist"
2="Health Care"
3="Lawyers/Judges"
5="Professional/Technical"
6="Management"
7="Teacher Educator"
8="Sales/Marketing"
9="Clerical/Service Worker"
10="Tradesman/Machine Oper / Laborer"
11="Farmer"
12="Student"
13="Homemaker"
14="Retired"
15="Federal Employee"
16="Federal Employee Retired"
17="Military"
18="Military Retired"
19="Other"
20="Business Owner"
;


value $etethnic
"00" =  "UNCODED"
"01" =  "ENGLISH"
"02" =  "SCOTTISH"
"03" =  "DANISH"
"04" =  "SWEDISH"
"05" =  "NORWEGIAN"
"06" =  "FINNISH"
"07" =  "ICELANDIC"
"08" =  "DUTCH"
"09" =  "BELGIAN"
"10" =  "GERMAN"
"11" =  "AUSTRIAN"
"12" =  "HUNGARIAN"
"13" =  "CZECH"
"14" =  "SLOVAK"
"15" =  "IRISH"
"16" =  "WELSH"
"17" =  "FRENCH"
"18" =  "SWISS"
"19" =  "ITALIAN"
"20" =  "HISPANIC"
"21" =  "PORTUGUESE"
"22" =  "POLISH"
"23" =  "ESTONIAN"
"24" =  "LATVIAN"
"25" =  "LITHUANIAN"
"26" =  "UKRAINIAN"
"27" =  "GEORGIAN"
"28" =  "BYELORUSSIAN"
"29" =  "ARMENIAN"
"30" =  "RUSSIAN"
"31" =  "TURKISH"
"32" =  "KURDISH"
"33" =  "GREEK"
"34" =  "PERSIAN"
"35" =  "MOLDOVAN"
"36" =  "BULGARIAN"
"37" =  "ROMANIAN"
"38" =  "ALBANIAN"
"39" =  "NATIVE AMERICAN"
"40" =  "SLOVENIAN"
"41" =  "CROATIAN"
"42" =  "SERBIAN"
"43" =  "BOSNIAK"
"44" =  "AZERBAIJANI"
"45" =  "KAZAKH"
"46" =  "AFGHAN"
"47" =  "PAKISTANI"
"48" =  "BANGLADESHI"
"49" =  "INDONESIAN"
"50" =  "INDIAN"
"51" =  "BURMESE (MYANMAR)"
"52" =  "MONGOLIAN"
"53" =  "CHINESE"
"56" =  "KOREAN"
"57" =  "JAPANESE"
"58" =  "THAI"
"59" =  "MALAY"
"60" =  "LAOTIAN"
"61" =  "KHMER"
"62" =  "VIETNAMESE"
"63" =  "SRI LANKAN"
"64" =  "UZBEK"
"65" =  "OTHER ASIAN"
"66" =  "JEWISH"
"67" =  "ALEUT"
"68" =  "HEBREW"
"70" =  "ARAB"
"72" =  "TURKMEN"
"73" =  "TAJIK"
"74" =  "KIRGHIZ"
"75" =  "SAUDI"
"76" =  "IRAQI"
"77" =  "LIBYAN"
"78" =  "EGYPTIAN"
"79" =  "RWANDAN"
"7A" =  "HINDU"
"7B" =  "DJIBOUTIAN"
"7C" =  "MANX"
"7D" =  "TELUGU"
"7E" =  "NEPALESE"
"7F" =  "SAMOAN"
"7G" =  "MAURITANIAN"
"7H" =  "INUIT"
"80" =  "TONGAN"
"81" =  "SENEGALESE"
"82" =  "MALAWIAN"
"83" =  "SUDANESE"
"84" =  "MOROCCAN"
"85" =  "AFRICAN AMERICAN"
"86" =  "KENYAN"
"87" =  "NIGERIAN (NIGERIA)"
"88" =  "GHANAIAN"
"89" =  "ZAMBIAN"
"8A" =  "CONGOLESE"
"8B" =  "CENTRAL AFRICAN (CENTRAL AFRICAN REPUBLIC)"
"8C" =  "TOGOLESE"
"8D" =  "BAHRAINI"
"8E" =  "QATARI"
"8F" =  "GUYANESE"
"8G" =  "TIBETAN"
"8H" =  "FIJIAN"
"8I" =  "SWAZI"
"8J" =  "ZULU"
"8K" =  "XHOSA"
"8L" =  "BASOTHO"
"8M" =  "SOUTH AFRICAN"
"8N" =  "LIBERIAN"
"8O" =  "COMORAN"
"8P" =  "BENINESE"
"8Q" =  "BURKINABE (BURKINA FASO)"
"8R" =  "NIGERIEN (NIGER)"
"8S" =  "ASHANTI"
"8T" =  "SWAHILI"
"8U" =  "HAITIAN"
"8V" =  "MALIAN"
"8W" =  "JAMAICAN"
"8X" =  "HAUSA"
"8Y" =  "PILI"
"90" =  "CONGOLESE (DRG)"
"91" =  "SURINAMESE"
"92" =  "MOZAMBICAN (MOZAMBIQUE)"
"93" =  "IVORIAN (IVORY COAST)"
"94" =  "BHUTANESE"
"95" =  "ETHIOPIAN"
"96" =  "UGANDAN"
"97" =  "BATSWANA (BOTSWANA)"
"98" =  "CAMEROONIAN"
"99" =  "ZIMBABWEAN"
"9A" =  "NAMIBIAN"
"9B" =  "BURUNDI"
"9C" =  "TANZANIAN"
"9D" =  "GAMBIAN"
"9E" =  "SOMALI"
"9F" =  "MACEDONIAN"
"9G" =  "CHADIAN"
"9H" =  "GABONESE"
"9I" =  "ANGOLAN"
"9J" =  "CHECHEN"
"9K" =  "IGBO"
"9L" =  "YORUBA"
"9M" =  "ALGERIAN"
"9N" =  "FILIPINO"
"9O" =  "SOTHO (LESOTHO)"
"9P" =  "TUNISIAN"
"9Q" =  "HAWAIIAN"
"9R" =  "MALAGASY (MADAGASCAR)"
"9S" =  "BASQUE"
"9T" =  "SIERRA LEONEAN"
"9U" =  "KUWAITI"
"9V" =  "YEMENI"
"9W" =  "GUINEAN (GUINEA-BISSAU)"
"9X" =  "PAPUA NEW GUINEAN"
"9Y" =  "EQUATORIAL GUINEAN"
"9Z" =  "SYRIAN"
"A1" =  "AFRICAN AMERICAN"
"A2" =  "AFRICAN AMERICAN"
"A3" =  "AFRICAN AMERICAN"
"A4" =  "AFRICAN AMERICAN"
"A5" =  "AFRICAN AMERICAN"
"D1" =  "AFRICAN AMERICAN"
"D2" =  "AFRICAN AMERICAN"
"D3" =  "AFRICAN AMERICAN"
"D4" =  "AFRICAN AMERICAN"
"D5" =  "AFRICAN AMERICAN"
"E1" =  "AFRICAN AMERICAN"
"E2" =  "AFRICAN AMERICAN"
"E3" =  "AFRICAN AMERICAN"
"E4" =  "AFRICAN AMERICAN"
"E5" =  "AFRICAN AMERICAN"
"F1" =  "AFRICAN AMERICAN"
"F2" =  "AFRICAN AMERICAN"
"F3" =  "AFRICAN AMERICAN"
"F4" =  "AFRICAN AMERICAN"
"F5" =  "AFRICAN AMERICAN"
"I1" =  "AFRICAN AMERICAN"
"I2" =  "AFRICAN AMERICAN"
"I3" =  "AFRICAN AMERICAN"
"I4" =  "AFRICAN AMERICAN"
"I5" =  "AFRICAN AMERICAN"
"S1" =  "AFRICAN AMERICAN"
"S2" =  "AFRICAN AMERICAN"
"S3" =  "AFRICAN AMERICAN"
"S4" =  "AFRICAN AMERICAN"
"S5" =  "AFRICAN AMERICAN"
"U1" =  "AFRICAN AMERICAN"
"U2" =  "AFRICAN AMERICAN"
"U3" =  "AFRICAN AMERICAN"
"U4" =  "AFRICAN AMERICAN"
"U5" =  "AFRICAN AMERICAN"
"UC" =  "UNCODABLE RECORDS"
"W1" =  "AFRICAN AMERICAN"
"W2" =  "AFRICAN AMERICAN"
"W3" =  "AFRICAN AMERICAN"
"W4" =  "AFRICAN AMERICAN"
"W5" =  "AFRICAN AMERICAN"
"ZZ" =  "MULTI ETHNIC";

value $etrelig
"B" =  "BUDDHIST"
"C" =  "CATHOLIC"
"E" =  "ETHIOPIAN ORTHODOX"
"G" =  "GREEK ORTHODOX"
"H" =  "HINDU"
"I" =  "MUSLIM"
"J" =  "JEWISH"
"K" =  "SIKH"
"L" =  "LUTHERAN"
"M" =  "MORMON"
"O" =  "EASTERN ORTHODOX"
"P" =  "PROTESTANT"
"S" =  "SHINTO"
"X" =  "UNCODED";

value $etlang
"00" =  "UNKNOWN"
"01" =  "ENGLISH"
"03" =  "DANISH"
"04" =  "SWEDISH"
"05" =  "NORWEGIAN"
"06" =  "FINNISH"
"07" =  "ICELANDIC"
"08" =  "DUTCH"
"09" =  "FLEMISH/WALLOON"
"10" =  "GERMAN"
"12" =  "HUNGARIAN"
"13" =  "CZECH"
"14" =  "SLOVAK"
"17" =  "FRENCH"
"19" =  "ITALIAN"
"20" =  "SPANISH"
"21" =  "PORTUGUESE"
"22" =  "POLISH"
"23" =  "ESTONIAN"
"24" =  "LATVIAN"
"25" =  "LITHUANIAN"
"27" =  "GEORGIAN"
"29" =  "ARMENIAN"
"30" =  "RUSSIAN"
"31" =  "TURKISH"
"32" =  "KURDISH"
"33" =  "GREEK"
"34" =  "FARSI"
"35" =  "MOLDOVAN"
"36" =  "BULGARIAN"
"37" =  "ROMANIAN"
"38" =  "ALBANIAN"
"40" =  "SLOVENIAN"
"41" =  "SERBO-CROATIAN"
"44" =  "AZERI"
"45" =  "KAZAKH"
"46" =  "PASHTU/PASHTO"
"47" =  "URDU"
"48" =  "BENGALI/BANGLA"
"49" =  "BAHASA INDONESIA"
"51" =  "BURMESE"
"52" =  "MONGOLIAN"
"53" =  "CHINESE"
"56" =  "KOREAN"
"57" =  "JAPANESE"
"58" =  "THAI"
"59" =  "BAHASA MELAYU"
"60" =  "LAO"
"61" =  "KHMER"
"62" =  "VIETNAMESE"
"63" =  "SINHALA"
"64" =  "UZBEK"
"68" =  "HEBREW"
"70" =  "ARABIC"
"72" =  "TURKMEN"
"73" =  "TAJIK"
"74" =  "KIRGHIZ"
"7A" =  "HINDI"
"7E" =  "NEPALI"
"7F" =  "SAMOAN"
"80" =  "TONGAN"
"86" =  "OROMO"
"88" =  "GA"
"8G" =  "TIBETAN"
"8I" =  "SISWATI"
"8J" =  "ZULU"
"8K" =  "XHOSA"
"8M" =  "AFRIKAANS"
"8O" =  "COMORIAN/SHIKOMORO"
"8S" =  "TWI (OF ASHANTI ETHNICITY)"
"8T" =  "SWAHILI"
"8X" =  "HAUSA"
"92" =  "BANTU"
"94" =  "DZONGKHA"
"95" =  "AMHARIC"
"97" =  "TSWANA"
"9E" =  "SOMALI"
"9F" =  "MACEDONIAN"
"9K" =  "IGBO"
"9L" =  "YORUBA"
"9N" =  "TAGALOG"
"9O" =  "SOTHO"
"9R" =  "MALAGASY"
"9S" =  "BASQUE";


value $ethisporg
"00" =  "UNKNOWN"
"01" =  "MEXICO"
"02" =  "CUBA"
"03" =  "PUERTO RICO"
"04" =  "NICARAGUA"
"05" =  "DOMINICAN REPUBLIC"
"06" =  "COLOMBIA"
"07" =  "HONDURAS"
"08" =  "GUATEMALA"
"09" =  "EL SALVADOR"
"10" =  "COSTA RICA"
"11" =  "PANAMA"
"12" =  "ECUADOR"
"13" =  "VENEZUELA"
"14" =  "ARGENTINA"
"15" =  "CHILE"
"16" =  "PERU"
"17" =  "BOLIVIA"
"18" =  "URUGUAY"
"19" =  "PARAGUAY"
"20" =  "SPAIN"
"22" =  "BRAZIL";

value $ethispasm
"1" =  "ASSIMILATED"
"2" =  "BILINGUAL ENGLISH"
"3" =  "BILINGUAL SPANISH"
"4" =  "UNASSIMILATED"
"0" =  "UNKNOWN";

value $etasiaasm
"1" =  "ASSIMILATED"
"2" =  "BILINGUAL ENGLISH"
"3" =  "BILINGUAL NATIVE"
"4" =  "UNASSIMILATED"
"0" =  "UNKNOWN";

value $etgender
"1" =      "MALE"
"2" =      "FEMALE"
"3" =      "EITHER"
"0" =      "UNKNOWN";

run;



