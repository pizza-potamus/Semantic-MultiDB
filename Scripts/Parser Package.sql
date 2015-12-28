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