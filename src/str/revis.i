define stream str-file.
{ cmp/str-glbl.i}
procedure readfiletxt:
   define input  parameter i_File-Name   as character no-undo.
   define output parameter Otext as longchar no-undo.
   
   define variable v_string-tmp as character no-undo.
   if searchfile(i_File-Name) eq ?
   then
      return.
   input  stream str-file from  value (i_File-Name)   .
   repeat :
      import stream str-file unformatted v_string-tmp.
      Otext = Otext + v_string-tmp + {&new-line}.
   end.
   input  stream str-file close.
end procedure.

procedure readrevisetxt:
   define input  parameter i_Str         as Longchar no-undo.
   define input  parameter i_StartString as character no-undo.
   define input  parameter i_comment     as character no-undo.
   
   define variable v_string-tmp          as character no-undo.
   define variable v-bh                  as handle  no-undo .
   define variable v-fh                  as handle  no-undo .
   define variable vi                    as integer no-undo.
   
   for each tt-place:
      tt-place.is-error       = yes.
   end.
   
   rpt:
   do vi = 1 to num-entries(i_Str,{&new-line}) :
      v_string-tmp = entry(vi, i_Str,{&new-line}).
         /* Отсекем комментарий */
      if index( v_string-tmp, i_comment ) > 0 
      then do:
         v_string-tmp = substring( v_string-tmp, 1, index( v_string-tmp, i_comment ) - 1 ).
      end.
      if v_string-tmp = '':U 
      then
         next rpt .
      if index( v_string-tmp, i_StartString ) > 0 
      then do:
            /* перешли к новому баку, следует в старом баке проставить */
         find first tt-place where tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) ) no-error .
         if not available tt-place
         then do :
           create tt-place .
           assign tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) ) 
                  tt-place.locint   = int(tt-place.loc1) 
           no-error .
           
         end.
         assign
             tt-place.t1             = ?
             tt-place.t2             = ?
             tt-place.t3             = ?
             tt-place.level-total    = ?   
             tt-place.level-water    = ?   
             tt-place.total-vol      = ? 
             tt-place.avrg-temp      = ?  
             tt-place.density        = ? 
             tt-place.mass           = ?
             tt-place.vapor-density  = ?
             tt-place.vapor-pressure = ?
             tt-place.volume_water   = ?
             tt-place.is-error       = no
             tt-place.error-message  = ?
         .
      end.
      else do:
            /* если резервуар корректный, то читаем по нему данные */
         if not available tt-place 
         then
            next rpt .
         find first tt-param where tt-param.strfrfile = trim( entry( 1, v_string-tmp, '=' ) ) no-error.
         if available tt-param 
         then do:
            v-bh = buffer tt-place:handle.
            assign
               v-fh                = v-bh:buffer-field( tt-param.strasi )
               v-fh:buffer-value() = decimal( trim( entry( 2, v_string-tmp, '=' ) ) )
            no-error.
            if (tt-param.flddb = "temperature"
             or tt-param.flddb = "water-qnty")
            and trim( entry( 2, v_string-tmp, '=' ) ) = "-"
            then do :
              assign
                 v-fh:buffer-value() = ?
              no-error.
            end .
         end.
         else do:
            run gbl/fileapnd.p
                  ( 'revis.err'
                  ,
               if trim( entry( 1, v_string-tmp, '=' ) ) = "ERROR"
               then 
                  substitute("&1 &2  Ошибка: &3 &4", string(today),string(time, "HH:MM:SS"),  trim( entry( 2, v_string-tmp, '=' ) ), {&carriage-return} + {&new-line})
                  
               
               else 
                  substitute("&1 &2  Неизвестный параметр: &3 &4", string(today),string(time, "HH:MM:SS"), trim( entry( 1, v_string-tmp, '=' ) ), {&carriage-return} + {&new-line})
               
               ,input 10 /* время ожинания освобождения файла */
             ) no-error .
         end.
      end. /* читаем данные по резервуару */
   end. /* rpt */
   for each tt-place:
      tt-place.vapor-pressure = tt-place.vapor-pressure / 1000. 
   end.
end procedure.

procedure get-from-struna :
  define input  parameter i-log-file-name as character no-undo.
  define input  parameter i-obj-code as integer no-undo.
  define variable v-comstring as character no-undo .
  define variable v_File-Name as character no-undo .
  define variable v_command as character no-undo .
  
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
  { str/crtt-rvs.i
        tt-param
        v-comstring
        v-comment
        v-StartString
        no-error
    }
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
  
   v_File-Name = searchfile('revis.txt').
   if v_File-Name ne ?
   then do:
      block-del-file: 
      do vi = 1 to 5:
         os-delete value( v_File-Name ) .
         v_File-Name = searchfile('revis.txt').
         if v_File-Name eq ?
         then
            leave block-del-file.
     end.
   end.
   if v_File-Name ne ?
   then
      return error 'Файл revis.txt заблокирован удалите файл и попробуйте еще раз. ' + v_File-Name .
   if    v-comstring = '':U
      or v-comstring = ?
   then do:
      return error 'Не задан парам. comstr в секции revision ini файла.' .
   end.
   v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
   if searchfile(v_File-Name) ne ?
   then do :
      v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
      if searchfile(v_File-Name) ne ?
      then do :
        os-delete value(searchfile(v_File-Name)) no-error .
      end.
      if searchfile(v_File-Name) ne ?
      then
        return error "Удалите все файлы wrevis*.tmp".
   end.
   
   assign
      v_command = substitute( "&1 &2 &3 &4", v-comstring, string(0), v_File-Name, i-obj-code)
   .
   os-command silent value( v_command ) .
   if searchfile(v_File-Name) ne ?
   then
      run readfiletxt (v_File-Name, output Vrevis).
   run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос &3&4", string(today),string(time, "HH:MM:SS"), v_command, {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
   if searchfile( v_File-Name ) = ? then do:
      run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("Файл с прибора не получен. &1",  {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
      return error 'Файл с прибора не получен.' .
  end.
  else do: 
      v_File-Name  = searchfile( v_File-Name ) . 
  end.
  
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  os-append value(v_File-Name) value(i-log-file-name).
  os-rename value( v_File-Name ) 'revis.txt'.
  os-delete value( v_File-Name ) .
  run gbl/fileapnd.p
          ( i-log-file-name
          , {&carriage-return} + {&new-line}
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
  run readrevisetxt (Vrevis,v-StartString,v-comment).
end procedure .

procedure get-from-ifsf :
   define input  parameter i-log-file-name as character no-undo.
   define input  parameter i-asi-ip        as character no-undo.
   define input  parameter i-asi-port      as character no-undo.

  define variable v_command     as   character     no-undo.
  define variable v-log     as logical no-undo .
  define variable v-bytes   as integer no-undo .
  define variable v-out-data as character no-undo .
  define variable v-line-str as character no-undo .
  define variable ii        as integer no-undo .
  define variable str       as character no-undo .
  define variable str1      as character no-undo .
  define variable str2      as character no-undo .
  
  define variable hSocket   as handle no-undo .
  define variable mDataIn   as memptr no-undo .
  define variable mDataout  as memptr no-undo .
  define variable cmd       as character no-undo .
  define variable connStr   as character no-undo .
  
  define variable v-attr-type   as character no-undo.
  define variable v-comstring   as character no-undo. 
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
  { str/crtt-rvs.i
        tt-param
        v-comstring
        v-comment
        v-StartString
        no-error
    }
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
  
  
  cmd = 'KOI8-R 1 0 1' + {&new-line} .
  set-size(mDataIn) = 0 .
  set-size(mDataIn) = length(cmd , "RAW":U) + 1 .
  put-string(mDataIn,1) = cmd .
  
  find first sys-ctrl no-lock.
  if i-asi-ip eq ? or i-asi-ip eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiIp",output i-asi-ip,output v-attr-type).
  if i-asi-port eq ? or i-asi-port eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiPort",output i-asi-port,output v-attr-type).  
  create socket hSocket .
  connStr = '-H ' + i-asi-ip + ' -S ' + i-asi-port .
  hSocket:connect(connStr) no-error.
  
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос  connStr='-H &3  -S &4 '  cmd='KOI8-R 1 0 1'&5", string(today),string(time, "HH:MM:SS"),i-asi-ip,i-asi-port, {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
  if hSocket:connected() = false
  then do :
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу подключиться к IFSF серверу." , {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
    return error "Не могу подключиться к IFSF серверу." .
  end.
  
  hSocket:set-socket-option('TCP-NODELAY', 'true').
  hSocket:set-socket-option('SO-KEEPALIVE', 'true').
  hSocket:set-socket-option('SO-REUSEADDR', 'true').
  
  v-log = hSocket:write(mDataIn, 1, get-size(mDataIn)) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу отправить команду на IFSF сервер.", {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
    return error "Не могу отправить команду на IFSF сервер." .
  end.
  
  run sleep (1000) .
  
  set-size(mDataOut) = 0 .
  v-bytes = hSocket:get-bytes-available() .
  set-size(mDataOut) = v-bytes + 1 .
  
  v-log = hSocket:read(mDataOut, 1, v-bytes, 2) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу прочитать ответ от IFSF сервера.", {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
    return error "Не могу прочитать ответ от IFSF сервера." .
  end.
  
  v-out-data = get-string(mDataOut,1) .
  if v-out-data = ""
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу получить данные от IFSF сервера.", {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
    return error "Не могу получить данные от IFSF сервера." .
  end.
  if index(v-out-data, "Bad Request") > 0
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Bad Request", {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  
    return error v-out-data .
  end.
  
  hSocket:disconnect() no-error.
  delete object hSocket.
  set-size(mDataIn) = 0.
  set-size(mDataOut)   = 0.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), {&carriage-return} + {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
   run gbl/fileapnd.p
          ( i-log-file-name
          , v-out-data
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
       
   run gbl/fileapnd.p
          ( i-log-file-name
          , {&carriage-return} + {&new-line}
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
  output to "revis.ifsf" .
  
  do vi = 1 to num-entries(v-out-data, {&new-line}) :
    put unformatted entry(vi, v-out-data, {&new-line}) skip .
  end.
  
  output close.
  run readrevisetxt (v-out-data,v-StartString,v-comment).
  
end procedure .

procedure parse-xml :
  define input parameter iStr as longchar .
  
  define variable hDoc              as handle     no-undo .
  define variable hRoot             as handle     no-undo .
  
  for each tt-place:
      tt-place.is-error       = yes.
  end.
  
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
     
  hDoc:LOAD("longchar",iStr,FALSE).
     
  hDoc:GET-DOCUMENT-ELEMENT(hRoot).
      
  RUN GetChildren(hRoot, 1).
  
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
  
end procedure .

PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText    AS HANDLE NO-UNDO.
define variable client   as character no-undo.
define variable good                as logical   no-undo .
define variable v-asi-error-code    as integer   no-undo initial 0 .
define variable v-asi-error-message as character no-undo .

CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .


REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN 
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    
    hNoderef:GET-CHILD(hText, 1) no-error .    
    
    IF hNoderef:NAME = "ErrNum"
    then do :
      v-asi-error-code = integer(hText:node-value) no-error .
    end .
    
    IF hNoderef:NAME = "ErrMsg"
    then do :
      v-asi-error-message = hText:node-value no-error .
      if     v-asi-error-code > 0
         and v-asi-error-code ne 2
      then do :
        assign
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?   
          tt-place.level-water    = ?   
          tt-place.total-vol      = ? 
          tt-place.avrg-temp      = ?  
          tt-place.density        = ? 
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = true
          tt-place.error-message  = v-asi-error-message
        .
      end .
    end .
        
    IF hNoderef:NAME = "Tank"
    then do :
      find first tt-place where tt-place.loc1 = hText:node-value no-error .
      if not available tt-place
      then do :
        create tt-place .
        assign tt-place.loc1     = hText:node-value 
               tt-place.locint   = int(tt-place.loc1) 
        no-error .
        
      end.
      assign
          v-asi-error-code        = 0
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?   
          tt-place.level-water    = ?   
          tt-place.total-vol      = ? 
          tt-place.avrg-temp      = ?  
          tt-place.density        = ? 
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = no
          tt-place.error-message  = ?
      .
    end.
    
    if    v-asi-error-code = 0
       or v-asi-error-code = 2
    then do :
      IF hNoderef:NAME = "LevelTotal" then assign tt-place.level-total = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "LevelWater" then assign tt-place.level-water = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "Temperature" then assign tt-place.avrg-temp = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Density" then assign tt-place.density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VolumeTotal" then assign tt-place.total-vol = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "MassTotal" then assign tt-place.mass = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporDensity" then assign tt-place.vapor-density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporPressure" then assign tt-place.vapor-pressure = decimal(hText:node-value) / 1000 no-error .
      IF hNoderef:NAME = "Temperature1" then assign tt-place.t1 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature2" then assign tt-place.t2 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature3" then assign tt-place.t3 = decimal(hText:node-value) no-error .
    end .
           
    RUN GetChildren(hNoderef, (level + 1)).
END.

DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.