block-level on error undo, throw.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-remote   like ub.cash-desk.remote  no-undo .
define input parameter p-mode     as character no-undo .
define output parameter out     as character no-undo .
define output parameter out2    as character no-undo .
define output parameter in_     as character no-undo .
define output parameter spl     as character no-undo .
define output parameter sav     as character no-undo .
define output parameter v-remote as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-inis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-inis.p $":U .
define variable vss-description as character no-undo init "Получение настроек для почты на/с кассы из ini-файла".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define variable v-cd-prfx as character no-undo .
define variable glog as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable yestr as character no-undo .
define variable out3 as character no-undo .
define variable out4 as character no-undo .
define variable temp-out as character no-undo .
define variable v-value as character no-undo .
CASE p-pos-type:
  when 'MAGIA-XML':U then do:
    assign
    v-cd-prfx = 'magia':U
    .
  end.
  when 'IBM-XML':U then do:
    assign
    v-cd-prfx = 'IBM-XML':U
    .
  end.
  when 'Emulator-NKT-IBM':U then do:
    assign
    v-cd-prfx = 'NKT-IBM':U
    .
  end.
  when 'IBM':U then do:
    assign
    v-cd-prfx = 'IBM':U
    .
  end.
  when 'NCR-GM':U then do:
    assign
    v-cd-prfx = 'ncr-gm':U
    .
  end.
  when 'NCR-AS@R':U then do:
    assign
    v-cd-prfx = 'ncr-as-r':U
    .
  end.
  when 'r-keeper':U then do:
    assign
    v-cd-prfx = 'r-keeper':U
    .
  end.
  when 'InfoKiosk':U then do:
    assign
    v-cd-prfx = 'infokiosk':U
    .
  end.
  when 'pricecheck-Servis+':U then do:
    assign
    v-cd-prfx = 'pricecheck-Servis+':U
    .
  end.
  when 'MARIA':U then do:
    assign
    v-cd-prfx = 'maria':U
    .
  end.
  when 'Autotank':U then do:
    assign
    v-cd-prfx = 'autotank':U
    .
  end.
END CASE.
CASE p-pos-type:
  when 'MAGIA-XML':U
  or
  when 'IBM-XML':U
  or
  when  'IBM':U
  or
  when  'Emulator-NKT-IBM':U
  or
  when  'InfoKiosk':U
  or
  when  'pricecheck-Servis+':U
  or
  when 'Autotank':U
  then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу out для отсылки информации на POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, v-cd-prfx)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
      if not
      (p-pos-type = 'InfoKiosk':U
           or
      p-pos-type = 'pricecheck-Servis+':U
      )
      then do:
        run verify-ini-entry in this-procedure (
                                                INPUT  'in'
                                                ,INPUT  'kassa-' + v-cd-prfx
                                                ,INPUT substitute("отсутствует путь к подкаталогу in для приема данных с POS &1", p-pos-type)
                                                ,INPUT yes
                                                ,output in_) no-error .
        if error-status:error or in_ = ? then return error return-value .
        RUN verify-file in this-procedure
                                          ( in_
                                          , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, v-cd-prfx)
                                          ,yes
                                          ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
      end.
      if p-pos-type <> 'InfoKiosk':U and
          p-pos-type <> 'pricecheck-Servis+':U
          then do:
        RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                              ,input substitute("kassa-&1":U, v-cd-prfx)
                              ,input substitute("отсутствует путь к подкаталогу &1 &2 в каталоге &3 &4 для приема данных с POS &6 для магазина с кодом &5"
                                              , "in"
                                              , chr(10)
                                              , in_
                                              , chr(10)
                                              , p-obj-code
                                              , v-cd-prfx)
                              ,input yes
                              ,output spl) no-error.
      end.
      if p-pos-type <> 'InfoKiosk':U and
         p-pos-type <> 'pricecheck-Servis+':U
         then do:
        if spl = ? or error-status:error then return error return-value .
        RUN verify-file(input in_ + spl
                        ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр spl&4, секция [kassa-&5] ini-файла"
                                          , spl
                                          , in_
                                          , chr(10)
                                          , p-obj-code
                                          , v-cd-prfx)
                        ,input yes
                        ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
        RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                              ,input substitute("kassa-&1":U, v-cd-prfx)
                              ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5", chr(10), in_, chr(10), p-obj-code, v-cd-prfx)
                              ,input yes
                              ,output sav) no-error.
        if error-status:error or sav = ? then do:
          if p-pos-type = 'MAGIA-XML':U then do:
            return error return-value .
          end.
          else do:
            sav = spl.
          end.
        end.
      end.
      if p-pos-type = 'MAGIA-XML':U then do:
        RUN verify-file(input (in_ + sav)
                        ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр sav&4, секция [kassa-&5] ini-файла",
                                  sav, in_, chr(10), p-obj-code, v-cd-prfx)
                        ,input yes
                        ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
      end.
      if p-mode = "send":U then do:
        run str/fileqnty.p ( out, output BadFlag ) .
        if not g#news and not g#auto and BadFlag then do:
          return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                  ,out).
        end.
      end.
      if p-pos-type <> 'MAGIA-XML':U
      and p-pos-type <> 'InfoKiosk':U
      and p-pos-type <> 'pricecheck-Servis+':U
      then do:
        run verify-ini-entry in this-procedure (
                                                INPUT  'remote'
                                                ,INPUT  'kassa-' + v-cd-prfx
                                                ,INPUT substitute("отсутствует путь к подкаталогу remote для отсылки информации на POS &1", p-pos-type)
                                                ,INPUT yes
                                                ,output v-remote) no-error .
        if error-status:error or v-remote = ? then v-remote = out.
        else do:
          RUN verify-file in this-procedure
                                            ( v-remote
                                            , substitute("Не найден каталог &1 параметр remote, секция [kassa-&2] ini-файла", v-remote , v-cd-prfx)
                                            ,yes
                                            ,output glog) no-error.
          if error-status:error or not glog then return error return-value .
          if p-mode = "send":u then do:
            run str/fileqntd.p ( v-remote, "out,tmp":U, output fq, output BadFlag ) .
            if not g#news and not g#auto and BadFlag then do:
              return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                      ,v-remote).
            end.
          end.
        end.
      end.
  end.
  when 'OMRON':U then do:
    RUN verify-ini-entry("in":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу in" + chr(10) + "для приема чеков с POS OMRON",
                          yes,
                          output in_) no-error.
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file(in_,
                    "Не найден каталог " + in_ + chr(10) +
                    "параметр in, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry("spl":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу spl" + chr(10) + "для приема чеков с POS OMRON",
                          yes,
                          output spl) no-error.
    if error-status:error or spl = ? then return error return-value .
    RUN verify-file(in_ + spl,
                    "Не найден подкаталог t-i" + spl + " в директории " + in_ + chr(10) +
                    "параметр spl, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry("out":U,
                          "kassa-omron":U,
                          "отсутствует путь к подкаталогу out" + chr(10) + "для передачи информации на POS OMRON",
                          yes,
                          output out) no-error.
    if error-status:error or out = ? then return error return-value .
    RUN verify-file(out,
                    "Не найден каталог " + out + chr(10) +
                    "параметр out, секция [kassa-omron] ini-файла",
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
  end.
  when 'NCR-GM':U
  or when 'NCR-AS@R':U
  then  do:
    assign
    out2 = '':U
    out3 = '':U
    out4 = '':U
    .
    RUN verify-ini-entry("out":U,
                          substitute("kassa-&1":U,  v-cd-prfx),
                          "отсутствует путь к подкаталогу out" + chr(10) + "для отсылки информации на POS NCR",
                          yes,
                          output out) no-error.
    if error-status:error or out = ? then return error return-value .
    RUN verify-file(out,
                    substitute("Не найден каталог &1&2 параметр out, секция [kassa-&3] ini-файла"
                               , out
                               ,chr(10)
                               , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    if p-pos-type = 'NCR-AS@R':U then do:
      RUN verify-ini-entry("out2":U,
                            substitute("kassa-&1":U,  v-cd-prfx),
                            "отсутствует путь к подкаталогу out2" + chr(10) + "для отсылки информации на POS NCR",
                            yes,
                            output out2) no-error.
      if error-status:error or out2 = ? then return error return-value .
      RUN verify-file(out2,
                      substitute("Не найден каталог &1&2 параметр out2, секция [kassa-&3] ini-файла"
                                , out2
                                ,chr(10)
                                , v-cd-prfx),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
      RUN verify-ini-entry("out3":U,
                            substitute("kassa-&1":U,  v-cd-prfx),
                            "отсутствует путь к подкаталогу out3" + chr(10) + "для отсылки информации на POS NCR",
                            yes,
                            output out3) no-error.
      if error-status:error or out3 = ? then return error return-value .
      RUN verify-file(out3,
                      substitute("Не найден каталог &1&2 параметр out3, секция [kassa-&3] ini-файла"
                                , out3
                                ,chr(10)
                                , v-cd-prfx),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
      assign
      out2 = out2 + chr(4) + out3
      .
    end.
    RUN verify-ini-entry("out4":U,
                          substitute("kassa-&1":U,  v-cd-prfx),
                          "отсутствует путь к подкаталогу out4 (директория p_regpar.dat)" + chr(10) + "для отсылки информации на POS NCR",
                          yes,
                          output out4) no-error.
    if error-status:error or out4 = ? then return error return-value .
    RUN verify-file(out4,
                    substitute("Не найден каталог &1&2 параметр out4, секция [kassa-&3] ini-файла"
                              , out4
                              ,chr(10)
                              , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    assign
    out2 = out2 + chr(4) + out3 + chr(4) + out4
    .
    RUN verify-ini-entry("in":U,
                          substitute("kassa-&1", v-cd-prfx),
                          "отсутствует путь к подкаталогу in" + chr(10) + "для приема чеков с сервера NCR",
                          yes,
                          output in_) no-error.
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file(in_,
                    substitute("Не найден каталог &1&2параметр in, секция [kassa-&3] ini-файла"
                              , in_
                              , chr(10)
                              , v-cd-prfx),
                    yes,
                    output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry("spl":U + string( p-obj-code ),
                          substitute("kassa-&1":U,  v-cd-prfx),
                          substitute("отсутствует путь к подкаталогу spl&1в каталоге &2&3для приема чеков магазина с кодом &4 с сервера NCR"
                                     , chr(10)
                                     , in_
                                     , chr(10)
                                     , p-obj-code
                                     ) ,
                          yes,
                          output spl) no-error.
    if spl = ? then spl = "":U.
    else do:
      RUN verify-file(in_ + spl,
                      substitute(
                      "Не найден подкаталог &1 в директории &2&3параметр spl&4 секция [kassa-&5] ini-файла"
                                 , spl
                                 , in_
                                 ,  chr(10)
                                 , p-obj-code
                                 , v-cd-prfx
                                 ),
                      yes,
                      output glog) no-error.
      if error-status:error or not glog then return error return-value .
    end.
    RUN verify-ini-entry("sav":U + string( p-obj-code ),
                          substitute("kassa-&1":U, v-cd-prfx),
                          "",
                          yes,
                          output sav) no-error.
    if error-status:error or sav = ? then sav = spl.
    if sav = ? or sav = "":U then sav = "sav".
    yestr = right-trim((in_ + spl), chr(92)) + "\yestr\":U.
    RUN verify-file(yestr,
                    "Не найден каталог " + yestr + chr(10) +
                    "используемый для получения архива чеков предыдущего дня",
                    yes,
                    output glog) no-error.
    if error-status:error then yestr = ?.
    assign v-remote = yestr.
  end.
  when 'r-keeper':U then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу out для отсылки информации на POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, v-cd-prfx)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    run verify-ini-entry in this-procedure (
                                            INPUT  'in'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогу in для приема данных с POS &1", p-pos-type)
                                            ,INPUT yes
                                            ,output in_) no-error .
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( in_
                                      , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, v-cd-prfx)
                                      ,yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу &1 &2 в каталоге &3 &4 для приема данных с POS &6 для магазина с кодом &5"
                                          , "spl"
                                          , chr(10)
                                          , in_
                                          , chr(10)
                                          , p-obj-code
                                          , v-cd-prfx)
                          ,input yes
                          ,output spl) no-error.
    if error-status:error or spl = ? then return error return-value .
    RUN verify-file(input (in_ + spl)
                    ,input substitute("Не найден подкаталог &1 в директории &2 &3 параметр spl&4, секция [kassa-&5] ini-файла"
                                        , spl
                                        , in_
                                        , chr(10)
                                        , p-obj-code
                                        , v-cd-prfx)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5", chr(10), in_, chr(10), p-obj-code, v-cd-prfx)
                          ,input yes
                          ,output sav) no-error.
    if error-status:error or sav = ? then do:
      return error return-value .
    end.
    if spl = sav then do:
      return error substitute("параметр sav&1, секция [kassa-&2] ini-файла - место ХРАНЕНИЯ ОБРАБОТАННЫХ файлов, принятых с касс типа &3 маг&1)&4" +
                              "параметр spl&1, секция [kassa-&2] ini-файла - место ПРИЕМА файлов с касс типа &3 маг&1)&4" +
                              "указывают на одну и ту же директорию &5 - что недопустимо"
                              , p-obj-code
                              , v-cd-prfx
                              , p-pos-type
                              , chr(10)
                              , (in_ + sav)).
    end.
    if p-mode = "send":U then do:
      run str/fileqnty.p ( out, output BadFlag ) .
      if not g#news and not g#auto and BadFlag then do:
        return error substitute("!!!Количество неотправленных на кассы файлов в каталоге &1 превышает 500 ! "
                                ,out).
      end.
    end.
  end.
  when 'MARIA':U then do:
    run verify-ini-entry in this-procedure (
                                            INPUT  'out'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогам для отсылки информации на POS &1&2" +
                                                              "(параметр out cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , chr(10)
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output out) no-error .
    if error-status:error or out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 для выгрузки информации на POS типа &1"
                                                   ,out
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    run verify-ini-entry in this-procedure (
                                            INPUT  'in'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к подкаталогам для приема информации с POS &1&2" +
                                                              "(параметр in cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , chr(10)
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output in_) no-error .
    if error-status:error or in_ = ? then return error return-value .
    RUN verify-file in this-procedure
                                      ( in_
                                      , substitute("Не найден каталог &1 для загрузки информации с POS типа &1"
                                                   ,in_
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry(  input ("spl":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует параметр spl&1&2 секция [kassa-&5] - подкаталог в каталоге &3&2 для приема данных с POS &4 для магазина с кодом &1"
                                          , p-obj-code
                                          , chr(10)
                                          , in_
                                          , p-pos-type
                                          , v-cd-prfx)
                          ,input yes
                          ,output spl) no-error.
    if spl = ? or error-status:error then return error return-value .
    RUN verify-file(input in_ + spl
                    ,input substitute("Не найден подкаталог &1 в директории &2&3(параметр spl&4, секция [kassa-&5] ini-файла)"
                                      , spl
                                      , in_
                                      , chr(10)
                                      , p-obj-code
                                      , v-cd-prfx)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    run verify-ini-entry in this-procedure (
                                            INPUT  'addin-dir'
                                            ,INPUT  'kassa-' + v-cd-prfx
                                            ,INPUT substitute("отсутствует путь к каталогу OLE-сервера Addin.exe для обмена информацией с POS &1&2" +
                                                              "(параметр addin-dir cекция [kassa-&3] ini файла)"
                                                             , p-pos-type
                                                             , chr(10)
                                                             , v-cd-prfx
                                                             )
                                            ,INPUT yes
                                            ,output v-remote) no-error .
    if v-remote = ? or error-status:error then return error return-value .
    RUN verify-file in this-procedure
                                      ( out
                                      , substitute("Не найден каталог &1 OLE-сервера AddIn.exe для обмена с POS типа &1"
                                                   ,v-remote
                                                   ,p-pos-type)
                                      , yes
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
    RUN verify-ini-entry(  input ("sav":U + string( p-obj-code ))
                          ,input substitute("kassa-&1":U, v-cd-prfx)
                          ,input substitute("отсутствует путь к подкаталогу sav &1 в каталоге &2 &3 для архива принятых данных для магазина с кодом &4 с POS &5"
                                          , chr(10)
                                          , in_
                                          , chr(10)
                                          , p-obj-code
                                          , v-cd-prfx)
                          ,input yes
                          ,output sav) no-error.
    if error-status:error or sav = ? then return error return-value .
  end.
END CASE.
