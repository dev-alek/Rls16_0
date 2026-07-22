block-level on error undo, throw.
 define input-output parameter pFile as character no-undo.
function objExists return character
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
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
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
 define variable mFileR    as character no-undo.
 define variable mFileDBG  as character no-undo.
 define variable mFileRs as character no-undo.
 define variable mExt   as character no-undo.
 define variable mNum as integer no-undo.
 mNum = num-entries(pfile,".").
 mExt = entry(mnum,pfile,".").
 if    mExt eq "p"
    or mExt eq "w"
    or mExt eq "cls"
 then do:
    Pfile = SearchPFile(pfile).
    assign
       mFileR = Pfile
       entry(mnum,mFileR,".") = "r"
       mFileDBG= Pfile
       entry(mnum,mFileDBG,".") = "dbg"
       mFileR = replace (mFileR,"\","/")
       mNum = num-entries(mFileR,"/")
       mFileR = entry(mnum,mFileR,"/")
       mFileDBG = replace (mFileDBG,"\","/")
       mNum = num-entries(mFileDBG,"/")
       mFileDBG = "./" + entry(mnum,mFileDBG,"/")
    .
    mFileRs = search(mFileR).
    os-delete value( mFileRs ).
    compile
        value( Pfile )
        save into  "."
         DEBUG-LIST VALUE ( mFileDBG )
        min-size
      no-error .
     if error-status :error
     or compiler :error
     or compiler :warning
     then do:
       define variable v-counter as integer  no-undo.
       define variable v-compiler-error as character no-undo.
       define variable vRow             as integer init -10 no-undo.
       do v-counter = 1 to compiler :num-messages
       :
         if vRow ne compiler :get-error-row( v-counter )
         then do:
            v-compiler-error = substitute( "&2 &1 Cтрока &3":U
                                          , "~n":U
                                          , v-compiler-error
                                          , compiler :get-error-row( v-counter )
                                          )
            no-error.
            vRow = compiler :get-error-row( v-counter ).
         end.
         v-compiler-error = substitute( "&1 &2 &3":U
                                          , v-compiler-error
                                          , compiler :get-message( v-counter )
                                          , vRow
                                          )
         no-error.
       end.
       do v-counter = 1 to error-status :num-messages
       :
         assign
             v-compiler-error = substitute( "&2 &3 &1":U
                                          ,vRow
                                          , "~n":U
                                          , v-compiler-error
                                          , error-status :get-message( v-counter )
                                          )
         no-error.
       end.
       message v-compiler-error
       view-as alert-box.
     end.
 end.
 else if    mExt eq "r"
 then
   mFileR = pfile .
 pfile = SearchPFile(mFileR).
