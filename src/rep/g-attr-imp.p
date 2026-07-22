block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-attr-imp.p $
$Archive: rep/g-attr-imp.p $

Импорт глобальных атрибутов (Йошкар-Ола)

Автор: Шальнев Иван Сергеевич
Дата создания: 07/10/11
Author: Shalnev Ivan
Creation date: 07/10/11

*/



define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-attr-imp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-attr-imp.p $":U .
define variable vss-description as character no-undo init "Закачка состава сырья товаров".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }
{ gbl/waitfram.i }

define stream inp.
define buffer buf_goods for ub.goods.
define variable InputFileName as char                 no-undo.
define variable glog as logical no-undo .
define variable v-import-string as character.
define variable v-gds-code         like ub.goods.gds-code no-undo.
define variable v-length-of        as integer no-undo.
define variable v-width-of         as integer no-undo.
define variable v-height-of        as integer no-undo.
define variable v-qnty-in-box      as integer no-undo.
define variable v-weight-box       as decimal no-undo.
define variable v-qnty-on-pallet   as integer no-undo.
define variable v-weight-of-pallet as decimal no-undo.
define variable ii as integer no-undo initial 0.
define variable v-value as character no-undo.
define variable v-type as character no-undo.

do
  on error undo, return error
  :
  { gbl/getcntxt.i get }
  if ( v-cntxt-db-num > 0 ) then do:
    message "Данная утилита может работать только в ГБД.".
    return.
  end.

  SYSTEM-DIALOG GET-FILE InputFileName
                TITLE   "Файл с глобальными атрибутами"
                FILTERS "Текстовый файл (*.txt)" "*.txt",
                        "Все файлы (*.*)"        "*.*"
                MUST-EXIST
                USE-FILENAME
                UPDATE glog.
  if not glog then return.

  InputFileName = trim (string (InputFileName)) .

  glog = yes.
  message "Выберите режим импорта:" skip
          "YES - замена" skip
          "NO - добавление (заполняются только пустые)"
          view-as alert-box question buttons YES-NO update glog.

  input stream inp FROM value (InputFileName) convert source "1251".

      REPEAT :
        IMPORT stream inp UNFORMATTED v-import-string NO-ERROR.
        ii = ii + 1.
        run waitfram-show in this-procedure ("Импортированно атрибутов для : " + string (ii) + "товаров").
        assign
          v-gds-code         = integer( entry(1, v-import-string, ";"))
          v-length-of        = integer( entry(9, v-import-string, ";"))
          v-width-of         = integer(entry(10, v-import-string, ";"))
          v-height-of        = integer(entry(11, v-import-string, ";"))
          v-qnty-in-box      = integer(entry(15, v-import-string, ";"))
          v-weight-box       = decimal(replace(entry(16, v-import-string, ";"),",","."))
          v-qnty-on-pallet   = integer(entry(17, v-import-string, ";"))
          v-weight-of-pallet = decimal(replace(entry(18, v-import-string, ";"),",","."))
        .
        find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error.
        if available buf_goods then do :
          if glog then do :
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-length-of},
                                                  input v-length-of) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-width-of},
                                                  input v-width-of) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-height-of},
                                                  input v-height-of) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-qnty-in-box},
                                                  input v-qnty-in-box) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-weight-box},
                                                  input v-weight-box) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-qnty-on-pallet},
                                                  input v-qnty-on-pallet) no-error.
            run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-weight-of-pallet},
                                                  input v-weight-of-pallet) no-error.

          end.
          else do :
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-length-of},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-length-of},
                                                    input v-length-of) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-width-of},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-width-of},
                                                    input v-width-of) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-height-of},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-height-of},
                                                    input v-height-of) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-qnty-in-box},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-qnty-in-box},
                                                    input v-qnty-in-box) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-weight-box},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-weight-box},
                                                    input v-weight-box) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-qnty-on-pallet},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-qnty-on-pallet},
                                                    input v-qnty-on-pallet) no-error.
            end.
            run gds-attr-value in this-procedure (input buf_goods.gds-code ,
                                                  input {&attr-weight-of-pallet},
                                                  output v-value,
                                                  output v-type) no-error.
            if v-value = ? or v-value = "" then do :
              run gds-attr-write in this-procedure (input buf_goods.gds-code ,
                                                    input {&attr-weight-of-pallet},
                                                    input v-weight-of-pallet) no-error.
            end.
          end.
        end.
      END.
  INPUT stream inp CLOSE.
  run waitfram-hide in this-procedure.
  message
   "Импорт атрибутов завершен   " skip
  view-as alert-box information.
end.