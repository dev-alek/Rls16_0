block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура проверки, восстановления Sequences

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input parameter p-action    as character no-undo.
  /* "check" - проверка, "rest" - восстановление */
  /* "check-no-msg" - проверка, без сообщения в конце, "rest-no-msg" - восстановление, без сообщения в конце*/
define input parameter p-seq-list  as character no-undo .
  /*пусто - все sequence или список нужных*/
define input parameter p-first-err as logical no-undo .
  /*yes - работа до первой ошибки, no - ошибки игнорируются */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура проверки, восстановления Sequences".
{ cmp/str-glbl.i }
{ cmp/getmcode.i restseq }
{ str/doc-code.i } /*function get-doc-code-int64 returns int64*/

define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable mode-erprn as logical no-undo.
/* Определяем интеграционный или нет режим работы */
{ cmp/library.i       }
{ gbl/conf-rd.i
    "'is-erpRN'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    NO
    conf-par
    par-type
    no-error
}
IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
                                                 else mode-erprn = no.


&scoped-define ignore_list "~
next-report~
,s-datatype~
,s-petrol-code~
,s-sgr~
,s-inv~
,s-reserv1~
,s-reserv2~
,s-doc~
,s-doc-type~
,s-file-num~
,s-line-num~
,s-tax-rate~
,synch-cli-grp~
,synch-gds-grp~
,s-v-doc~
,s-ext-classif~
,s-fbr-grp~
,s-user-history~
,s-tog~
,s-op-hist~
,s-jwlr-grp~
,s-jewelry~
,s-h-route~
,s-h-route-dump~
,s-h-route-dump~
,synch-an-grp~
":U

define stream LogStream .

define variable v-ld-db-name      as character no-undo .
define variable v-seq-val         as int64     no-undo .
define variable v-seq-name        as character no-undo .
define variable v-proc-name       as character no-undo .
define variable v-total-cnt       as integer   no-undo .
define variable v-total-run       as integer   no-undo .
define variable v-total-err       as integer   no-undo .

define variable v-curr-db-num     as integer no-undo.
define variable v-curr-seq-name   as character no-undo .
define variable v-curr-seq-value  as int64     no-undo .
define variable v-curr-recid      as recid     no-undo .
define variable v-new-seq-value   as int64     no-undo .
define variable v-table-name      as character no-undo .
define variable v-seq-field-name  as character no-undo .
define variable v-num-rec         as integer   no-undo .

define variable v-msg             as character no-undo .
define variable v-show-msg        as logical   no-undo .
define variable v-action          as character no-undo .

define frame seq-info
  v-curr-seq-name  format "x(25)" label "Счетчик" skip
  v-table-name     format "x(20)" label "Таблица" skip
  v-seq-field-name format "x(20)" label "Поле"    skip
  v-num-rec        label "Количество" skip
  with view-as dialog-box side-labels 1 columns three-d
  title "Проверка, восстановление счетчиков" .

&scoped-define init-validation ~
assign ~
  v-curr-seq-value = 0 ~
.

&scoped-define show-action ~
  do with frame seq-info ~
  on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) ~
  : ~
    assign ~
      v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format) ~
      v-table-name :screen-value     = string( v-table-name, v-table-name :format) ~
      v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format) ~
      v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format) ~
    . ~
  end. ~

&scoped-define validate-sequence ~
assign ~
  v-curr-seq-name  = "~{&sequence-name~}" ~
  v-table-name     = "~{&table-name~}" ~
  v-seq-field-name = "~{&seq-field-name~}" ~
  v-num-rec        = 0 ~
  v-curr-recid     = 0 ~
  v-new-seq-value  = 0 ~
. ~
~{&show-action~} ~
for each restseq.~{&table-name~} no-lock  ~
on error undo, return error substitute( "&1 (validate-sequence ~{&table-name~}). &2&3&4", vss-workfile, return-value, ~{&new-line~}, error-status :get-message ( 1 ) )~
: ~
  ~{&not-include-in-seq-records} ~
  assign ~
    v-num-rec = v-num-rec + 1 ~
  . ~
  if v-num-rec mod 10 = 0 then do: ~
    ~{&show-action~} ~
  end. ~
  ~{&seq-expresstion~} ~
  if v-curr-seq-value < v-new-seq-value then do: ~
    assign ~
      v-curr-seq-value = v-new-seq-value ~
      v-curr-recid     = recid(restseq.~{&table-name~}) ~
    . ~
  end. ~
end.

&scoped-define validate-sequence-first-space ~
DEFINE VARIABLE v-new-code-value as int64 no-undo. ~
assign ~
  v-curr-seq-name  = "~{&sequence-name~}" ~
  v-table-name     = "~{&table-name~}" ~
  v-seq-field-name = "~{&seq-field-name~}" ~
  v-num-rec        = 0 ~
  v-curr-recid     = 0 ~
  v-new-seq-value  = 0 ~
. ~
~{&show-action~} ~
do v-new-seq-value = 1 to ~{&seq-up-level} ~
on error undo, return error substitute( "&1 (validate-sequence-first-space ~{&table-name~}). &2&3&4", vss-workfile, return-value, ~{&new-line~}, error-status :get-message ( 1 ) )~
: ~
  assign v-new-code-value = ~{&seq-expresstion}. ~
  if v-new-code-value < currentdb-from-code then next. ~
  if v-new-code-value > currentdb-end-code then leave. ~
  find first restseq.~{&table-name~} no-lock ~
    where restseq.~{&table-name~}.~{&seq-field-name} = v-new-code-value ~
    no-error. ~
  if available restseq.~{&table-name~}  then do: ~
    if v-curr-seq-value < v-new-seq-value then do: ~
      assign ~
        v-curr-seq-value = v-new-seq-value ~
        v-curr-recid     = recid(restseq.~{&table-name~}) ~
      . ~
    end. ~
  END. ~
  ELSE do: ~
    assign ~
      v-curr-seq-value = v-new-seq-value - 1 ~
    . ~
    LEAVE. ~
  END. ~
  v-num-rec = v-num-rec + 1. ~
  if v-num-rec mod 10 = 0 then do: ~
    ~{&show-action~} ~
  end. ~
end.



&scoped-define update-sequence ~
if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value  ~
  or (v-curr-seq-value <> 0  ~
      and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value   ~
     ) ~
then do: ~
  run log-error in this-procedure ~
    (input v-curr-seq-name ~
    ,input v-curr-recid ~
    ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name ) ~
    ,input v-curr-seq-value ~
    ). ~
  if v-action = "rest":U then do: ~
    assign ~
      dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value ~
    . ~
  end. ~
end. ~
else do: ~
  if v-curr-seq-value = 0 then do:  ~
    /*если не было записей, по которым можно восстановить сикуэнс */ ~
    find first restseq._sequence no-lock ~
      where restseq._sequence._seq-name = "~{&sequence-name~}" no-error. ~
    if available restseq._sequence then do: ~
      if v-action = "rest":U then do: ~
        assign ~
          dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init ~
        . ~
      end. ~
    end. ~
  end. ~
end.

function get-chk-doc-doc-code-int64 returns int64
  ( input p-db-num as integer, input p-doc-code as character ) :

  define variable v-doc-code-int64 as int64   no-undo .

  case num-entries(p-doc-code, "/") :
    when 2 then do:
      if p-db-num = 0 then return 0.
      assign
        v-doc-code-int64 = int64(entry(2, p-doc-code, "/"))
        no-error
      .
    end.
    when 1 then do:
      if p-db-num <> 0 then return 0.
      assign
        v-doc-code-int64 = int64(p-doc-code) no-error
      .
    end.
    otherwise do:
      /* do nothing */
      assign
      v-doc-code-int64 = 0.
    end.
  end case.

  return v-doc-code-int64 .
end.

function get-firm-firm-code-int64 returns int64
  ( input p-curr-value      as int64,
    input p-db-num        as integer) :

  define variable v-firm-code-db as int64   no-undo .
    v-firm-code-db = p-curr-value + p-db-num *  exp( 10, 7 ) .
    return v-firm-code-db.
end.

function get-person-psn-code-int64 returns int64
  ( input p-curr-value as int64,
    input p-db-num        as integer ) :

  define variable v-psn-code-db as int64   no-undo .
    assign v-psn-code-db = p-curr-value + p-db-num *  exp( 10, 7 ).
       return v-psn-code-db.
end.


function get-layout-id-int64 returns int64
  ( input p-db-num as integer, input p-layout-id as character ) :

  define variable v-layout-id-int64 as int64   no-undo .

  case num-entries(p-layout-id, "-") :
    when 2 then do:
      if p-db-num = 0 then return 0.
      assign
        v-layout-id-int64 = int64(entry(2, p-layout-id, "-"))
        no-error
      .
    end.
    when 1 then do:
      if p-db-num <> 0 then return 0.
      assign
        v-layout-id-int64 = int64(p-layout-id) no-error
      .
    end.
    otherwise do:
      /* do nothing */
      assign
      v-layout-id-int64 = 0.
    end.
  end case.

  return v-layout-id-int64 .
end.


procedure factord-to-fact-num :

  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as int64 no-undo .

  define variable v-fact-order-trunc as decimal no-undo .
  define variable v-fact-num-dec as decimal no-undo .

  do
  on error undo, return error substitute( "&1 (factord-to-fact-num). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      assign
      p-fact-num = 0.
      return.
    end.

    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      v-fact-num-dec = (p-fact-order - v-fact-order-trunc ) * 10000000000
      p-fact-num = int64(v-fact-num-dec)
    .
  end.

end procedure. /* factord-to-fact-num */



procedure clear-log-file :

  do
  on error undo, return error substitute( "&1 (clear-log-file). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    output stream LogStream to "rest-seq.log" .
    output stream LogStream close .
  end.

end procedure. /* clear-log-file */


procedure log-error :

  define input parameter p-err-seq-name   as character no-undo .
  define input parameter p-err-recid      as recid     no-undo .
  define input parameter p-err-curr-value as int64     no-undo .
  define input parameter p-err-new-value  as int64     no-undo .

  assign
    v-total-err = v-total-err + 1
  .

  do
  on error undo, return error substitute( "&1 (log-error). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    output stream LogStream to "rest-seq.log" append .
    put stream LogStream unformatted
      string(today, "99/99/9999") space
      string(time, "HH:MM") space
      p-action space
      p-err-seq-name space
      "recid:" space p-err-recid  space
      "curr:" space p-err-curr-value space
      "new:" space p-err-new-value
      skip
      .
    output stream LogStream close .
  end.

end procedure. /* log-error */

procedure check-seq-list :

  do
  on error  undo, return error substitute( "&1 (check-seq-list). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (check-seq-list). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-seq-list). endkey", vss-workfile )
  :
    define variable v-ret-msg         as character no-undo .
    define variable v-all-proc-list   as character no-undo .
    define variable v-ind             as integer   no-undo .
    define variable v-num-entries     as integer   no-undo .
    define variable v-proc-name       as character no-undo .
    define variable v-check-seq-name  as character no-undo .
    define variable v-list-excessive  as character no-undo .
    define variable v-list-necessary  as character no-undo .
    define variable v-list-all-av-seq as character no-undo .

    assign
      v-all-proc-list   = this-procedure :internal-entries
      v-ret-msg         = "":U
      v-list-excessive  = "":U
      v-list-necessary  = "":U
      v-num-entries     = num-entries( v-all-proc-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1 (check-seq-list do v-ind = 1). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        v-proc-name = entry( v-ind, v-all-proc-list )
      .
      if v-proc-name begins "restore-":U then do:
        assign
          v-check-seq-name  = trim( replace( v-proc-name, "restore-":U, "":U ) )
          v-list-all-av-seq = v-list-all-av-seq + (if v-list-all-av-seq = "":U then "":U else ",":U) + v-check-seq-name
        .
        find first restseq._sequence no-lock
          where restseq._sequence._seq-name = v-check-seq-name
          no-error.
        if not available restseq._sequence
          or lookup( restseq._sequence._seq-name, {&ignore_list}, ",":U ) > 0
        then do:
          assign
            v-list-excessive = v-list-excessive + {&new-line} + v-check-seq-name
          .
        end.
      end.
    end.
    for each restseq._sequence no-lock
    on error undo, return error substitute( "&1 (check-seq-list for each restseq._sequence). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if lookup( restseq._sequence._seq-name, v-list-all-av-seq, ",":U ) = 0
        and lookup( restseq._sequence._seq-name, {&ignore_list}, ",":U ) = 0
      then do:
        assign
          v-list-necessary = v-list-necessary + {&new-line} + restseq._sequence._seq-name
        .
      end.
    end.

    if v-list-excessive <> "":U then do:
      assign
        v-ret-msg = v-ret-msg + substitute( "&1Лишние процедуры по обработке sequence: &2", {&new-line}, v-list-excessive ) + {&new-line}
      .
    end.
    if v-list-necessary <> "":U then do:
      assign
        v-ret-msg = v-ret-msg + substitute( "&1Отсутствуют процедуры по обработке sequence: &2", {&new-line}, v-list-necessary ) + {&new-line}
      .
    end.

    if v-ret-msg <> "":U then do:
      return error v-ret-msg .
    end.
    else do:
      return .
    end.

  end.

end procedure. /* check-seq-list */

do
on error undo, return error substitute( "&1 (main). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:

  if lookup(p-action, "check,rest,check-no-msg,rest-no-msg" ) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Запрошено неизвестное действие" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo, return error .
  end.

  assign
    v-show-msg = true
  .
  if lookup(p-action, "check-no-msg,rest-no-msg":U ) > 0 then do:
    assign
      v-show-msg = false
    .
  end.

  assign
    v-action = "check":U
  .
  if lookup(p-action, "rest,rest-no-msg":U ) > 0 then do:
    assign
      v-action = "rest":U
    .
  end.

  assign
    v-ld-db-name = ldbname( "restseq":U )
  .

  run clear-log-file in this-procedure .
  assign
    v-total-cnt = 0
    v-total-err = 0
    v-total-run = 0
  .

  run check-seq-list in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке корректности процедуры восстановления" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    output stream LogStream to "rest-seq.log" append .
    put stream LogStream unformatted
      string(today, "99/99/9999") space string(time, "HH:MM") space
      return-value
      skip
      .
    output stream LogStream close .
    if p-first-err = true then do:
      return error .
    end.
  end.

  find first restseq.sys-ctrl no-lock
    no-error .
  if available restseq.sys-ctrl then do:
    assign
      v-curr-db-num = restseq.sys-ctrl.db-num
    .
  end.
  if v-curr-db-num = ? then do:
    undo, return error "(rest-seq.p) Не удалось определить номер текущей БД" .
  end.

  view frame seq-info .
  for each restseq._sequence no-lock
  on error undo, return error substitute( "&1 (for each restseq._sequence). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    assign
      v-seq-name  = restseq._sequence._seq-name
      v-proc-name = "restore-":U + v-seq-name
    .
    if lookup( v-seq-name, {&ignore_list} ) > 0 then do:
      next.
    end.

    if ( p-seq-list <> "":U
         and lookup( v-seq-name, p-seq-list ) > 0
       )
       or p-seq-list = "":U
    then do:

      assign
        v-total-cnt      = v-total-cnt + 1
        v-seq-val        = dynamic-current-value( v-seq-name, v-ld-db-name )
        v-curr-seq-value = v-seq-val
      .
      if restseq._sequence._seq-max <> ? then do:
        if v-seq-val > restseq._sequence._seq-max then do:
          assign
            v-curr-seq-value = restseq._sequence._seq-max
          .
        end.
      end.
      else do:
        if v-seq-val > 9223372036854775807 then do:
          assign
            v-curr-seq-value = 9223372036854775807
          .
        end.
      end.
      if restseq._sequence._seq-min <> ?
        and v-seq-val < restseq._sequence._seq-min
      then do:
        assign
          v-curr-seq-value = restseq._sequence._seq-min
        .
      end.
      if v-curr-seq-value <> v-seq-val then do:
        run log-error in this-procedure ~
          (input v-seq-name
          ,input ?
          ,input v-seq-val
          ,input v-curr-seq-value
          ).
        if v-action = "rest":U then do:
          assign
            dynamic-current-value( v-seq-name, v-ld-db-name ) = v-curr-seq-value
          .
        end.
        else do:
          next .
        end.
      end.
      if lookup( v-proc-name, this-procedure :internal-entries ) > 0 then do:
        assign
          v-total-run = v-total-run + 1
        .
        run value( v-proc-name ) in this-procedure
          ( input v-curr-db-num
          ) no-error .
        if error-status :error then do:
          assign
            v-msg = substitute( "Ошибка при восстановлении счетчика &1&2&3&2&4", v-seq-name, {&new-line}, error-status :get-message(1), return-value)
          .
          output stream LogStream to "rest-seq.log" append .
          put stream LogStream unformatted
            string(today, "99/99/9999") space string(time, "HH:MM") space
            v-msg
            skip
            .
          output stream LogStream close .
          if v-show-msg = true then do:
            message
              v-msg
              view-as alert-box error .
          end.
          if p-first-err = true then do:
            return error v-msg.
          end.
        end.
      end.
    end.
  end.

  hide frame seq-info .

  case v-action :
    when "rest":U then do:
      if v-total-err <> 0 then do:
        assign
          v-msg = substitute( "Восстановление счетчиков закончено.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Исправлено счетчиков  &4.&1"
                              + "Список исправленных счетчиков приведен в файле &5.&1"
                              , {&new-line}
                              , v-total-cnt
                              , v-total-run
                              , v-total-err
                              , "rest-seq.log":U
                            )
        .
      end.
      else do:
        assign
          v-msg = substitute( "Восстановление счетчиков закончено.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Все счетчики содержали правильную информацию."
                              , {&new-line}
                              , v-total-cnt
                              , v-total-run
                            )
        .
      end.
    end.
    when "check":U then do:
      if v-total-err <> 0 then do:
        assign
          v-msg = substitute( "Проверка счетчиков закончена.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Обнаружено ошибок     &4.&1"
                              + "Список ошибок приведен в файле &5.&1"
                              , {&new-line}
                              , v-total-cnt
                              , v-total-run
                              , v-total-err
                              , "rest-seq.log":U
                            )
        .
      end.
      else do:
        assign
          v-msg = substitute( "Проверка счетчиков закончена.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Ошибок не обнаружено."
                              , {&new-line}
                              , v-total-cnt
                              , v-total-run
                            )
        .
      end.
    end.
  end case.

  output stream LogStream to "rest-seq.log" append .
  put stream LogStream unformatted
    string(today, "99/99/9999") space string(time, "HH:MM") space
    v-msg skip
    .
  output stream LogStream close .

  if v-show-msg = true then do:
    message
      v-msg
      view-as alert-box information .
  end.

  return v-msg .

end.

procedure restore-s-trn-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-trn-fact). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    {&init-validation}

    &scoped-define sequence-name   s-trn-fact

    &scoped-define table-name      price-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      trn-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-trn-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-fact */

procedure restore-s-chk :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-chk). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

    {&init-validation}

    &scoped-define sequence-name   s-chk

    &scoped-define table-name      chk-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-chk-doc-doc-code-int64(p-curr-db-num, restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-chk-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-chk-doc-doc-code-int64(p-curr-db-num, restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-chk */

procedure restore-s-trn-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-trn-doc). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    {&init-validation}

    &scoped-define sequence-name   s-trn-doc

    &scoped-define table-name      trn-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      rvs-doc
    &scoped-define seq-field-name  rvs-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      price-doc
    &scoped-define seq-field-name  doc-num
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      icnt-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      fbr-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .

    {&validate-sequence}
    &scoped-define table-name      parts-attr
    &scoped-define seq-field-name  in-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      cli-gds
    &scoped-define seq-field-name  in-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}


    &scoped-define table-name      c-trn-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      c-rvs-doc
    &scoped-define seq-field-name  rvs-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc
    &scoped-define seq-field-name  doc-num
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      c-fbr-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-doc */

procedure restore-s-fbr-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-fbr-doc). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    {&init-validation}

    &scoped-define sequence-name   s-fbr-doc

    &scoped-define table-name      fbr-pln
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-doc */

procedure restore-s-fbr-num :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-fbr-num). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    {&init-validation}

    &scoped-define sequence-name   s-fbr-num

    &scoped-define table-name      fbr-history
    &scoped-define seq-field-name  hst-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fbr-num */

procedure restore-s-bank :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-bank

    &scoped-define table-name      rcs-retail1bank
    &scoped-define seq-field-name  bank-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-bank */

procedure restore-s-cli-grp :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-cli-grp

    assign
    v-curr-seq-name  = "{&sequence-name}"
    v-table-name     = "cli-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .

    {&show-action}

    find last restseq.cli-grp no-lock
      use-index pi no-error
    .
    if available restseq.cli-grp then do:
      assign
        v-curr-seq-value = restseq.cli-grp.node-code
      .
    end.
    {&update-sequence}
  end.

end procedure. /* restore-s-cli-grp */

procedure restore-s-fmgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-fm-code as   int64              no-undo .

    &scoped-define sequence-name   s-fmgb-code
    
      find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-fm-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "a":U
        no-error
      .
      if not available restseq.code-range then do:
        find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-fm-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
        .
      end .

      assign
        v-curr-seq-name  = "{&sequence-name}"
        v-curr-recid     = 0
      .  
      if available restseq.code-range then do:
            
    if mode-erprn then do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          run log-error in this-procedure
    (input v-curr-seq-name 
    ,input v-curr-recid 
    ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name ) 
    ,input v-curr-seq-value 
    ). 
      dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value .
    end.
    else do:
      assign
        v-table-name     = "firm"
        v-seq-field-name = "firm-code"
        v-num-rec        = 0
        v-new-seq-value  = 0
      .

      {&show-action}

      if restseq.code-range.stts = "a":U then do:
        run get-max-code ( input "get-m-code":U
                          ,input restseq.code-range.db-num
                          ,input restseq.code-range.range-type
                          ,input restseq.code-range.first-code
                          ,input restseq.code-range.last-code
                          ,input FALSE
                          ,output v-fm-code
                          ).
        assign
          v-curr-seq-value = v-fm-code
        .
        {&update-sequence}
      end.
      else do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          {&update-sequence}
      end.
    end. /* end_of mode not erprn */

      end . /* end_of available restseq.code-range */
  end.

end procedure. /* restore-s-fmgb-code */


procedure restore-s-pngb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-pn-code as   int64              no-undo .

    &scoped-define sequence-name   s-pngb-code
    
    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-pn-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if not available restseq.code-range then do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-pn-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
    end.
        
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-curr-recid     = 0
    .
      if available restseq.code-range then do:
            
    if mode-erprn then do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          run log-error in this-procedure
    (input v-curr-seq-name 
    ,input v-curr-recid 
    ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name ) 
    ,input v-curr-seq-value 
    ). 
      dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value .
    end.
    else do:
      assign
        v-table-name     = "person"
        v-seq-field-name = "psn-code"
        v-num-rec        = 0
        v-new-seq-value  = 0
      .

      {&show-action}

      if restseq.code-range.stts = "a":U then do:
        run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-pn-code
                          ).
        assign
          v-curr-seq-value = v-pn-code
        .
        {&update-sequence}
      end.
      else do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        {&update-sequence}
      end.
    end. /* end_of mode not erprn */

      end . /* end_of available restseq.code-range */
  end.

end procedure. /* restore-s-pngb-code */

procedure restore-s-sclc-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .

    &scoped-define sequence-name   s-sclc-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&loc-sc-code}
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).

      assign
        v-curr-seq-value = v-b-code
      .
      {&update-sequence}
    end.
/*
    else do:
      return error "(rest-seq.p) Нет ни одного активного диапазона локальных весовых кодов" .
    end.
*/

  end.
end procedure. /* restore-s-sclc-code */

procedure restore-s-scgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .

    &scoped-define sequence-name   s-scgb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-sc-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .

    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).

      assign
        v-curr-seq-value = v-b-code
      .
      {&update-sequence}
    end.

  end.

end procedure. /* restore-s-scgb-code */

procedure restore-s-pglc-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .

    &scoped-define sequence-name   s-pglc-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&loc-pg-code}
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).

      assign
        v-curr-seq-value = v-b-code
      .
      {&update-sequence}
    end.
/*
    else do:
      return error "(rest-seq.p) Нет ни одного активного диапазона локальных штучных кодов для весов"  .
    end.
*/

  end.
end procedure. /* restore-s-pglc-code */


procedure restore-s-pmnt-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-pmnt-code

    &scoped-define table-name      payment
    &scoped-define seq-field-name  pmnt-code
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-pmnt-code */

procedure restore-s-gds-grp :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-gds-grp

    assign
    v-curr-seq-name  = "{&sequence-name}"
    v-table-name     = "gds-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .

    {&show-action}

    find last restseq.gds-grp no-lock
      use-index pi no-error
    .

    if available restseq.gds-grp then do:
      assign
        v-curr-seq-value = restseq.gds-grp.node-code
      .
    end.
      {&update-sequence}
      
    {&init-validation}

    &scoped-define sequence-name   s-fbr-grp
    assign
    v-curr-seq-name  = "{&sequence-name}"
    v-table-name     = "fbr-gds-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .

    {&show-action}

    find last restseq.fbr-gds-grp no-lock use-index inodecode
      no-error
    .
    if available restseq.fbr-gds-grp then do:
      assign
        v-curr-seq-value = restseq.fbr-gds-grp.node-code
      .
    end.
    {&update-sequence}
  end.

end procedure. /* restore-s-gds-grp */

procedure restore-s-gds-prt :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then return.


    {&init-validation}

    &scoped-define sequence-name   s-gds-prt

    &scoped-define table-name      gds-prt
    &scoped-define seq-field-name  node-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      gds-prt
    &scoped-define seq-field-name  upper-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-gds-prt */

procedure restore-s-bcgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .

  &scoped-define sequence-name   s-bcgb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "bar-code"
      v-seq-field-name = "b-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-bc-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).
      assign
        v-curr-seq-value = v-b-code
      .
      {&update-sequence}
    end.
/*
    else do:
      return error "(rest-seq.p) Нет ни одного активного диапазона собственных кодов" .
    end.
*/

  end.

end procedure. /* restore-s-bcgb-code */

procedure restore-next-num-filter :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
  /*
  ЖДЕМ ДИМУ
    {&init-validation}

    &scoped-define sequence-name   next-num-filter

    &scoped-define table-name      filter
    &scoped-define seq-field-name  num-flt
    &scoped-define seq-expresstion assign v-new-seq-value = restseqflt.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
    */
  end.

end procedure. /* restore-next-num-filter */

procedure restore-s-user-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-user-id

    &scoped-define table-name      user-account
    &scoped-define seq-field-name  user-id
    &scoped-define not-include-in-seq-records if int64(entry(1, restseq.{&table-name}.{&seq-field-name}, "-") ) <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = int64(entry(2, restseq.{&table-name}.{&seq-field-name}, "-") ).
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-user-id */

procedure restore-s-usr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-usr-chip

    &scoped-define table-name      c-user-account
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-user-login
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records


    {&update-sequence}
  end.

end procedure. /* restore-s-user-id */

procedure restore-s-user-login-action-role :
  define input parameter p-curr-db-num as integer no-undo.
  define buffer buf_global-state for ub.global-state .
  define buffer buf_global-state-attr for ub.global-state-attr .
  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-user-login-action-role

    &scoped-define table-name      user-login-action-role
    &scoped-define seq-field-name  user-login-role-code

   FIND FIRST buf_global-state
        exclusive-LOCK        .
FIND FIRST buf_global-state-attr
    WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
    AND buf_global-state-attr.attr-code = "action-gbl"
    EXCLUSIVE-LOCK
    NO-error
    .
  IF not AVAILABLE buf_global-state-attr or buf_global-state-attr.attr-value <> "yes"
    THEN
  DO:
         &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.

  END.
  else do:
             &scoped-define not-include-in-seq-records .
  end.  

    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-user-login-action-role */

procedure restore-s-menu-user-call :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-menu-user-call

    &scoped-define table-name      menu-user-call
    &scoped-define seq-field-name  menu-user-call-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-user-login-action-role */

procedure restore-s-user-menu-group :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-user-menu-group

    &scoped-define table-name      user-menu-group
    &scoped-define seq-field-name  user-menu-group-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-user-login-action-role */

procedure restore-s-action-post :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-post

    &scoped-define table-name      action-post
    &scoped-define seq-field-name  action-post-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-action-post */

procedure restore-s-action-post-menu-group :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-post-menu-group

    &scoped-define table-name      action-post-menu-group
    &scoped-define seq-field-name  action-post-menu-group-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-as-ction-post-menu-group */

procedure restore-s-action-post-role :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-post-role

    &scoped-define table-name      action-post-role
    &scoped-define seq-field-name  action-post-role-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-action-post-role */

procedure restore-s-action-role :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-role

    &scoped-define table-name      action-role
    &scoped-define seq-field-name  action-role-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-action-role */

procedure restore-s-action-role-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-role-chip

    &scoped-define table-name      c-action-role-item
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-action-role
    &scoped-define seq-field-name  action-role-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-action-role-chip */
procedure restore-s-action-role-item :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-action-role-item

    &scoped-define table-name      action-role-item
    &scoped-define seq-field-name  action-role-item-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-action-role-item */

procedure restore-s-alc-sale-lic :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-sale-lic

    &scoped-define table-name      alc-sale-lic
    &scoped-define seq-field-name  alc-sale-lic-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.create-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-sale-lic */

procedure restore-s-alc-supp-lic :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-supp-lic

    &scoped-define table-name      alc-supp-lic
    &scoped-define seq-field-name  alc-supp-lic-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.create-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-supp-lic */

procedure restore-s-alc-type :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-type

    &scoped-define table-name      alc-type
    &scoped-define seq-field-name  alc-type-inner-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.create-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-type */

procedure restore-s-cd-events-log :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-cd-events-log

    &scoped-define table-name      cd-event-log
    &scoped-define seq-field-name  trans-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-type */

procedure restore-s-alc-type-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-type-chip

    &scoped-define table-name      c-alc-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-type-gds
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-type-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-type-chip */

procedure restore-s-alc-sale-lic-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-sale-lic-chip

    &scoped-define table-name      c-alc-sale-lic
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-sale-lic-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-sale-lic-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-sale-lic-chip */

procedure restore-s-alc-supp-lic-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-alc-supp-lic-chip

    &scoped-define table-name      c-alc-supp-lic
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-supp-lic-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    &scoped-define table-name      c-alc-supp-lic-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-alc-supp-lic-chip */

procedure restore-s-btpr :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-btpr

    &scoped-define table-name      BatchProcess
    &scoped-define seq-field-name  BatchProcess#
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.BatchProcess.BatchProcess# .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-btpr */

procedure restore-next-rep-num :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   next-rep-num

    &scoped-define table-name      rep
    &scoped-define seq-field-name  rep-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-next-rep-num */

procedure restore-s-recipe :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-recipe

    &scoped-define table-name      recipe
    &scoped-define seq-field-name  recipe-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-recipe */

procedure restore-s-ord-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ord-doc

    &scoped-define table-name      ord-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-ord-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      ord-doc-rcv
    &scoped-define seq-field-name  rcv-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      ord-cons
    &scoped-define seq-field-name  cons-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      ord-chain
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}

  end.

end procedure. /* restore-s-ord-doc */

procedure restore-s-ord-ch :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ord-ch

    &scoped-define table-name      ord-chain
    &scoped-define seq-field-name  rel-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}

  end.

end procedure. /* restore-s-ord-doc */


procedure restore-s-ord-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ord-fact

    &scoped-define table-name      ord-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ord-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      ord-doc-rcv
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      ord-cons
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    {&update-sequence}

  end.

end procedure. /* restore-s-ord-fact */


procedure restore-s-wth-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-wth-doc

    &scoped-define table-name      wth-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-doc */

procedure restore-s-wth-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-wth-fact

    &scoped-define table-name      wth-doc
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-fact */

procedure restore-s-wth-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-wth-code

    &scoped-define table-name      wealth
    &scoped-define seq-field-name  wth-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-code */

procedure restore-s-par-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-par-code

    &scoped-define table-name      wth-par
    &scoped-define seq-field-name  par-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-par-code */


procedure restore-s-wth-ser :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-wth-ser

    &scoped-define table-name      wth-ser
    &scoped-define seq-field-name  ser-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-ser */

procedure restore-s-wth-place :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-wth-place

    &scoped-define table-name      wth-place
    &scoped-define seq-field-name  w-p-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-place */


procedure restore-s-dcgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-dc-code as   int64              no-undo .

    &scoped-define sequence-name   s-dcgb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "dis-card"
      v-seq-field-name = "card-num"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-dc-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dc-code
                        ).
      assign
        v-curr-seq-value = v-dc-code
      .
      {&update-sequence}
    end.

  end.
end procedure. /* restore-s-dcgb-code */

procedure restore-s-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-corr-chip

    &scoped-define table-name      c-price-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-inkas
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fbr-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-rvs-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-trn-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-wth-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-bank
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-schet
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-ob
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-doc-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      c-group-period-validity
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-tax-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-cash-pay
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-condition-keeping
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-deliv-type-cond-keep
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-delivery-subject
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-delivery-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-delivery-type-subject
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-var-deliv-gr-per-val
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-variant-delivery
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ord-doc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-code-an-uchet
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-code-cel-nazn
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fin-code-cor-acc
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ex-mark
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-contract
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-corr-chip */

procedure restore-s-fbr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-fbr-chip

    &scoped-define table-name      c-recipe
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-recipe-gds
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-recipe-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-fbr-chip */

procedure restore-s-gds-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-gds-chip

    &scoped-define table-name      c-gds-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-table-bind
    &scoped-define seq-field-name  chip-num-rec
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-gds-chip */


procedure restore-s-cli-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-cli-chip

    &scoped-define table-name      c-cli-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-thbj-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-thbj-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-clients-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-clients
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-firm
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-person
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-dis-some-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-dis-thbj-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-ext-classif
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-shop
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-staff
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-store
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-sysconf
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-cli-chip */

procedure restore-s-dc-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-dc-chip

    &scoped-define table-name      c-dis-card
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-card-property
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-dc-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-obj
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-host
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dc-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-card-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-card-type-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-card-mask
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-time-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-dct-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-dc-chip */

procedure restore-s-scales-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-scales-chip

    &scoped-define table-name      c-scales
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-fbr-prn
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-scales-chip */


procedure restore-s-cash-desk-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-cash-desk-chip

    &scoped-define table-name      c-cash-desk
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-cash-desk-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-cash-desk-chip */


procedure restore-s-curr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-curr-chip

    &scoped-define table-name      c-currency
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-curr-accnt
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-curr-bank
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-curr-chip */

procedure restore-s-wth-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-wth-chip

    &scoped-define table-name      c-wth-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-wth-place
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-wth-chip */


procedure restore-s-task-num :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-task-num

    &scoped-define table-name      schedule
    &scoped-define seq-field-name  task-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.cre-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-task-num */

procedure restore-s-nws-hist :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-nws-hist

    &scoped-define table-name      nws-doc-hist
    &scoped-define seq-field-name  ord-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-nws-hist */

procedure restore-s-fin-bank :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-fin-bank

    &scoped-define table-name      fin-bank
    &scoped-define seq-field-name  code-bank
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name}.
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-bank */

procedure restore-s-fin-ob :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-ob

    &scoped-define table-name      fin-ob
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      fin-ob-before
    &scoped-define seq-field-name  before-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-ob */

procedure restore-s-fin-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-code

    &scoped-define table-name      fin-code-an-uchet
    &scoped-define seq-field-name  fin-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      fin-code-cel-nazn
    &scoped-define seq-field-name  fin-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      fin-code-cor-acc
    &scoped-define seq-field-name  fin-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    {&update-sequence}

  end.

end procedure. /* restore-s-fin-code */

procedure restore-s-fin-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-fd-code as   int64              no-undo .

    &scoped-define sequence-name   s-fin-doc
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "fin-doc"
      v-seq-field-name = "fin-doc-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-fd-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-fd-code
                        ).
      assign
        v-curr-seq-value = v-fd-code
      .
    {&update-sequence}
  end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-fd-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        {&update-sequence}

      end.
    end.
  end.
end procedure. /* restore-s-fin-doc */

procedure restore-s-fin-sttm :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-sttm

    &scoped-define table-name      fin-statement
    &scoped-define seq-field-name  sttm-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-sttm */



procedure restore-s-fin-ob-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-ob-fact

    &scoped-define table-name      fin-ob
    &scoped-define seq-field-name  fact-order
    &scoped-define seq-expresstion run factord-to-fact-num in this-procedure (restseq.{&table-name}.{&seq-field-name}, output v-new-seq-value)  .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-fact */


procedure restore-s-fin-doc-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-doc-fact

    &scoped-define table-name      fin-doc
    &scoped-define seq-field-name  fact-order
    &scoped-define seq-expresstion run factord-to-fact-num in this-procedure (restseq.{&table-name}.{&seq-field-name}, output v-new-seq-value)  .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-doc-fact */

procedure restore-s-fin-sttm-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-sttm-fact

    &scoped-define table-name      fin-statement
    &scoped-define seq-field-name  fact-order
    &scoped-define seq-expresstion run factord-to-fact-num in this-procedure (restseq.{&table-name}.{&seq-field-name}, output v-new-seq-value)  .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-sttm-fact */


procedure restore-s-ctgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-dc-code as   int64              no-undo .

    &scoped-define sequence-name   s-ctgb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "contract"
      v-seq-field-name = "contract-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-ct-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dc-code
                        ).
      assign v-curr-seq-value = v-dc-code .
      {&update-sequence}
    end.
  end.
end procedure. /* restore-s-ctgb-code */


procedure restore-s-chip-contract-specif :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-chip-contract-specif

    &scoped-define table-name      c-contract-specif
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.
end procedure. /* restore-s-chip-contract-specif */



procedure restore-s-sf-doc :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-sf-doc

    &scoped-define table-name      schet-fact-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-f-doc */



procedure restore-s-fin-connect :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-connect

    &scoped-define table-name      fin-connect
    &scoped-define seq-field-name  connect-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      factur-connect
    &scoped-define seq-field-name  connect-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-connect */


procedure restore-s-fin-schet :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-fin-schet

    &scoped-define table-name      fin-schet
    &scoped-define seq-field-name  code-schet
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-schet */


procedure restore-s-place-io :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-place-io
    &scoped-define table-name      place-io
    &scoped-define seq-field-name  place-io-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-place-io */

procedure restore-s-chip-place-io :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-chip-place-io
    &scoped-define table-name      c-place-io
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.
end procedure. /* restore-s-chip-place-io */

procedure restore-s-point-io :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-point-io
    &scoped-define table-name      point-io
    &scoped-define seq-field-name  point-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-place-io */

procedure restore-s-chip-point-io :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-chip-point-io
    &scoped-define table-name      c-point-io
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.
end procedure. /* restore-s-chip-place-io */



procedure restore-delivery :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   delivery

    &scoped-define table-name      group-period-validity
    &scoped-define seq-field-name  gr-per-val-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      condition-keeping
    &scoped-define seq-field-name  cond-keep-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      delivery-type
    &scoped-define seq-field-name  deliv-type-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      delivery-subject
    &scoped-define seq-field-name  deliv-subj-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-delivery */

procedure restore-s-gds-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-gds-grp-chip

    &scoped-define table-name      c-gds-grp-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-gds-grp-chip */

procedure restore-s-cli-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-cli-grp-chip

    &scoped-define table-name      c-cli-grp
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-gds-grp-chip */


procedure restore-s-drgb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-dr-code as   int64              no-undo .

    &scoped-define sequence-name   s-drgb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "dis-rule"
      v-seq-field-name = "rule-num"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-dr-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dr-code
                        ).
      assign
        v-curr-seq-value = v-dr-code
      .
      {&update-sequence}
    end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-dr-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        {&update-sequence}

      end.
    end.
  end.

end procedure. /* restore-s-gds-grp-chip */


procedure restore-s-file-num-2 :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-file-num-2

    &scoped-define table-name      cd-grp
    &scoped-define seq-field-name  grp-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name}.
    &scoped-define not-include-in-seq-records if index(restseq.cd-grp.grp-type, 'session') = 0 then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    &scoped-define table-name      cd-grp
    &scoped-define seq-field-name  grp-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name}.
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-file-num-2 */

procedure restore-s-ext-system :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-ext-system

    &scoped-define table-name      ext-system
    &scoped-define seq-field-name  esys-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-ext-system */

procedure restore-s-asmt :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-asmt

    &scoped-define table-name      assortment-matrix
    &scoped-define seq-field-name  asmt-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      abc-analysis
    &scoped-define seq-field-name  abc-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      xyz-analysis
    &scoped-define seq-field-name  xyz-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      abcxyz-analysis
    &scoped-define seq-field-name  abcx-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}



    {&update-sequence}
  end.

end procedure. /* restore-s-asmt */

procedure restore-s-news-ord :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-news-ord
    &scoped-define table-name      route
    &scoped-define seq-field-name  tbl-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define sequence-name   s-news-ord
    &scoped-define table-name      esys-route
    &scoped-define seq-field-name  esr-tbl-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    {&update-sequence}
  end.
end procedure. /* restore-s-news-ord */

procedure restore-s-news-dord :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-news-dord
    &scoped-define table-name      route-dump
    &scoped-define seq-field-name  dump-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define sequence-name   s-news-dord
    &scoped-define table-name      route
    &scoped-define seq-field-name  dump-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define sequence-name   s-news-dord
    &scoped-define table-name      esys-route
    &scoped-define seq-field-name  esr-dump-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-news-dord */

procedure restore-s-fin-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-fin-corr-chip

    &scoped-define table-name      c-fin-statement
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      c-fin-statement-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-fin-corr-chip */


procedure restore-s-ref-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ref-corr-chip

    &scoped-define table-name      c-auto-tank
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-country
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-dis-cfg-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-prop-head
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-prop-ref
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-prop-ruleset
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-prop-script
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-pscript-ruleset
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ext-classif
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-rule-profile
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-rule-process
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      c-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ruledict
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ruleset
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-gds-prt
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-pay-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-sum-grp
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-units
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-ext-system
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-layout-elem
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-wi-mode
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-dis-grp-rule
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-hist-nws-option
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-layout
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-profile-by-profile
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rp-by-call
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rp-rule-param
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rule-by-call
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rule-by-profile
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rule-by-set
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-rule-call-param
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-ruledict-param
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-sr-izmerenia
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-stop-list
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    
    &scoped-define table-name      c-tare
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-ref-corr-chip */

procedure restore-s-ref-obj-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ref-obj-corr-chip

    &scoped-define table-name      c-assortment-matrix
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      c-sum-grp-obj
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-ref-obj-corr-chip */



procedure restore-s-plc-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-plc-chip

    &scoped-define table-name      c-plc-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-plc-chip */


procedure restore-s-pmp-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-pmp-chip

    &scoped-define table-name      c-pmp-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &scoped-define table-name      c-pump-nozzle
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &scoped-define table-name      c-pump-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &scoped-define table-name      c-pump
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-pmp-chip */


procedure restore-s-nzl-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-nzl-chip

    &scoped-define table-name      c-nzl-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &scoped-define table-name      c-nozzle-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &scoped-define table-name      c-nozzle
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}

  end.

end procedure. /* restore-s-nzl-chip */


procedure restore-s-fbr-gds-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-fbr-gds-grp-chip

    &scoped-define table-name      c-fbr-gds-grp-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-fbr-gds-grp-chip */


procedure restore-s-shift-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-shift-chip

    &scoped-define table-name      c-sht-hist
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-shift-chip */


procedure restore-s-sert-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-sert-chip

    &scoped-define table-name      c-sert
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-sert-chip */

procedure restore-s-rule-profile :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.

    {&init-validation}

    &scoped-define sequence-name   s-rule-profile

    &scoped-define table-name      rule-profile
    &scoped-define seq-field-name  profile_id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-rule-profile */


procedure restore-s-rule-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.

    {&init-validation}

    &scoped-define sequence-name   s-rule-id

    &scoped-define table-name      rule
    &scoped-define seq-field-name  rule_id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-rule-id */

procedure restore-s-rule-script-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.

    {&init-validation}

    &scoped-define sequence-name   s-rule-script-id

    &scoped-define table-name      rule-script
    &scoped-define seq-field-name  script_id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-rule-script-id */

procedure restore-s-cagb-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-ca-code as   int64              no-undo .

    &scoped-define sequence-name   s-cagb-code
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "rule-by-call"
      v-seq-field-name = "call#_id"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find restseq.code-range no-lock
      where restseq.code-range.range-type = {&gbl-ca-code}
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-ca-code
                        ).
      assign
        v-curr-seq-value = v-ca-code
      .
      {&update-sequence}
    end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = {&gbl-ca-code}
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        {&update-sequence}

      end.
    end.
  end.

end procedure. /* restore-s-cagb-code */


procedure restore-s-hn-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.

    {&init-validation}

    &scoped-define sequence-name   s-hn-id

    &scoped-define table-name      hist-nws-option
    &scoped-define seq-field-name  hn-id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-rule-profile */


procedure restore-s-cfg-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-cfg-chip

    &scoped-define table-name      c-config
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-cfg-chip */

procedure restore-s-ex-mark :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-ex-mark

    &scoped-define table-name      ex-mark
    &scoped-define seq-field-name  mark-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-cfg-chip */

procedure restore-s-chip-mp :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-chip-mp

    &scoped-define table-name      c-global-state
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-global-state-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-sum-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-sum-in-sum-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-qnty-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-qnty-in-qnty-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-turnover-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-tnv-in-turnover-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-buyer-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-buyer-in-buyer-group
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type-pay-type
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type-cassa
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type-gds-grp
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-list-type-cash-pay
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming-attr
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming-gds
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming-gds-qnty
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming-gds-sum
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-price-doc-forming-gds-tnv
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-curr-chip */

procedure restore-s-bgr :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-bgr

    &scoped-define table-name      buyer-group
    &scoped-define seq-field-name  bgr-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.bgr-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-bgr */

procedure restore-s-gop :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-gop
    &scoped-define table-name      grp-obj-price
    &scoped-define seq-field-name  gop-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.gop-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-gop */

procedure restore-s-pal :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-pal
    &scoped-define table-name      price-all
    &scoped-define seq-field-name  pal-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.pal-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-pal */

procedure restore-s-pdf :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-pdf
    &scoped-define table-name      price-doc-forming
    &scoped-define seq-field-name  pdf-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.pdf-db <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-pdf */

procedure restore-s-plt :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-plt
    &scoped-define table-name      price-list-type
    &scoped-define seq-field-name  plt-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.plt-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-plt */

procedure restore-s-qgr :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}
    &scoped-define sequence-name   s-qgr

    &scoped-define table-name      sum-group
    &scoped-define seq-field-name  sgr-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.sgr-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      qnty-group
    &scoped-define seq-field-name  qgr-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.qgr-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      turnover-group
    &scoped-define seq-field-name  tog-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.tog-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-qgr */

procedure restore-s-lk-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-lk-chip


    &scoped-define table-name      some-lk
    &scoped-define seq-field-name  resource#_id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      who-lk
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-lk-chip */


procedure restore-s-region :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-region

    &scoped-define table-name      c-region
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-region */

procedure restore-s-stop-list :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-stop-list

    &scoped-define table-name      stop-list
    &scoped-define seq-field-name  stop-list-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}

    &scoped-define table-name      c-stop-list
    &scoped-define seq-field-name  stop-list-code
    &scoped-define seq-expresstion assign v-new-seq-value = get-doc-code-int64(restseq.{&table-name}.{&seq-field-name}) .
    {&validate-sequence}


    {&update-sequence}
  end.

end procedure. /* restore-s-stop-list */


procedure restore-s-stop-list-fact :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-stop-list-fact

    &scoped-define table-name      stop-list
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &scoped-define table-name      c-stop-list
    &scoped-define seq-field-name  fact-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}



    {&update-sequence}
  end.

end procedure. /* restore-s-stop-list-fact */


procedure restore-s-casm :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-casm

    &scoped-define table-name      season
    &scoped-define seq-field-name  sea-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &scoped-define table-name      c-season
    &scoped-define seq-field-name  sea-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    {&update-sequence}
  end.

end procedure. /* restore-s-casm */

procedure restore-s-trn-fo :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-trn-fo

    &scoped-define table-name      fin-ob-trn
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-fo */

procedure restore-s-trn-reason :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-trn-reason

    &scoped-define table-name      trn-reason
    &scoped-define seq-field-name  reason-code
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-trn-reason */

procedure restore-s-cd-trans :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-cd-trans

    &scoped-define table-name      cd-trans
    &scoped-define seq-field-name  trans-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records
    {&update-sequence}
  end.

end procedure. /* restore-s-cd-trans */



procedure restore-s-spool :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    define variable v-spool as   int64              no-undo .

  &scoped-define sequence-name   s-spool
    assign
      v-curr-seq-name  = "{&sequence-name}"
      v-table-name     = "spool"
      v-seq-field-name = "spool"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .

    {&show-action}

    find first restseq._sequence no-lock
    where restseq._sequence._seq-name = v-curr-seq-name
    no-error.

    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) >=  restseq._sequence._seq-max then do:
      assign
        v-curr-seq-value = 1
      .
      {&update-sequence}
    end.
/*
    else do:
      return error "(rest-seq.p) Нет ни одного активного диапазона собственных кодов" .
    end.
*/



  end.

end procedure. /* restore-s-spool */

procedure restore-s-blob-int64 :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-blob-int64

    &scoped-define table-name      blob-data
    &scoped-define seq-field-name  int64-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-corr-chip */

procedure restore-s-clob-int64 :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-clob-int64

    &scoped-define table-name      clob-data
    &scoped-define seq-field-name  int64-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}


    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-corr-chip */

procedure restore-s-upg-ord :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-upg-ord

    &scoped-define table-name      upgrade
    &scoped-define seq-field-name  version-ord
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-upg-ord */

procedure restore-s-egais :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error return-value
  :
    {&init-validation}

    &scoped-define sequence-name   s-egais

    &scoped-define table-name      c-egais-clients
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    &scoped-define table-name      c-egais-gds
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-egais */


procedure restore-s-layout-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error substitute( "&1 (restore-s-layout-id). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

    {&init-validation}

    &scoped-define sequence-name   s-layout-id

    &scoped-define table-name      layout
    &scoped-define seq-field-name  layout-id
    &scoped-define not-include-in-seq-records if int64(restseq.{&table-name}.cr-db-num) <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = get-layout-id-int64(p-curr-db-num, restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-layout
    &scoped-define seq-field-name  layout-id
    &scoped-define not-include-in-seq-records if int64(restseq.{&table-name}.cr-db-num) <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = get-layout-id-int64(p-curr-db-num, restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-layout-id */

procedure restore-s-db-chip :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :


    {&init-validation}

    &scoped-define sequence-name   s-db-chip

    &scoped-define table-name      c-db
    &scoped-define seq-field-name  chip-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.corr-user-db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.

end procedure. /* restore-s-user-id */

procedure restore-s-sost :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-sost

    &scoped-define table-name      ext-file
    &scoped-define seq-field-name  file-num
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.from-db-num <> p-curr-db-num then next. if restseq.{&table-name}.file-num = 2147483647 then next.
    &scoped-define seq-expresstion assign v-new-seq-value = abs(restseq.{&table-name}.{&seq-field-name} ).
    {&validate-sequence}
    &undefine not-include-in-seq-records
    {&update-sequence}
  end.

end procedure. /* restore-s-sost */

procedure restore-s-sr-izmerenia :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-sr-izmerenia

    &scoped-define table-name      sr-izmerenia
    &scoped-define seq-field-name  node-code
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-sr-izmerenia */

procedure restore-s-norm-loss :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define sequence-name   s-norm-loss

    &scoped-define table-name      norm-loss
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.

end procedure. /* restore-s-sr-izmerenia */

procedure restore-s-gds-mercury-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-gds-mercury-id

    &scoped-define table-name      gds-mercury
    &scoped-define seq-field-name  id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.
 end procedure. /* restore-s-gds-mercury-id  */ 
  procedure restore-s-vsd-id :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-vsd-id

    &scoped-define table-name      vsd
    &scoped-define seq-field-name  id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}
    &undefine not-include-in-seq-records

    {&update-sequence}
  end.
end procedure. /* restore-s-vsd-id */

&scoped-define sequence-name s-promo-chip
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-PromoAction
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-PromoCriterion
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-PromoGift
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-PromoGoods
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-PromoObject
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-promo-schedule
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-promo-schedule-week
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}
    
    {&update-sequence}
  end.
end procedure. /* restore-s-promo-chip */
&scoped-define sequence-name s-promoaction-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define table-name      PromoAction
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    
    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-promoaction-id */
&scoped-define sequence-name s-promoCriterion-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define table-name      PromoCriterion
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-promoCriterion-id */
&scoped-define sequence-name s-promoGift-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define table-name      PromoGift
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-promoGift-id */
&scoped-define sequence-name s-promoGoods-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define table-name      PromoGoods
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-promoGoods-id */
&scoped-define sequence-name s-promoobject-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define table-name      PromoObject
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

    {&validate-sequence}
    {&update-sequence}
  end.
end procedure. /* restore-s-promoobject-id */
&scoped-define sequence-name s-tech-prol-pwd
procedure restore-{&sequence-name} :
    define input parameter p-curr-db-num as integer no-undo.

    do
        on error undo, return error
        :
        {&init-validation}

    &scoped-define table-name      tech-prol-pwd
    &scoped-define seq-field-name  id
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

        {&validate-sequence}
        {&update-sequence}
    end.
end procedure. /* restore-s-tech-prol-pwd */

&scoped-define sequence-name s-c-tech-prol-pwd_chip-num
procedure restore-{&sequence-name} :
    define input parameter p-curr-db-num as integer no-undo.

    do
        on error undo, return error
        :
        {&init-validation}

    &scoped-define table-name      c-tech-prol-pwd
    &scoped-define seq-field-name  chip-num
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .

        {&validate-sequence}
        {&update-sequence}
    end.
end procedure. /* restore-s-tech-prol-pwd */
&scoped-define sequence-name s-promosched-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}
    &scoped-define seq-field-name  id

    &scoped-define table-name      promo-schedule
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      promo-schedule-week
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}
    
    {&update-sequence}
  end.
end procedure. /* restore-s-promosched-id */

&scoped-define sequence-name s-c-cashbook-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-cashbook
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-cashbookattr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-cashbookrule
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-cashbookruleattr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-cashbook-chip-num */

&scoped-define sequence-name s-cashbook-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  id
    
    &scoped-define table-name      cashbook
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-cashbook-id */

&scoped-define sequence-name s-c-operserv-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-operserv
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-operservattr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-operserv-chip-num */



&scoped-define sequence-name s-c-counter-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-counter
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-operserv-chip-num */

&scoped-define sequence-name s-operserv-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  id
    
    &scoped-define table-name      operserv
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-operserv-id */

&scoped-define sequence-name s-devisPC-id
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  id
    
    &scoped-define table-name      devisPC
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-operserv-id */

procedure restore-s-utd-doc-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-utd-doc-code

    &scoped-define table-name      utd
    &scoped-define seq-field-name  doc-id
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records
    {&update-sequence}
  end.
end procedure.

&scoped-define sequence-name s-c-utd-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-utd
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-err
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-lines
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-marking-lines
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-err-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-lines-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-marking-lines-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-utd-head
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-cashbook-chip-num */

&scoped-define sequence-name s-c-code
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-Code
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-operserv-id */


&scoped-define sequence-name s-c-mark-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-marking
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-mark-chip-num */


&scoped-define sequence-name s-c-mark-attr-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-counter
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-mark-chip-num */

procedure restore-s-order-code :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :

    {&init-validation}

    &scoped-define sequence-name   s-order-code

    &scoped-define table-name      order-doc
    &scoped-define seq-field-name  doc-code
    &scoped-define not-include-in-seq-records if restseq.{&table-name}.db-num <> p-curr-db-num then NEXT.
    &scoped-define seq-expresstion assign v-new-seq-value = restseq.{&table-name}.{&seq-field-name} .
    {&validate-sequence}

    &undefine not-include-in-seq-records
    {&update-sequence}
  end.
end procedure.

&scoped-define sequence-name s-c-order-chip-num
procedure restore-{&sequence-name} :
  define input parameter p-curr-db-num as integer no-undo.

  do
  on error undo, return error
  :
    {&init-validation}

    &scoped-define seq-field-name  chip-num
    
    &scoped-define table-name      c-order-doc
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-order-line
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-order-doc-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-order-line-attr
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    &scoped-define table-name      c-order-head
    &scoped-define seq-expresstion assign v-new-seq-value = int64(restseq.{&table-name}.{&seq-field-name}) no-error .
    {&validate-sequence}

    {&update-sequence}
  end.
end procedure. /* restore-s-c-order-chip-num */
