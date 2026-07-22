block-level on error undo, throw.
 define input-output parameter pFile as character no-undo.
 {utl\search.i}
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
    /* удаляем файл, если он есть */
    os-delete value( mFileRs ).
    compile
        value( Pfile )
        save into  "."
         DEBUG-LIST VALUE ( mFileDBG ) 

        min-size
      no-error .
    /* проверяем была ли ошибка при компиляции */
     if error-status :error
     or compiler :error
     or compiler :warning
     then do:
       /*  assign
         v-compiler-error = substitute( "Строка &2&1":U
                                      , {&delim-key}
                                      , compiler :error-row
                                      )
       . */
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
                                       /*   , entry(compiler :get-message-type( v-counter ),"Error,Warning,Preprocessor")  */
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
  
  