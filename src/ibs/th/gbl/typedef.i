 define temp-table {1}
    field list  as character 
    field item as character
    field codeint  as integer
    field codeChar  as character
 index  item     list item  
 index  codeint  list codeint
 index  codeChar list codeChar
 .  