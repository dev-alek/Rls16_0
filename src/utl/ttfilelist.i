define temp-table {1} no-undo
   field fnAME as character  
   field localPach as character  
   field fullpach as character
   field fulllocalpach as character  format "x(25)"
   field fLevel   as int
   field NotNew   as logical
index localPach localPach fname
index fulllocalpach fulllocalpach. 