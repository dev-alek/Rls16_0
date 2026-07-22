&if defined (Shift) eq 0
&then
&scop Shift 0
&endif   
define property {&NameType}ListAll as character init "{&ListType}" no-undo
get.     
define property {&NameType}List    as character  no-undo
    get():
       return if {&NameType}List = ""
              then {&NameType}ListAll
              else {&NameType}List.
    end.
    private set.
    
 method public void {&NameType}refresh():  
 define variable vi as integer  no-undo.
     for each tt-type  where tt-type.list  = "{&NameType}" :
         delete tt-type.
     end.    
     do vi = 1 to num-entries({&NameType}List):
         create tt-type.
         assign
            tt-type.list  = "{&NameType}"
            tt-type.item  = entry(vi,{&NameType}List)
            tt-type.code  = lookup (tt-type.item, {&NameType}ListAll) - {&Shift}
         .
    end.
end.   

method public character {&NameType}Lbl (intSts as integer ):
    return typeLbl("{&NameType}",intSts).
end.

method public integer {&NameType}Int (charSts as character):
    return typeInt("{&NameType}",charSts).
end.
