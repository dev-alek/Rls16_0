&if defined (Shiftlist) eq 0
&then
&scop Shiftlist 0
&endif   
define property {&NameType}ListAll as character init "{&ListType}" no-undo
get.

&if defined (ListTypeChar) ne 0
&then
define property {&NameType}Charall as character init "{&ListTypeChar}" no-undo
get.
&endif      
define property {&NameType}List    as character  no-undo
    get():
       return if {&NameType}List = ""
              then {&NameType}ListAll
              else {&NameType}List.
    end.
    private set(iarg as character):
       {&NameType}List = iarg.
       {&NameType}refresh().
    end.
    
 method public void {&NameType}Refresh():  
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "{&NameType}" :
         delete tt-type.
     end.    
     do vi = 1 to num-entries({&NameType}List):
         create tt-type.
         assign
            tt-type.list     = "{&NameType}".
            tt-type.item     = entry(vi,{&NameType}List).
            tt-type.codeInt  = lookup (tt-type.item, {&NameType}ListAll). 
            &if defined (ListTypeChar) ne 0
            &then
            tt-type.codeChar = entry(tt-type.codeInt,{&NameType}Charall).
            &endif
            tt-type.codeInt = tt-type.codeInt - {&Shiftlist}
         .
    end.
end.   

method public character {&NameType}Lbl (intSts as integer ):
    return typeLbl("{&NameType}",intSts).
end.

method public character {&NameType}Lbl (charSts as character ):
    return typeLbl("{&NameType}",charSts).
end.

method public integer {&NameType}Int (charSts as character):
    return typeInt("{&NameType}",charSts).
end.

method public character  {&NameType}char (charSts as character):
    return typechar("{&NameType}",charSts).
end.

method public character  {&NameType}char (icodeint as integer ):
    return typechar("{&NameType}",icodeint).
end.
