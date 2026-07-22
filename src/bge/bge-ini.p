block-level on error undo, throw.
/*

$Revision: db20b37e7994, 1993, rls $
$Author: SMMolotkov $
$Date: Fri Aug 23 12:08:20 2019 +0300 $
$Workfile: bge-ini.p $
$Archive: bge/bge-ini.p $

Cоздание каталогов, секции и ключа для Экспорта XML

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    strB        as character    - "bge" - экспорт во внешн бух, "buh" - импорт из IBS Trade
    strFRG-ACC  as character    - полный путь до каталога ЭКСПОРТА: d:\temp\frg-acc

Output:
    RETURN-VALUE =  "OK", тогда strFRG-ACC - это полный путь до каталога ЭКСПОРТА;
    RETURN-VALUE <> "OK", отказ от создания секции-ключа или не созданы каталоги

*/
define input  parameter strB        as character        no-undo.
define output parameter strFRG-ACC  as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: db20b37e7994, 1993, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Aug 23 12:08:20 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ini.p $":U .
define variable vss-description as character no-undo init "Cоздание каталогов, секции и ключа для Экспорта XML".
{ cmp/vssrevis.i }

define variable strBGE    as character    no-undo.
define variable strDIR    as character    no-undo.

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

strBGE = ibs.th.gbl.gbl-inipar:dirfrgAcc .
if strBGE = ? then do : /* нет ключа */

     RUN makeFRGdir ( OUTPUT strDIR ). /* запросим место и сделаем попытку созданий дир */
     IF RETURN-VALUE = "OK"
     THEN DO:
       define variable v-err-message as character no-undo .
       v-err-message = ibs.th.gbl.gbl-inipar:PutKeyValue("BGE", "Dirfrg-acc", "{&Slash}frg-acc") .
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
            strFRG-ACC = strDIR + "{&Slash}frg-acc"
         .
         RETURN "OK".
     END.
     ELSE RETURN "ERROR".
     
end .
else do : /* есть ключ */
  strFRG-ACC = strBGE .
  RETURN "OK".
end .


PROCEDURE makeFRGdir :
    /* Запросить место и создать 4 каталога; OK - удача */
    define output parameter strDIR   as character        no-undo.

    define variable strQuest    as character    no-undo.

               /* Запросить подтверждение : "OK" - создать, "CANCEL" - отказ */
    run bge/bge-ini1.w (
          input strB
        , output strQuest
    ).
    IF strQuest = "OK"
    THEN DO:                 /* запросить место */
        strQuest = "ERROR".
        run bge/bge-ini2.w (
              input strB
            , OUTPUT strQuest
            , OUTPUT strDIR
        ) NO-ERROR.         /* место - каталог */
        IF strQuest = "OK"
        AND NOT ERROR-STATUS:ERROR
        THEN DO:
          /* попытка создать дир "frg-acc" */
          run bge/dir_cd.p (strDir + "{&Slash}frg-acc", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          /* создана дир "frg-acc" */

          /* попытка создать дир "dict" */
          run bge/dir_cd.p (strDir + "{&Slash}frg-acc{&Slash}dict", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          /* создана дир "dict" */

          /* попытка создать дир "exp-acc" */
          run bge/dir_cd.p (strDir + "{&Slash}frg-acc{&Slash}exp-acc", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          /* создана дир "exp-acc" */

          /* попытка создать дир "global" */
          run bge/dir_cd.p (strDir + "{&Slash}frg-acc{&Slash}global", "CA").
          IF RETURN-VALUE = "ERROR" THEN RETURN "ERROR".
          /* создана дир "global" */

          RETURN "OK".
        END.
    END.
    RETURN "ERROR".
END PROCEDURE.