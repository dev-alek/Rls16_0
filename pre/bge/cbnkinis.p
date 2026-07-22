block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-format    as character no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-mode     as character no-undo .
define output parameter out     as character no-undo .
define output parameter in_     as character no-undo .
define output parameter spl     as character no-undo .
define output parameter sav     as character no-undo .
define output parameter adresat as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: cbnkinis.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/cbnkinis.p $":U .
def var vss-description as character no-undo init "Получение настроек для экспорта/импорта в систему КЛИЕНТ-БАНК из ini-файла".
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
define variable v-format-prfx as character no-undo .
define variable glog as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable yestr as character no-undo .
CASE p-format:
  when '1s':U then do:
    assign
    v-format-prfx = '1s':U
    .
  end.
END CASE.
CASE p-format:
  when '1s':U
  then do:
      run verify-ini-entry in this-procedure (
                                                INPUT  p-bik + '_out'
                                              ,INPUT  'client-bank-' + v-format-prfx
                                              ,INPUT substitute("отсутствует путь к подкаталогу out для экспорта в систему КЛИЕНТ-БАНК по формату &1 для БИК &2", p-format, p-bik)
                                              ,INPUT yes
                                              ,output out) no-error .
      if error-status:error or out = ? then return error return-value .
      RUN verify-file in this-procedure
                                        ( out
                                        , substitute("Не найден каталог &1 параметр &2_out, секция [client-bank-&3] ini-файла"
                                                    , out
                                                    , p-bik
                                                    , v-format-prfx)
                                        , yes
                                        ,output glog) no-error.
      if error-status:error or not glog then return error return-value .
      run verify-ini-entry in this-procedure (
                                               INPUT  (p-bik + '_in')
                                              ,INPUT  ('client-bank-' + v-format-prfx)
                                              ,INPUT substitute("отсутствует путь к подкаталогу in для импорта данных из системы КЛИЕНТ-БАНК по формату &1 для БИК &2"
                                                              , p-format
                                                              , p-bik)
                                              ,INPUT yes
                                              ,output in_) no-error .
      if error-status:error or in_ = ? then return error return-value .
      RUN verify-file in this-procedure
                                        ( in_
                                        , substitute("Не найден каталог &1 параметр &2_in, секция [client-bank-&3] ini-файла"
                                                     , in_
                                                     , p-bik
                                                     , v-format-prfx)
                                        ,yes
                                        ,output glog) no-error.
      if error-status:error or not glog then return error return-value .
      RUN verify-ini-entry(  input substitute("&1_spl&2":U,  p-bik, p-host-code)
                            ,input substitute("client-bank-&1":U, v-format-prfx)
                            ,input substitute("отсутствует путь к подкаталогу &1&2 в каталогах экспорта/импорта данных в систему КЛИЕНТ-БАНК по формату &3 для фирмы с кодом &4"
                                            , substitute("&1_spl&2":U,  p-bik, p-host-code)
                                            , chr(10)
                                            , v-format-prfx
                                            , p-host-code
                                            )
                            ,input yes
                            ,output spl) no-error.
     if spl = ? or error-status:error then return error return-value .
     RUN verify-file(  input out + spl
                      ,input substitute("Не найден подкаталог &1 в директории &2&3 параметр &4_spl&5, секция [client-bank-&6] ini-файла"
                                        , spl
                                        , out
                                        , chr(10)
                                        , p-bik
                                        , p-host-code
                                        , v-format-prfx)
                      ,input yes
                      ,output glog) no-error.
     if error-status:error or not glog then return error return-value .
     RUN verify-ini-entry(   input substitute("&1_sav&2":U, p-bik, p-host-code )
                            ,input substitute("client-bank-&1":U, v-format-prfx)
                            ,input substitute("отсутствует путь к подкаталогу &1_sav&2 в каталогах экспорта/импорта данных в систему КЛИЕНТ-БАНК&3" +
                                              "по ФОРМАТУ &4 для БИК &1 фирма &2"
                                              ,p-bik
                                              ,p-host-code
                                              ,chr(10)
                                              ,v-format-prfx
                                              )
                            ,input yes
                            ,output sav) no-error.
      if error-status:error or sav = ? then do:
          sav = spl.
      end.
      else do:
        RUN verify-file(  input (in_ + sav)
                          ,input substitute("Не найден подкаталог &1 в директории &2&3 параметр &4_sav&5, секция [client-bank-&6] ini-файла"
                                            , sav
                                            , in_
                                            , chr(10)
                                            , p-bik
                                            , p-host-code
                                            , v-format-prfx)
                          ,input yes
                          ,output glog) no-error.
        if error-status:error or not glog then return error return-value .
      end.
      run verify-ini-entry in this-procedure (
                                                INPUT  p-bik + '_adresat'
                                              ,INPUT  'client-bank-' + v-format-prfx
                                              ,INPUT substitute("отсутствует имя системы КЛИЕНТ-БАНК (параметр &1) по формату &2 для БИК &3", (p-bik + '_adresat'),  p-format, p-bik)
                                              ,INPUT yes
                                              ,output adresat) no-error .
      if error-status:error or out = ? then return error return-value .
      if p-mode = "send":U then do:
        run str/fileqnty.p ( out, output BadFlag ) .
        if not g#news and BadFlag then do:
          return error substitute("!!!Количество неотправленных в систему КЛИЕНТ-СЕРВЕР файлов в каталоге &1 превышает 500 ! "
                                  ,out).
        end.
      end.
  end.
END CASE.
