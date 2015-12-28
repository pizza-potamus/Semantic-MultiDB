set serveroutput on;
DECLARE
--parser object creates a t_array to store words in user's query
global_query parser.t_array;
--var to store sql keywords
sql_word varchar2(200);
--int vars to hold locations of SELECT, FROM, and WHERE
SELECT_num int;
FROM_num int;
WHERE_num int;
--int vars to hold the attribute and source counts
att_num int := 1;
sou_num int := 1;
--vars to store local queries, one for each local db
local_query varchar2(500);
--vars to hold non-sql tokens
att1 varchar2(500);
att2 varchar2(500);
sou1 varchar2(500);
sou2 varchar2(500);
--Condition variables for where clause
cond1 varchar2(500);
cond2 varchar2(500);

--'SELECT EVENT_NAME EVENT_DESCRIPTION FROM EVENT_TABLE WHERE EVENT_ID <= 10'
BEGIN
--parse the user's query into words separated by spaces into the t_array
global_query := parser.parse('SELECT COUNT(*) FROM EVENT_TABLE WHERE EVENT_ID <= 10');

--for loop to look for locations of SELECT, FROM, and WHERE in the global_query array
for x in 1..global_query.count loop
  if (global_query(x) = 'SELECT') then
    --location of SELECT (should be 1)
    SELECT_num := x;
  elsif (global_query(x) = 'FROM') then
    --location of FROM
    FROM_num := x;
  elsif (global_query(x) = 'WHERE') then
    --location of WHERE
    WHERE_num := x;
  end if;
end loop;

--loop through the tokens in user's query
for j in 1..global_query.count loop
  --loop through the 40 rows in the sql keywords table
  for i in 1..40 loop
    --select into sql_word the tokens of the user's query
    SELECT keyword INTO sql_word FROM SQL_WORDS WHERE sql_word_id = i;
    --if it is a sql keyword from the sql keywords table
    if (global_query(j) = sql_word) then
    DBMS_OUTPUT.PUT_LINE('sql_word = '||sql_word);
      --concatenate it to the local query
      local_query := local_query || sql_word || ' ';
      --break out of the loop and move on to next token
      exit;
    end if;
  end loop;
--if the token is not a sql keyword, check that the token has not already been concatenated to the local_query
if ((instr(local_query,global_query(j))) = 0) then
--if token is preceded by SELECT but before FROM
  if (j > SELECT_num AND j < FROM_num) then
    --then check if token is att1 or att2
    if (att1 IS NULL) then
      att1 := global_query(j);
      --then concatenate att1 to local_query
      local_query := local_query || att1 || ' ';
    elsif (att2 IS NULL) then
      att2 := global_query(j);
      --then concatenate att2 to local_query
      local_query := local_query || att2 || ' ';
    end if;
  --once contenated reloop
  continue;
  --else if token is preceded by FROM but before WHERE
  elsif (j > FROM_num AND (j < WHERE_num OR WHERE_num IS NULL)) then
    --then check if token is sou1 or sou2
    if (sou1 IS NULL) then
      sou1 := global_query(j);
      --then concatenate sou1 to local_query
      local_query := local_query || sou1 || ' ';
    elsif (sou2 IS NULL) then
      sou2 := global_query(j);
      --then concatenate sou2 to local_query
      local_query := local_query || sou2 || ' ';
    end if;
  --once contenated reloop
  continue;
  --else if token is preceded by WHERE
  elsif (j > WHERE_num AND global_query(j) <> '=') then
    --then check if token is cond1 or cond2
    if (cond1 IS NULL) then
      cond1 := global_query(j);
      --then concatenate cond1 to local_query
      local_query := local_query || cond1 || ' ';
    elsif (cond2 IS NULL) then
      cond2 := global_query(j);
      --then concatenate cond2 to local_query
      local_query := local_query || cond2 || ' ';
    end if;
  --once contenated reloop
  continue;
  end if;
end if;
end loop;
--Print the local_query and variables to check the parser's results
DBMS_OUTPUT.PUT_LINE('local_query = '||local_query);
DBMS_OUTPUT.PUT_LINE('att1 = '||att1);
DBMS_OUTPUT.PUT_LINE('att2 = '||att2);
DBMS_OUTPUT.PUT_LINE('sou1 = '||sou1);
DBMS_OUTPUT.PUT_LINE('sou2 = '||sou2);
DBMS_OUTPUT.PUT_LINE('cond1 = '||cond1);
DBMS_OUTPUT.PUT_LINE('cond2 = '||cond2);
end;