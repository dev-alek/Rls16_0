block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт/изменение клиентов по списку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт/изменение клиентов по списку".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
{ cmp/getmcode.i ub }
{ ref/extclass.i }
{ gbl/key-rec.i }

define variable file-name as character no-undo .
define variable default-cli-grp like ub.cli-grp.node-code no-undo .
define variable mydelimiter as character no-undo.
define variable firm-pars as character no-undo.
define variable person-pars as character no-undo.

define variable log-file-name                as character      no-undo init "process-clients.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .


define stream InStream.
define stream logstream .
define variable ss as char format "X(3000)".
/*для раскладки строчки*/
define variable n-entry as char no-undo extent 40.
/*компоненты строчки*/
/*поля clients*/
define variable my-obj-type like ub.clients.obj-type no-undo.
define variable my-obj-code like ub.clients.obj-code no-undo.
define variable my-obj-name like ub.clients.obj-name no-undo. /*130  40*/
define variable my-reg-code like ub.clients.reg-code no-undo.
define variable my-data-type as character no-undo .

define variable my-parus-2-code as character no-undo .

define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
define variable choice as integer no-undo.
define variable create-client as logical no-undo.
define variable dd as decimal.
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable     f-code      like ub.firm.firm-code no-undo.
define variable     p-code      like ub.person.psn-code no-undo.
define variable my-value as integer no-undo.
define buffer buf-cli-grp for ub.cli-grp.
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable ii as integer.
define variable firm-fields as integer no-undo.
define variable person-fields as integer no-undo.
define variable uniq-method as character no-undo .
define variable dopdec as decimal no-undo.
define variable nen as integer no-undo .
define variable v-correct-inn as logical no-undo .
define variable v-check-dupl as logical no-undo .
define variable v-check-inn-kpp as logical no-undo .
define variable v-return-value as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable intelli-log-file-name as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer another_firm for ub.firm.
define buffer another_person for ub.person.
define buffer buf_ext-classif for ub.ext-classif.
define temp-table temp-firm no-undo like ub.firm.
define temp-table temp-person no-undo like ub.person.
define temp-table temp-clients no-undo like ub.clients.
define temp-table tt0-staff no-undo like ub.staff.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_rule-call-param for tt0-rule-call-param.
{ trg/person1s.i tt0-staff }


&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При импорте информации произошли ошибки!!!'" ~
                    "'process-clients.txt'" ~}   ~
                    return

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-delimiter"
 no-error.
if available buf_rule-call-param then do:
assign mydelimiter = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-uniq-method"
 no-error.
if available buf_rule-call-param then do:
assign uniq-method = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-default-cli-grp"
 no-error.
if available buf_rule-call-param then do:
assign default-cli-grp = buf_rule-call-param.param-value-integer.
end.


assign
file-name            = p-process-file-name.

assign
intelli-log-file-name = substitute("&1.log"
                        ,substring( string( next-value( s-file-num, {&db-name_schema} ), '99999999999999999999'), 13, 8 )).
{ gbl/curdbnum.i v-db-num }
FIND FIRST ub.db WHERE ub.db.db-num = v-db-num NO-LOCK .
if not ub.db.add-client
or NOT g#db-num = 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Импорт клиентов возможен только в ГБД&1и БД, в которых разрешен ввод клиентов", {&new-line})).
  assign
  v-view-log = yes.
  {&view-log}.
end.
  find last buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-firm-fields"
 no-error.
if available buf_rule-call-param then do:
assign firm-fields = buf_rule-call-param.p-index.
end.

  find last buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-person-fields"
 no-error.
if available buf_rule-call-param then do:
assign person-fields = buf_rule-call-param.p-index.
end.


define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

run gbl/filename.p (
                 input  file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .

if error-status:error
or v-full-path = ?
or v-full-path = '':U
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден файл для импорта клиентов&1", file-name)).
  assign
  v-view-log = yes.
  {&view-log}.
end.
define variable v-end-new-line as logical no-undo .
run gbl/filnline.p ( input file-name
                    ,output v-end-new-line) no-error.
if error-status:error
or not v-end-new-line then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при проверке наличия пустой строки в конце файла импорта&1&2"
                         , {&new-line}
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.


assign
file-name = v-full-path.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт клиентов из файла &1", file-name)).

input stream Instream from value(file-name).
_stroka:
REPEAT ON ERROR UNDO, leave:
    empty temp-table temp-clients.
    empty temp-table  temp-firm.
    empty temp-table  temp-person.
    my-seek1 = seek(Instream).
    import stream INstream
    UNFORMATTED
    ss
    .
    num-rec = num-rec + 1.
    my-seek2 = seek(Instream).
    if NUM-entries(ss, mydelimiter)  <> firm-fields AND
       NUM-entries(ss, mydelimiter)  <> person-fields then do:
        my-mess = substitute("Строчка не разобрана!&1" +
                             "количество полей &2 не соответствует выбранному Вами формату c кол-вом полей!"
                             ,{&new-line}
                             ,num-entries(ss, mydelimiter) ).
        if num-rec = 1 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
          {&view-log}.
        end.
        else do:
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
        end.
        next _stroka.
    end.
    do nen = 1 to 40:
      assign
      n-entry[nen] = "":U
      .
    end.
    do nen = 1 to num-entries(ss, mydelimiter):
      assign
      n-entry[nen] = entry(nen, ss, Mydelimiter)
      n-entry[nen] = if index(n-entry[nen], {&double-quote}, 1) = 1
                     AND r-index(n-entry[nen], {&double-quote}, 1) = 1
                     then trim(n-entry[nen], {&double-quote})
                     else n-entry[nen]
      n-entry[nen] = if index(n-entry[nen], {&single-quote}, 1) = 1
                     AND r-index(n-entry[nen], {&single-quote}, 1) = 1
                     then trim(n-entry[nen], {&single-quote})
                     else n-entry[nen]
      .
    end.
    assign
    my-obj-type = n-entry[1]
    .
    if my-obj-type  <> {&cmp} AND my-obj-type <> {&prs} then do:
        my-mess = substitute("Разрешенные значения поля <<ТИП-ОБЪЕКТА>> - &1 или &2"
                             ,{&cmp}
                             ,{&prs}).
        run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
        run err-write in this-procedure ( input-output my-mess).
        next _stroka.
    end.
    assign
    my-obj-code = integer(n-entry[2])
    my-obj-name = n-entry[3]
    no-error
    .
    if error-status:error then do:
      my-mess = substitute("Поле <<КОД КЛИЕНТА>> должно быть неотрицательным целым числом").
      run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
      run err-write in this-procedure ( input-output my-mess).
      next _stroka.
    end.
    CASE my-obj-type:
      when {&cmp} then do:
        create temp-clients.
        assign
        temp-clients.obj-type = {&cmp}
        temp-clients.obj-name = my-obj-name
        temp-clients.obj-code = my-obj-code
        .
        create temp-firm.
        temp-firm.firm-code = my-obj-code.
          if NUM-entries(ss, mydelimiter) <> firm-fields then do:
            my-mess = substitute("Количество полей в строке импорта клиентов типа <<&1>>&2" +
                                 "согласно определенному Вами формату должно быть равно &3"
                                  ,{&cmp}
                                  ,{&new-line}
                                  ,firm-fields).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
      end.
      when {&prs} then do:
        create temp-clients.
        assign
        temp-clients.obj-type = {&prs}
        temp-clients.obj-name = my-obj-name
        temp-clients.obj-code = my-obj-code
        .
        create temp-person.
        temp-person.psn-code = my-obj-code
        .
        if NUM-entries(ss, mydelimiter)  <> person-fields then do:
          my-mess = substitute("Количество полей в строке импорта клиентов типа <<&1>>&2" +
                                "согласно определенному Вами формату должно быть равно "
                              ,{&prs}
                              ,{&new-line}
                              ,person-fields
                              ).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        end.
      end.
    END cASE.
    if my-obj-code = 0 then
    create-client = yes.
    else create-client = no.
    v-check-dupl = no.
    v-check-inn-kpp = no.
    if create-client then do:
      case uniq-method:
        when "obj-name" then do:
          FIND FIRST ub.clients no-lock where
                    ub.clients.obj-name = my-obj-name
                and ub.clients.obj-type = my-obj-type NO-ERROR.
          if avail ub.clients then do:
            if ub.clients.obj-type = {&cmp} then do:
              my-mess = substitute("Уже есть клиент с названием <<&1>>", my-obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
            else do:
              v-check-dupl = yes.
            end.
          end.
        end.
        when "inn+kpp" then do:
          v-check-inn-kpp = yes.
        end.
      end case.
    end.
    CASE my-obj-type:
      WHEN {&cmp} then do:
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character = "firm.tobj-code" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-firm.tobj-code = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<КОД ТОРГОВОГО ПРЕДСТАВИТЕЛЯ>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character = "firm.ind" no-error.
        IF available buf_rule-call-param then do:
          assign
          temp-firm.ind = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<ПОЧТОВЫЙ ИНДЕКС>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        for each  buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character > '':
            case entry(1, buf_rule-call-param.param-value-character, "."):
              when {&table_firm} then do:
                assign
                my-data-type = buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when {&abl-datatype-character} then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when {&abl-datatype-integer} then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-decimal} then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-logical} then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              when {&table_clients} then do:
                assign
                my-data-type = buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when {&abl-datatype-character} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when {&abl-datatype-integer} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-decimal} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-logical} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              otherwise do:
                case entry(2, buf_rule-call-param.param-value-character, "."):
                  when "parus-2-code" then do:
                    my-parus-2-code =  n-entry[buf_rule-call-param.p-index].
                  end.
                end.
              end.
            end case.
        end.
        if v-check-dupl then do:
          for each buf_clients no-lock where
                  buf_clients.obj-type = {&prs}
              and buf_clients.obj-name = my-obj-name,
              first buf_person no-lock where
                    buf_person.psn-code = buf_clients.obj-code :
            if (buf_person.name1 = temp-person.name1
            and buf_person.name2 = temp-person.name2)
            or
              (temp-person.name1 = ''
            and temp-person.name2 = '')
            or
              (buf_person.name1 = ''
            and buf_person.name2 = '')
            or (buf_person.name1 = temp-person.name1
                and
                (temp-person.name2 = ''
                or buf_person.name2 = ''))
            or (buf_person.name2 = temp-person.name2
                and
                (temp-person.name1 = ''
                or buf_person.name1 = '')) then do:
              my-mess = substitute("Уже есть такой &1  или не везде заданы ИМЕНА И ОТЧЕСТВА", temp-clients.obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.

        if v-check-inn-kpp then do:
          if temp-firm.inn + temp-firm.kpp <> '' then do:
            for each another_firm no-lock where
                    another_firm.inn = temp-firm.inn
                and another_firm.kpp = temp-firm.kpp :
                leave.
            end.
            for each another_person no-lock where
                    another_person.inn = temp-firm.inn
                and another_person.kpp = temp-firm.kpp :
                leave.
            end.
            if available another_firm
            or available another_person then do:
              my-mess = substitute("Уже есть клиент с сочетанием {&abbr_inn_allshift}+{&abbr_kpp_allshift}=&1+&2"
                                  , temp-firm.inn
                                  , temp-firm.kpp).
              if available another_firm then do:
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", "орг", another_firm.firm-code, my-parus-2-code, my-mess)).
              end.
              else do:
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", "чел", another_person.psn-code, my-parus-2-code, my-mess)).
              end.
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.

        IF LENGTH(temp-clients.obj-name) > 130 OR
           LENGTH(temp-firm.city) > 23 OR
           temp-firm.ind > 999999 OR
           length(temp-firm.inn) > 21 OR
           length(temp-firm.okonh) > 120 OR
           length(temp-firm.okpo) > 10 OR
           length(temp-firm.kpp) > 9 OR
           length(temp-firm.addres1) > 30 OR
           length(temp-firm.addres2) > 30 OR
           length(temp-firm.post-addr1) > 50 OR
           length(temp-firm.post-addr2) > 50 OR
           length(temp-firm.phone) > 20 OR
           length(temp-firm.phone1-note) > 10 OR
           length(temp-firm.fax) >  20 OR
           length(temp-firm.telex) > 20 OR
           length(temp-firm.e-mail) > 100 OR
           length(temp-firm.director) >  25 OR
           length(temp-firm.contact-psn) > 50 OR
           length(temp-firm.engl-name) > 130 then do:
           assign
           my-mess =  (IF LENGTH(temp-clients.obj-name) > 130 then " поле <<НАЗВАНИЕ>> " else "") +
                      (IF LENGTH(temp-firm.city) > 23 then " поле <<Город>> " else "") +
                      (IF temp-firm.ind > 999999 then " поле <<ПОЧТОВЫЙ ИНДЕКС>> " else "") +
                      (IF length(temp-firm.inn) > 21 then " поле <<{&abbr_inn_allshift}>> " else "") +
                      (IF length(temp-firm.okonh) > 120 then " поле <<{&abbr_okonh_allshift}>> " else "") +
                      (IF length(temp-firm.okpo) > 10 then  " поле <<ОКПО>> " else "") +
                      (IF length(temp-firm.kpp) > 9 then  " поле <<{&abbr_kpp_allshift}>> " else "") +
                      (IF length(temp-firm.addres1) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 1>> " else "") +
                      (IF length(temp-firm.addres2) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 2>> " else "") +
                      (IF length(temp-firm.post-addr1) > 50 then " <<ПОЧТОВЫЙ АДРЕС 1>> " else "") +
                      (IF length(temp-firm.post-addr2) > 50 then " <<ПОЧТОВЫЙ АДРЕС 2>> " else "") +
                      (IF length(temp-firm.phone) > 20 then " <<N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-firm.phone1-note) > 10 then  " <<Примечания к N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-firm.fax) > 20 then " <<N ФАКСА> " else "") +
                      (IF length(temp-firm.telex) > 20 then " <<N ТЕЛЕКСА>> " else "") +
                      (IF length(temp-firm.e-mail) > 100 then " <<E-mail>> " else "") +
                      (IF length(temp-firm.director) >  25 then  " <<Руководитель>> " else "") +
                      (IF length(temp-firm.contact-psn) > 50 then " <<Контактное лицо>> " else "") +
                      (IF length(temp-firm.engl-name) > 140 then  " <<Английское название>> " else "")
          my-mess = "Длина поля " + my-mess + " больше разрешенной"
          .
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END.
       if temp-firm.inn <> "":U then do:
         run gbl/keyinn.p ( input temp-firm.inn, input {&cmp}, input 0, input temp-firm.is-pboul, output v-correct-inn).
          if not v-correct-INN then do:
            assign
            v-return-value = return-value.
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure  ( input-output v-return-value).
            next _stroka.
          end.
       end.
      END. /*WHEN {&cmp}*/
      WHEN {&prs} then do:
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character = "person.firm-code" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-person.firm-code = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<КОД ФИРМЫ>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character = "person.ind" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-person.ind = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<ПОЧТОВЫЙ ИНДЕКС>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        for each  buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character > '':
            case entry(1, buf_rule-call-param.param-value-character, "."):
              when {&table_person} then do:
                assign
                my-data-type = buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when {&abl-datatype-character} then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when {&abl-datatype-integer} then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-decimal} then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-logical} then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              when {&table_clients} then do:
                assign
                my-data-type = buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when {&abl-datatype-character} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when {&abl-datatype-integer} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-decimal} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when {&abl-datatype-logical} then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              otherwise if num-entries(buf_rule-call-param.param-value-character, ".") > 1 then  do:
                case entry(2, buf_rule-call-param.param-value-character, "."):
                  when "parus-2-code" then do:
                    my-parus-2-code =  n-entry[buf_rule-call-param.p-index].
                  end.
                end.
              end.
            end case.
        end.
        if v-check-dupl then do:
          for each buf_clients no-lock where
                  buf_clients.obj-type = {&prs}
              and buf_clients.obj-name = my-obj-name,
              first buf_person no-lock where
                    buf_person.psn-code = buf_clients.obj-code :
            if (buf_person.name1 = temp-person.name1
            and buf_person.name2 = temp-person.name2)
            or
              (temp-person.name1 = ''
            and temp-person.name2 = '')
            or
              (buf_person.name1 = ''
            and buf_person.name2 = '')
            or (buf_person.name1 = temp-person.name1
                and
                (temp-person.name2 = ''
                or buf_person.name2 = ''))
            or (buf_person.name2 = temp-person.name2
                and
                (temp-person.name1 = ''
                or buf_person.name1 = '')) then do:
              my-mess = substitute("Уже есть такой &1  или не везде заданы ИМЕНА И ОТЧЕСТВА", my-obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.
        if v-check-inn-kpp then do:
          if temp-person.inn + temp-person.kpp <> '' then do:
            for each another_firm no-lock where
                    another_firm.inn = temp-person.inn
                and another_firm.kpp = temp-person.kpp :
                leave.
            end.
            for each another_person no-lock where
                    another_person.inn = temp-person.inn
                and another_person.kpp = temp-person.kpp :
                leave.
            end.
            if available another_firm
            or available another_person then do:
              my-mess = substitute("Уже есть клиент с сочетанием {&abbr_inn_allshift}+{&abbr_kpp_allshift}=&1&2"
                                  , temp-person.inn
                                  , temp-person.kpp).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.

        IF LENGTH(my-obj-name) > 40 OR
           LENGTH(temp-person.city) > 23 OR
           temp-person.ind > 999999 OR
           length(temp-person.inn) > 15 OR
           length(temp-person.okonh) > 120 OR
           length(temp-person.okpo) > 10 OR
           length(temp-person.kpp) > 9 OR
           length(temp-person.address) > 30 OR
           length(temp-person.name1) > 20 OR
           length(temp-person.name2) > 20 OR
           length(temp-person.firm-name) > 40 OR
           length(temp-person.phone1) > 20 OR
           length(temp-person.phone1-note) > 10 OR
           length(temp-person.fax) >  20 OR
           length(temp-person.position) > 20 OR
           length(temp-person.e-mail) > 100 OR
           length(temp-person.passp-ser) >  8 OR
           length(temp-person.passp-num) > 18 OR
           length(temp-person.given-by) > 40 then do:
           assign
           my-mess =
                      (IF LENGTH(temp-clients.obj-name) > 40 then " поле <<ФАМИЛИЯ>> " else "") +
                      (IF LENGTH(temp-person.city) > 23 then " поле <<Город>> " else "") +
                      (IF temp-person.ind > 999999 then " поле <<ПОЧТОВЫЙ ИНДЕКС>> " else "") +
                      (IF length(temp-person.inn) > 15 then " поле <<{&abbr_inn_allshift}>> " else "") +
                      (IF length(temp-person.okonh) > 120 then " поле <<{&abbr_okonh_allshift}>> " else "") +
                      (IF length(temp-person.okpo) > 10 then  " поле <<ОКПО>> " else "") +
                      (IF length(temp-person.kpp) > 9 then  " поле <<{&abbr_kpp_allshift}>> " else "") +
                      (IF length(temp-person.address) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 1>> " else "") +
                      (IF length(temp-person.name1) > 20 then "поле <<ИМЯ>> " else "") +
                      (IF length(temp-person.name2) > 20 then " <<ФАМИЛИЯ>> " else "") +
                      (IF length(temp-person.firm-name) > 40 then " <<ОРГАНИЗАЦИЯ>> " else "") +
                      (IF length(temp-person.phone1) > 20 then " <<N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-person.phone1-note) > 10 then  " <<Примечания к N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-person.fax) > 20 then " <<N ФАКСА> " else "") +
                      (IF length(temp-person.position) > 20 then " <<Должность>> " else "") +
                      (IF length(temp-person.e-mail) > 100 then " <<E-mail>> " else "") +
                      (IF length(temp-person.passp-ser) >  8 then  " <<СЕРИЯ ПАСПОРТА>> " else "") +
                      (IF length(temp-person.passp-num) > 18 then " <<N ПАСПОРТА>> " else "") +
                      (IF length(temp-person.given-by) > 40 then  " <<ПАСПОРТ ВЫДАН>> " else "")
          my-mess = "Длина поля " + my-mess + " больше разрешенной"
          .
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END.
       if temp-person.inn <> "":U then do:
         run gbl/keyinn.p ( input temp-person.inn, input {&prs}, input 0, input temp-person.is-pboul, output v-correct-inn).
          if not v-correct-INN then do:
            assign
            v-return-value = return-value.
             run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output v-return-value).
            next _stroka.
          end.
       end.
      END. /*when {*prs}*/
    END CASE.
    if my-parus-2-code <> ''
    and create-client
    then do:
      find first buf_ext-classif no-lock where
                buf_Ext-classif.classif-subject = {&table_Clients}
          and buf_ext-classif.classif-name = {&extclass_clients_parus-2}
          and buf_ext-classif.db-num = -1
          and buf_ext-classif.charkey_one = my-parus-2-code  no-error.
      if available buf_Ext-classif then do:
        my-mess = substitute("Уже есть клиент с кодом клиента &1 в классификаторе ПАРУС-2"
                            , my-parus-2-code
                            ).
        run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
        run err-write in this-procedure ( input-output my-mess).
        next _stroka.
      end.
    end.
    FIND FIRST ub.cli-grp No-LOCK where ub.cli-grp.node-code = default-cli-grp NO-ERROR.
    IF NOT avail ub.cli-grp then do:
      my-mess = substitute("Не найдена группа клиентов с вн.кодом &1", default-cli-grp).
      run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
      run err-write in this-procedure ( input-output my-mess).
      return.
    end.
    IF can-find(FIRST buf-cli-grp No-LOCK WHERE buf-cli-grp.upper-code = default-cli-grp) then do:
     run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
     my-mess = substitute("Выбрана нетерминальная группа клиентов (вн код &1)", cli-grp.node-name).
     run err-write in this-procedure ( input-output my-mess).
     return.
   end.
   DO TRANSACTION ON STOP UNDO, NEXT _stroka ON ERROR UNDO, NEXT _stroka:
    if my-obj-code > 0 then do:
      /*проверим валидность кода клиента*/
      FIND FIRST clients NO-LOCK WHERE
                 clients.obj-type = my-obj-type AND
                 clients.obj-code = my-obj-code No-ERROR.
      IF not avail clients then do:
          create-client  = yes.
/*        if gbclcode-is-this-db-code ( input v-db-num*/
/*                                    ,(if my-obj-type = {&prs} then {&gbl-pn-code} else {&gbl-fm-code})*/
/*                                    ,input my-obj-code) = no then do:*/
/*          my-mess = substitute("Значения кода создаваемого клиента не соответствует&1" +*/
/*                                "используемым диапазонам кодов клиентов для данной БД&1" +*/
/*                                "Импортировать возможно клиентов с кодом из использованных диапазонов&1" +*/
/*                                "или из использованной части активного диапазона"*/
/*                                , {&new-line}).*/
/*          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).*/
/*          run err-write in this-procedure ( input-output my-mess).*/
/*          next _stroka.*/
/*        end.*/
      end.
      else do:
        FIND FIRST CLIENTS EXCLUSIVE-LOCK WHERE
                   CLIENTS.obj-type = my-obj-type AND
                   CLIENTS.obj-code = my-obj-code NO-WAIT No-ERROR.
        IF AVAIL clients then do:
          CASE my-obj-type:
            WHEN {&cmp} then do:
              FIND FIRST ub.firm exclusive-lock WHERE
                         ub.firm.firm-code = my-obj-code No-WAIT NO-ERROR.
              IF NOT AVAIL ub.firm then do:
                my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята!"
                                    ,my-obj-type
                                    ,my-obj-code).
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
                run err-write in this-procedure ( input-output my-mess).
                next _stroka.
              end.
            END.
            WHEN {&prs} then do:
              FIND FIRST ub.person exclusive-lock WHERE
                         ub.person.psn-code = my-obj-code No-WAIT NO-ERROR.
              IF NOT AVAIL ub.person then do:
                my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята!"
                                   ,my-obj-type
                                   ,my-obj-code).
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
                run err-write in this-procedure ( input-output my-mess).
                next _stroka.
              end.
            end.
          END CASE.
          assign
          v-rid = recid(clients).
        END.
        ELSE DO:
          my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята"
                              ,my-obj-type
                              ,my-obj-code).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END. /*if not avail clients frim person excl-lock*/
      end. /* if avail clients no-lock*/

    end. /*my-obj-code > 0 and create-client = no*/
    if create-client then do:
          CASE my-obj-type:
        WHEN {&cmp} then do:
          run ref/firm1.p (
               input parparentproc
              ,input-output v-rid
              ,input {&add-import}
              ,input "cli-all":U
              ,input yes /*p-silent*/
              ,input - abs(my-obj-code) /*генерация уцникального номера внутри*/
              ,input 0
              ,input my-obj-name
              ,input 0 /*p-lim-kr*/
              ,input "":U /*p-PS*/
              ,input default-cli-grp
              ,input temp-firm.addres1
              ,input temp-firm.addres2
              ,input temp-firm.city
              ,input temp-firm.contact-psn
              ,input temp-firm.director
              ,input temp-firm.e-mail
              ,input temp-firm.engl-name
              ,input temp-firm.fax
              ,input temp-firm.given-by
              ,input temp-firm.ind
              ,input temp-firm.inn
              ,input no
              ,input temp-firm.is-pboul
              ,input temp-firm.kpp
              ,input temp-firm.okonh
              ,input temp-firm.okpo
              ,input temp-firm.passp-num
              ,input temp-firm.passp-ser
              ,input temp-firm.phone
              ,input temp-firm.phone1-note
              ,input temp-firm.post-addr1
              ,input temp-firm.post-addr2
              ,input temp-firm.post-city
              ,input temp-firm.post-ind
              ,input temp-clients.reg-code
              ,input temp-firm.telex
              ,input temp-firm.tobj-code
              ,input no /* p-turnover-buyer     */
              ,input no /*p-turnover-buyer-gds */
             ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,{&new-line}
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.

        END.
        WHEN {&prs} then do:
          run ref/person1.p (
              input parparentproc
             ,input this-procedure:handle
             ,input-output v-rid
             ,input {&add-import}
             ,input "cli-all":U
             ,input yes  /*p-silent*/
             ,input - abs(my-obj-code)  /*генерация уникального номера внутри!!!*/
             ,input 0 /*stts*/
             ,input my-obj-name
             ,input 0 /*lim-kr*/
             ,input "":U /*ps*/
             ,input default-cli-grp
             ,input temp-person.address
             ,input temp-person.city
             ,input ? /*date-birth*/
             ,input temp-person.e-mail
             ,input temp-person.fax
             ,input temp-person.firm-code
             ,input temp-person.firm-name
             ,input ? /*gender*/
             ,input temp-person.given-by
             ,input temp-person.ind
             ,input temp-person.inn
             ,input no
             ,input temp-person.is-pboul
             ,input temp-person.kpp
             ,input temp-person.name1
             ,input temp-person.name2
             ,input temp-person.okonh
             ,input temp-person.okpo
             ,input temp-person.passp-num
             ,input temp-person.passp-ser
             ,input temp-person.phone1
             ,input temp-person.phone1-note
             ,input temp-person.position
             ,input temp-person.post-box
             ,input temp-person.post-address
             ,input temp-person.post-city
             ,input temp-person.post-ind
             ,input temp-clients.reg-code
             ,input no /* p-turnover-buyer     */
             ,input no /*p-turnover-buyer-gds */
             ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,{&new-line}
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        END.
      END CASE.
      if my-parus-2-code <> '' then do:
          /*запишем в ПАРУС-2*/
        define variable v-uniq-key-rec as character no-undo .
        find first buf_clients no-lock where
                  recid(buf_clients) = V-RID.
        run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                      ,input (buffer buf_clients:handle)
                                      ,output v-uniq-key-rec).
        define variable v-rid-ext as integer no-undo.
        run ref/extclas1.p ( INPUT {&add-def}
                            ,INPUT yes /*p-silent*/
                            ,INPUT-OUTPUT v-rid-ext
                            ,INPUT {&table_clients} /*p-classif-subject*/
                            ,INPUT {&extclass_clients_parus-2} /*p-classif-name*/
                            ,input (-1) /*p-db-num*/
                            ,input 0 /*p-key#_one*/
                            ,input 0 /*p-Key#_Two*/
                            ,input 0 /*p-key#_Three*/
                            ,input MY-parus-2-CODE /*p-CharKey_One */
                            ,input '':U /*p-CharKey_two */
                            ,input '':U /*p-CharKey_three */
                            ,input 0 /*p-nonunique */
                            ,input v-uniq-key-rec ) no-error.
        if error-status:error then do:
          my-mess = substitute("Не удалось сохранить КОД клиента с типом &1 и кодом &2 ВО КЛАССИФИКАТОРЕ ПАРУС-2&3&4&3&5"
                              ,my-obj-type
                              ,my-obj-code
                              ,{&new-line}
                              , error-status:get-message(1)
                              , return-value).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          undo _stroka, next _stroka.
        end.
      end.
      define variable v-int as integer no-undo .
      run get-max-code in this-procedure
        ( input "f-u":U
        ,input g#db-num
        ,input (if my-obj-type = {&cmp} then {&gbl-fm-code} else {&gbl-pn-code})
        ,input ?
        ,input ?
        ,input TRUE
        ,output v-int
        ).
    end. /*if create-client*/
    else do:
      CASE my-obj-type:
        WHEN {&cmp} then do:
          run ref/firm1.p (
               input parparentproc
              ,input-output v-rid
              ,input {&update}
              ,input "cli-all":U
              ,input yes /*p-silent*/
              ,input clients.obj-code
              ,input clients.stts
              ,input my-obj-name
              ,input clients.lim-kr
              ,input clients.PS
              ,input clients.grp-code
              ,input temp-firm.addres1
              ,input temp-firm.addres2
              ,input temp-firm.city
              ,input temp-firm.contact-psn
              ,input temp-firm.director
              ,input temp-firm.e-mail
              ,input temp-firm.engl-name
              ,input temp-firm.fax
              ,input temp-firm.given-by
              ,input temp-firm.ind
              ,input temp-firm.inn
              ,input no
              ,input temp-firm.is-pboul
              ,input temp-firm.kpp
              ,input temp-firm.okonh
              ,input temp-firm.okpo
              ,input temp-firm.passp-num
              ,input temp-firm.passp-ser
              ,input temp-firm.phone1
              ,input temp-firm.phone1-note
              ,input temp-firm.post-addr1
              ,input temp-firm.post-addr2
              ,input temp-firm.post-city
              ,input temp-firm.post-ind
              ,input temp-clients.reg-code
              ,input temp-firm.telex
              ,input temp-firm.tobj-code
              ,input no /* p-turnover-buyer     */
              ,input no /*p-turnover-buyer-gds */
              ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,{&new-line}
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        END.
        when {&prs} then do:
          run ref/person1.p (
               input parparentproc
              ,input this-procedure:handle
              ,input-output v-rid
              ,input {&update}
              ,input "cli-all":U
              ,input yes  /*p-silent*/
              ,input clients.obj-code
              ,input clients.stts
              ,input my-obj-name
              ,input clients.lim-kr
              ,input clients.PS
              ,input clients.grp-code
              ,input temp-person.address
              ,input temp-person.city
              ,input ? /*date-birth*/
              ,input temp-person.e-mail
              ,input temp-person.fax
              ,input temp-person.firm-code
              ,input temp-person.firm-name
              ,input ? /*gender*/
              ,input temp-person.given-by
              ,input temp-person.ind
              ,input temp-person.inn
              ,input no
              ,input temp-person.is-pboul
              ,input temp-person.kpp
              ,input temp-person.name1
              ,input temp-person.name2
              ,input temp-person.okonh
              ,input temp-person.okpo
              ,input temp-person.passp-num
              ,input temp-person.passp-ser
              ,input temp-person.phone1
              ,input temp-person.phone1-note
              ,input person.position
              ,input temp-person.post-box
              ,input temp-person.post-address
              ,input temp-person.post-city
              ,input temp-person.post-ind
              ,input temp-clients.reg-code
              ,input no /* p-turnover-buyer     */
              ,input no /*p-turnover-buyer-gds */
              ) no-error .
            if error-status:error then do:
              my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                  ,my-obj-type
                                  ,my-obj-code
                                  ,{&new-line}
                                  , error-status:get-message(1)
                                  , return-value).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
        end.
      END CASE.
    end. /*not create*/
  END.
  num-rec-ok = num-rec-ok + 1.
  find first clients no-lock where
            recid(clients) = v-rid.
  run display-intelli-log in this-procedure ( input substitute("&1&2,&3,true,&4", clients.obj-type, clients.obj-code, my-parus-2-code, "OK")).
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END. /*REPEAT*/

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт клиентов из файла &1 завершен: из &2 записей успешно закачано &3&4&5"
                      , file-name
                      , num-rec
                      , num-rec-ok
                      , {&new-line}
                      ,(if lookup("parus-2-code", firm-pars, {&slash-char}) > 0
                        or lookup("parus-2-code", person-pars, {&slash-char}) > 0 then
                        substitute("Дополнительный лог находится в файле &1", intelli-log-file-name)
                        else "")
                      )).
input stream InStream close.
{&view-log}.


PROCEDURE err-write:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  seek STREAM Instream to my-seek1.
  import stream InStream unformatted
  ss.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess + {&new-line} + ss).
  assign
  v-view-log = yes.
  mess = "".
  seek STREAM Instream to my-seek2.
END PROCEDURE.

procedure display-intelli-log :
define input parameter p-mess as character no-undo .

do
on error undo, return error
:
  if lookup("parus-2-code", firm-pars, {&slash-char}) > 0
  or lookup("parus-2-code", person-pars, {&slash-char}) > 0 then do:
    output stream logstream to value(intelli-log-file-name) append.
    put stream logstream unformatted replace(p-mess, {&new-line}, {&space-char})  skip.
    output stream logstream close.
  end.
end.

end procedure. /* display-log */