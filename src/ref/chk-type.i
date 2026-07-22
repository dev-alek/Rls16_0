DEFINE {1} TEMP-TABLE tt-chk-type NO-UNDO 
   field sel  as logical
   field code as integer
   field name as character
index pi code
index si sel code.
