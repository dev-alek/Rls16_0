block-level on error undo, throw.
define input  parameter strB        as character        no-undo.
define output parameter strFRG-ACC  as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: db20b37e7994, 1993, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Aug 23 12:08:20 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ini.p $":U .
define variable vss-description as character no-undo init "Cоздание каталогов, секции и ключа для Экспорта XML".
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
define variable strBGE    as character    no-undo.
define variable strDIR    as character    no-undo.
strBGE = ibs.th.gbl.gbl-inipar:dirfrgAcc .
if strBGE = ? then do :
     RUN makeFRGdir ( OUTPUT strDIR ).
     IF RETURN-VALUE = "OK"
     THEN DO:
       define variable v-err-message as character no-undo .
       v-err-message = ibs.th.gbl.gbl-inipar:PutKeyValue("BGE", "Dirfrg-acc", "\frg-acc") .
       if v-err-message > "" then do:
             message v-err-message
                skip(1)
                     "Не удалось записать значение ключа"
                skip "Dirfrg-acc в секции BGE ini-файла."
                skip "Выгрузка данных невозможна."
                skip(1)
                skip "Снимите защиту от записи"
                skip "или пропишите каталог выгрузки"
                skip "в ini-файле вручную."
             view-as alert-box error.
             undo, return error .
         end.
         assign
            strFRG-ACC = strDIR + "\frg-acc"
         .
         RETURN "OK".
     END.
     ELSE RETURN "ERROR".
end .
else do :
  strFRG-ACC = strBGE .
  RETURN "OK".
end .
PROCEDURE makeFRGdir :
    define output parameter strDIR   as character        no-undo.
    define variable strQuest    as character    no-undo.
    run bge/bge-ini1.w (
          input strB
        , output strQuest
    ).
    IF strQuest = "OK"
    THEN DO:
        strQuest = "ERROR".
        run bge/bge-ini2.w (
              input strB
            , OUTPUT strQuest
            , OUTPUT strDIR
        ) NO-ERROR.
        IF strQuest = "OK"
        AND NOT ERROR-STATUS:ERROR
        THEN DO:
          run bge/dir_cd.p (strDir + "\frg-acc", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          run bge/dir_cd.p (strDir + "\frg-acc\dict", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          run bge/dir_cd.p (strDir + "\frg-acc\exp-acc", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          run bge/dir_cd.p (strDir + "\frg-acc\global", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          RETURN "OK".
        END.
    END.
    RETURN "ERROR".
END PROCEDURE.
