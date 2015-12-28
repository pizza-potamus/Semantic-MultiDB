/* Parser Package */
CREATE OR REPLACE PACKAGE PARSER IS 

TYPE t_array IS TABLE OF VARCHAR2(50) 
   INDEX BY BINARY_INTEGER; 

FUNCTION PARSE (p_token VARCHAR2, p_space VARCHAR2) RETURN t_array; 

END; 

create or replace PACKAGE BODY PARSER IS 

   FUNCTION PARSE (p_token VARCHAR2) RETURN t_array  
   IS 
    
      i        number :=0;
      position number :=0;
      pull_str varchar2(50) := p_token; 
       
   tokens t_array; 
    
   BEGIN 
    
      -- find the first token in the query
      position := instr(pull_str,' ',1,1); 
    
      -- while there are tokens left, loop  
      WHILE ( position != 0) LOOP 
          
         -- increment counter  
         i := i + 1; 
          
         -- add token to t_array tokens
         tokens(i) := substr(pull_str,1,position); 
          
         -- remove the found token from the query string 
         pull_str := substr(pull_str,position+1,length(pull_str)); 
          
         -- find the next token in query string / reloop
         position := instr(pull_str,' ',1,1); 
          
         -- when query string is empty, add last token to array  
         IF position = 0 THEN 
         
            tokens(i+1) := pull_str; 
          
         END IF; 
       
      END LOOP; 
    
      -- return array  
      RETURN tokens; 
       
   END PARSE; 

END;

/* SQL Words Table */
CREATE TABLE SQL_WORDS (sql_word_id int, keyword varchar2(50));
INSERT INTO SQL_WORDS VALUES (1, 'SELECT');
INSERT INTO SQL_WORDS VALUES (2, 'FROM');
INSERT INTO SQL_WORDS VALUES (3, 'WHERE');
INSERT INTO SQL_WORDS VALUES (4, 'COUNT(*)');
INSERT INTO SQL_WORDS VALUES (5, '*');
INSERT INTO SQL_WORDS VALUES (6, 'UNION');
INSERT INTO SQL_WORDS VALUES (7, 'JOIN');
INSERT INTO SQL_WORDS VALUES (8, 'UPDATE');
INSERT INTO SQL_WORDS VALUES (9, 'INSERT');
INSERT INTO SQL_WORDS VALUES (10, 'INTO');
INSERT INTO SQL_WORDS VALUES (11, 'VALUES');
INSERT INTO SQL_WORDS VALUES (12, 'DELETE');
INSERT INTO SQL_WORDS VALUES (13, 'GROUP');
INSERT INTO SQL_WORDS VALUES (14, 'BY');
INSERT INTO SQL_WORDS VALUES (15, 'HAVING');
INSERT INTO SQL_WORDS VALUES (16, '=');
INSERT INTO SQL_WORDS VALUES (17, '<>');
INSERT INTO SQL_WORDS VALUES (18, '>');
INSERT INTO SQL_WORDS VALUES (19, '<');
INSERT INTO SQL_WORDS VALUES (20, '>=');
INSERT INTO SQL_WORDS VALUES (21, '<=');
INSERT INTO SQL_WORDS VALUES (22, 'AND');
INSERT INTO SQL_WORDS VALUES (23, 'OR');
INSERT INTO SQL_WORDS VALUES (24, 'NOT');
INSERT INTO SQL_WORDS VALUES (25, 'COALESCE');
INSERT INTO SQL_WORDS VALUES (26, 'MERGE');
INSERT INTO SQL_WORDS VALUES (27, 'NULL');
INSERT INTO SQL_WORDS VALUES (28, 'ORDER');
INSERT INTO SQL_WORDS VALUES (29, 'TRUNCATE');
INSERT INTO SQL_WORDS VALUES (30, 'UNION');
INSERT INTO SQL_WORDS VALUES (31, 'IN');
INSERT INTO SQL_WORDS VALUES (32, 'EXISTS');
INSERT INTO SQL_WORDS VALUES (33, 'LIKE');
INSERT INTO SQL_WORDS VALUES (34, 'BETWEEN');
INSERT INTO SQL_WORDS VALUES (35, 'ANY');
INSERT INTO SQL_WORDS VALUES (36, 'IS');
INSERT INTO SQL_WORDS VALUES (37, 'UNIQUE');
INSERT INTO SQL_WORDS VALUES (38, 'DISTINCT');
INSERT INTO SQL_WORDS VALUES (39, 'ANY');
INSERT INTO SQL_WORDS VALUES (40, 'ALL');

/*Parse and Display Procedure */
set serveroutput on;
CREATE OR REPLACE PROCEDURE Parse_and_Display (querystring IN VARCHAR)
IS
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
        local2_query varchar2(500);
        dynamic1_query varchar2(500);
        dynamic2_query varchar2(500);
        dynamic3_query varchar2(500);
        dynamic4_query varchar2(500);
        --Ken's variables
        dynamicatt1 varchar2(500);
        dynamicsou1 varchar2(500);
        dynamicjoi1 varchar2(500);
        dynamictyp1 varchar2(500);
        dynamicatt2 varchar2(500);
        dynamicsou2 varchar2(500);
        dynamicjoi2 varchar2(500);
        dynamictyp2 varchar2(500);
        dynamicatt3 varchar2(500);
        dynamicsou3 varchar2(500);
        dynamicjoi3 varchar2(500);
        dynamictyp3 varchar2(500);
        dynamicatt4 varchar2(500);
        dynamicsou4 varchar2(500);
        dynamicjoi4 varchar2(500);
        dynamictyp4 varchar2(500);
        dynamicatt5 varchar2(500);
        dynamicsou5 varchar2(500);
        dynamicjoi5 varchar2(500);
        dynamictyp5 varchar2(500);
                manycolumns varchar2(500);

        att1 varchar2(500);
        att2 varchar2(500);
        sou1 varchar2(500);
        sou2 varchar2(500);
        meta_table varchar2(200);
        counter int;
        cnt int;
        columnresult varchar2(999);
        declareresult varchar2(999);
        putresult varchar2(999);
        headerresult varchar2(999);
        fetchcolumns varchar2(999);
        --Condition variables for where clause
        cond1 varchar2(500);
        cond2 varchar2(500);
        finalcond varchar2(500);
        countholder int;
       
BEGIN
--parse the user's query into words separated by spaces into the t_array
global_query := parser.parse(querystring);

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
DBMS_OUTPUT.PUT_LINE('Global Query = '||local_query);
DBMS_OUTPUT.PUT_LINE('att1 = '||att1);
DBMS_OUTPUT.PUT_LINE('att2 = '||att2);
DBMS_OUTPUT.PUT_LINE('sou1 = '||sou1);
DBMS_OUTPUT.PUT_LINE('sou2 = '||sou2);
DBMS_OUTPUT.PUT_LINE('cond1 = '||cond1);
DBMS_OUTPUT.PUT_LINE('cond2 = '||cond2);
DBMS_OUTPUT.PUT_LINE('');

counter := 1;
cnt:=1;

for i in 1..3 loop
    --Pull canonical value of attribute
    IF att1 IS NOT NULL THEN
      IF att1='COUNT' THEN
        countholder:=1;
        IF sou1 IS NOT NULL THEN
        dynamic3_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
        DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = LOWER('''||sou1||''')';
        --DBMS_OUTPUT.PUT_LINE(dynamic3_query);
        execute immediate dynamic3_query into dynamicatt3, dynamicsou3, dynamictyp3, dynamicjoi3;
        END IF;
       
        IF cond1 IS NOT NULL THEN
        local2_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
        DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = LOWER('''||cond1||''')';
        --      DBMS_OUTPUT.PUT_LINE(local2_query);
        execute immediate local2_query into dynamicatt5, dynamicsou5, dynamictyp5, dynamicjoi5;
        finalcond:= ' WHERE Lower('||dynamicatt5||') LIKE LOWER(''%'||cond2||'%'')';
          END IF;        
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||dynamicsou3||finalcond INTO countholder;
        DBMS_OUTPUT.PUT_LINE('DB'||counter||' COUNT:');
        DBMS_OUTPUT.PUT_LINE(countholder);
        DBMS_OUTPUT.PUT_LINE('');
        counter:=counter+1;
        continue;
      ELSE
        dynamic1_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
        DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = '''||att1||'''';
        --    DBMS_OUTPUT.PUT_LINE(dynamic1_query);
        execute immediate dynamic1_query into dynamicatt1, dynamicsou1, dynamictyp1, dynamicjoi1;
      END IF;  
    END IF;
 
    IF att2 IS NOT NULL THEN
    dynamic2_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
    DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = '''||att2||'''';
    --    DBMS_OUTPUT.PUT_LINE(dynamic2_query);
    execute immediate dynamic2_query into dynamicatt2, dynamicsou2, dynamictyp2, dynamicjoi2;
    END IF;
  
   
    IF sou1 IS NOT NULL THEN
    dynamic3_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
    DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = LOWER('''||sou1||''')';
    --DBMS_OUTPUT.PUT_LINE(dynamic3_query);
    execute immediate dynamic3_query into dynamicatt3, dynamicsou3, dynamictyp3, dynamicjoi3;
    END IF;
   
    IF sou2 IS NOT NULL THEN
    dynamic4_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
    DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = LOWER('''||sou2||''')';
    --    DBMS_OUTPUT.PUT_LINE(dynamic4_query);
    execute immediate dynamic4_query into dynamicatt4, dynamicsou4, dynamictyp4, dynamicjoi4;
    END IF;

    IF cond1 IS NOT NULL THEN
       local2_query := 'SELECT COALESCE(DB'||counter||'_attribute, DB'||counter||'_function) AS att, DB'||counter||'_source as sou,
    DB'||counter||'_datatype as typ, DB'||counter||'_join as joi FROM metatable WHERE canonical = LOWER('''||cond1||''')';
      --      DBMS_OUTPUT.PUT_LINE(local2_query);
       execute immediate local2_query into dynamicatt5, dynamicsou5, dynamictyp5, dynamicjoi5;
      finalcond:= ' WHERE Lower('||dynamicatt5||') LIKE LOWER(''%'||cond2||'%'')';
          END IF;

    SELECT LISTAGG(column_name, ', ')  WITHIN GROUP (ORDER BY column_name) into columnresult FROM user_tab_cols WHERE table_name = UPPER(dynamicsou3);   
    SELECT LISTAGG(column_name, ' ||'' | ''|| ')  WITHIN GROUP (ORDER BY column_name) into putresult FROM user_tab_cols WHERE table_name = UPPER(dynamicsou3);
    SELECT LISTAGG(column_name, ' VARCHAR2(500);') WITHIN GROUP (ORDER BY column_name) into declareresult FROM user_tab_cols WHERE table_name = UPPER(dynamicsou3);
    SELECT LISTAGG(column_name, '  //  ') WITHIN GROUP (ORDER BY column_name) into headerresult FROM user_tab_cols WHERE table_name = UPPER(dynamicsou3);
           
        declareresult :=declareresult||' VARCHAR2(500);';
  
IF dynamicsou3 IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('DB'||counter||': NOT AVAILABLE at Local DB!');
    counter := counter+1;
    CONTINUE;
ELSIF dynamictyp3='table' THEN
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('DB'||counter||': SELECT * FROM '||dynamicsou3||' '||dynamicjoi3||finalcond||';');
    DBMS_OUTPUT.PUT_LINE('');
    EXECUTE IMMEDIATE
    'DECLARE
      q VARCHAR2(200);
      cre VARCHAR2(200);
      c int;
      CURSOR c1 IS SELECT '||columnresult||' FROM '||dynamicsou3||' '||dynamicjoi3||finalcond||';'
      ||declareresult||'
      BEGIN
      OPEN c1;
      DBMS_OUTPUT.PUT_LINE('''||headerresult||''');
      LOOP
      FETCH c1 into '||columnresult||';
      EXIT WHEN c1%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('||putresult||');
      END LOOP;
      CLOSE c1;
      DBMS_OUTPUT.PUT_LINE('''');
     END;';
    
  /* Code to display one or more columns */
  ELSE
  IF dynamicatt4 IS NOT NULL
  THEN manycolumns:= dynamicatt3||', '||dynamicatt4;
  fetchcolumns:='column2, column3';
  ELSE manycolumns:=dynamicatt3;
  fetchcolumns:='column2';
  END IF;
 
  IF dynamicatt5='COUNT'
  THEN finalcond:=' WHERE '||dynamicatt3||
  ' IN(Select '||dynamicatt3||' FROM '||dynamicsou3||' GROUP BY '||dynamicatt3||' HAVING COUNT('||dynamicatt3||') >= '||cond2||')';
 
  END IF;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
      
    DBMS_OUTPUT.PUT_LINE('DB'||counter||': SELECT '||manycolumns||
       ' FROM '||dynamicsou3||finalcond||';');
        DBMS_OUTPUT.PUT_LINE('');
   
  
    EXECUTE IMMEDIATE
    'DECLARE
      q VARCHAR2(200);
      cre VARCHAR2(200);
      c int;
      CURSOR c1 IS SELECT '||manycolumns||' FROM '||dynamicsou3||finalcond||';
      column2 VARCHAR2(999);
      column3 VARCHAR2(999);

      BEGIN
      OPEN c1;
      DBMS_OUTPUT.PUT_LINE('''||dynamicatt3||'''||''  //  ''||'''||dynamicatt4||''');
      LOOP
      FETCH c1 into '||fetchcolumns||';
      EXIT WHEN c1%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(column2||'' | ''||column3);
      END LOOP;
      CLOSE c1;
      DBMS_OUTPUT.PUT_LINE('''');
     END;';
    END IF;
DBMS_OUTPUT.PUT_LINE ('');


  counter:=counter+1;
end loop;
  
end;