block-level on error undo, throw.
/*

$Revision: 8d6ad4ee6014, 1102, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: imp-ggr.p $
$Archive: utl/imp-ggr.p $

Импорт групп товаров

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

DEFINE VARIABLE p-install as logical no-undo init false .

define variable vss-revision    as character no-undo initial "$Revision: 8d6ad4ee6014, 1102, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: imp-ggr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/imp-ggr.p $":U .
define variable vss-description as character no-undo initial "Импорт групп товаров ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define stream sinp .

define variable f-name as character no-undo .
define variable v-ok   as logical   no-undo .
DEFINE VARIABLE v-level-name as character no-undo .
DEFINE VARIABLE v-level-num as integer no-undo .
DEFINE VARIABLE v-full-level-name as character no-undo .
DEFINE VARIABLE v-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-calc-method like ub.gds-grp.calc-method no-undo .
DEFINE VARIABLE v-increase-pc like ub.gds-grp.increase-pc no-undo .
DEFINE VARIABLE v-print-code  like ub.gds-grp.print-code  no-undo .
DEFINE VARIABLE v-d-pcnt like ub.gds-grp.d-pcnt no-undo .
DEFINE VARIABLE v-new-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-rid as recid no-undo.
DEFINE VARIABLE v-ask as logical no-undo init yes.
DEFINE VARIABLE choice as integer no-undo .
define stream slog.
define buffer buf_gds-grp for ub.gds-grp.

do
on error undo, return
:
  assign
    v-ok = false
  .
  if p-install = false then do:
    message
      "Импорт групп товаров" skip
      "Продолжить ?" skip
      view-as alert-box question buttons ok-cancel update v-ok .
    if not v-ok then do:
      return .
    end.
  end.

  assign
    f-name = 'gds-grp.ggr'
  .

  if p-install = false then do:
    system-dialog get-file f-name
      title "Выберите файл c группами товаров"
      filters "Файлы групп товаров *.ggr" "*.ggr",
                "Все файлы  *.*" "*.*"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update v-ok
      default-extension "ggr".
    if v-ok <> true then do:
      return .
    end.
  end.


  input stream sinp from value (f-name).

  define variable v-file-format as character no-undo .
  find first ub.sys-ctrl no-lock .
  if ub.sys-ctrl.db-num <> 0 then do:
    if not p-install then do:
      message
      "Утилиту импорта групп товаров можно запускать только в ГБД"
      view-as alert-box error .
    end.
    return error "Утилиту импорта групп товаров можно запускать только в ГБД".
  end.
  import stream sinp v-file-format .
  if v-file-format <> "GOODS_GRP_1_0" then do:
    input stream sinp close.
    message
      "Неправильный формат файла" skip
      "Первая строка файла" v-file-format skip
      "Файл" f-name skip
      view-as alert-box error .
    undo, return error .
  end.
  run write-to-log in this-procedure({&new-line} + string(today, "99/99/9999") + {&space-char} +
                                     string(time, "HH:MM:SS") + {&space-char} +
                                     g#userid) .
  repeat
  :
    define variable v-full-name as character no-undo .
    import stream sinp v-full-name .

    assign
      v-ok = true
    .
    if v-ask then
    run gbl/d-askw.w (input "Создание групп товаров",
              input "Группа" + {&new-line} + v-full-name,
              input "|",
              input "Создать|Не создавать|Создать все|Отмена",
              input "Создать группу (если такой еще нет)|Не создавать группу|Перестать спрашивать и по возможности создать все|Прекратить загрузку групп товаров",
              input 1,
              input 4,
              output choice).
   CASE choice:
    when 1 then do:
      assign
      v-ok = yes.
    end.
    when 2 then do:
      assign
      v-ok = no
      .
    end.
    when 3 then do:
      assign
      v-ok = yes
      v-ask = no
      .
    end.
    when 4 then do:
      leave.
    end.
   END CASE.
    if v-ok = true then do:
      assign
      v-full-name = trim(v-full-name, {&delim-grp})
      v-full-level-name = "":U
      .
      find first buf_gds-grp no-lock where
                 buf_gds-grp.upper-code = 0 no-error .
      assign
      v-node-code = buf_gds-grp.node-code
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      v-d-pcnt = buf_gds-grp.d-pcnt
      v-print-code = buf_gds-grp.print-code
      .
      /* создать группу на основании полного имени v-full-name */
      _cycle:
      do v-level-num = 1 to num-entries(v-full-name, {&delim-grp}):
        assign
        v-level-name =  entry(v-level-num, v-full-name, {&delim-grp})
        v-full-level-name = v-full-level-name + v-level-name + {&delim-grp}
        .
        find first buf_gds-grp no-lock where
                   buf_gds-grp.upper-code = v-node-code
               and buf_gds-grp.node-name = v-level-name no-error .
        if not avail buf_gds-grp then do:
         run ref/gdsgrp01.p (
                         input {&add-def}
                        ,input p-install
                        ,input no /*p-get-node-code*/
                        ,input yes /*p-fill-tax-from-upper*/
                        ,input-output v-new-node-code
                        ,input-output v-node-code
                        ,input v-level-name
                        ,input v-calc-method
                        ,input v-increase-pc
                        ,input v-print-code
                        ,input {&pr-round-off}
                        ,input 0
                        ,output v-rid
                        ) no-error.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
            next _cycle.
          end.
          /* сохранить информацию о созданных группах в отдельный файл */
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
          end.
          else do:
            run write-to-log in this-procedure("new group" + {&space-char} + v-full-level-name) .
          end.
          assign
          v-node-code = v-new-node-code
          .
        end.
        else do:
          run write-to-log in this-procedure("exists group" + {&space-char} + v-full-level-name) .
          assign
          v-node-code = buf_gds-grp.node-code
          v-calc-method = buf_gds-grp.calc-method
          v-increase-pc = buf_gds-grp.increase-pc
          v-print-code  = buf_gds-grp.print-code
          v-d-pcnt = buf_gds-grp.d-pcnt
          .
          next _cycle.
        end.

      end. /*do v-level-num*/
    end. /* v-ok*/
    { gbl/stopwork.i }
  end. /*repeat*/
  input stream sinp close.

end.


message "Импорт групп товаров закончен.".

procedure write-to-log :
define input parameter P-MESSAGE as character no-undo .

  do
  on error undo, return error
  :
    output STREAM SLOG TO imp-ggr.log append.
    put STREAM SLOG unformatted
    P-MESSAGE SKIP.
    OUTPUT STREAM SLOG CLOSE.
  end.

end procedure. /* write-to-log */