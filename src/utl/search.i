&if defined(search_def) eq 0
&then
&glob search_def yes
/*{ cmp/str-glbl.i }*/
&if defined(str-glbl_i) = 0 &then
&global-define CommentStartNoClass /~* 
&endif
{ def/funcmet.i objExists character }
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       /* BTS-145 был баг, что сюда приходила строка GET-запроса, а возвращался прогрессовый файл ablunit.pl */
       /* поэтому добавлена проверка, что в full-pathname и file-name идин и тот же файл */
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\") 
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0 
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and 
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\") 
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and 
          index( vtype, entry(vi,vFileType )) > 0 
       then return file-information:full-pathname .
    end.
    return ? .

end.

{ def/funcmet.i SearchFile character }
(input  ifile as character):
   return objExists(ifile,?).
end.

{ def/funcmet.i SearchPFile character }
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r". 
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
     
  end.
&endif