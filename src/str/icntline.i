/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание строки временной таблицы для документа измренеия погрешности ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/22/07
Author: Bakhtadze Natalya
Creation date: 07/22/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ str/findtank.i }

procedure add-icnt-line-err :
define input parameter p-mode as character no-undo .
define input parameter p-chk-doc-code as character no-undo .
define input parameter p-icnt-doc-code as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input-output parameter p-ptrlcheck as character no-undo .
define parameter buffer buf_tt-icnt-line for tt-icnt-line.
define variable v-pump-code as integer no-undo .
define variable v-nozzle-code as integer no-undo .
define variable v-pl-code as integer no-undo .
define variable v-loc1-code as character no-undo .
define variable v-gds-code as integer no-undo .
define variable v-recid-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-exist as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_bar-code for ub.bar-code.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode <> {&add-def} then do:
    find first buf_icnt-doc exclusive-lock where
              buf_icnt-doc.doc-code = p-icnt-doc-code no-error.
    if not available buf_icnt-doc then do:
      undo main-block, return error
      substitute( "Не найден документ измерения погрешности счетчиков ТРК с номером &1"
                    , p-icnt-doc-code
                    ).
    end.
    if buf_icnt-doc.doc-type <> {&icnt-err} then do:
      undo main-block, return error
      substitute( "Документ измерения погрешности счетчиков ТРК с номером &2 имеет неверный тип &3"
                    , p-icnt-doc-code
                    , buf_icnt-doc.doc-type
                    ).
    end.
    for each buf_chk-doc no-lock where
            buf_chk-doc.out-2-code = p-icnt-doc-code:
      p-ptrlcheck = p-ptrlcheck + (if p-ptrlcheck = '':U then '':U else {&comma-char}) + buf_chk-doc.doc-code.
    end.
  end.
  find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = p-chk-doc-code no-error.
  if not available buf_chk-doc then do:
    undo main-block, return error
    substitute( "Не найден чек техпролива с номером &1"
                  , p-chk-doc-code
                  ).
  end.
  if buf_chk-doc.chk-type <> integer({&rcpt-tech-refuell}) then do:
    undo main-block, return error
    substitute( "Чек с номером &1 имеет тип отличный от типа ТЕХПРОЛИВ"
                  , p-chk-doc-code
                  ) .

  end.
  if buf_chk-doc.office <> {&gds-goods}
  and buf_chk-doc.office <> {&gds-office} then do:
    undo main-block, return error
    substitute( "Чек с номером &1 - ошибочный - нельзя создать по нему строку док-та измерения погрешности ТРК"
                  , p-chk-doc-code
                  ).
  end.
  if (p-mode = {&add-def}
      and not (buf_chk-doc.obj-type = p-obj-type
              and
              buf_chk-doc.obj-code = p-obj-code))
  or (p-mode = {&update}
      and not (buf_chk-doc.obj-type = buf_icnt-doc.obj-type
              and
              buf_chk-doc.obj-code = buf_icnt-doc.obj-code)) then do:
    undo main-block, return error
    substitute( "Чек с номером &1 принадлежит &2&3, а док-нт измерения погрешности ТРК &4 - &5&6"
                  , p-chk-doc-code
                  , buf_chk-doc.obj-type
                  , buf_chk-doc.obj-code
                  , p-icnt-doc-code
                  , (if p-mode = {&add-def} then p-obj-type else buf_icnt-doc.obj-type)
                  , (if p-mode = {&add-def} then p-obj-code else buf_icnt-doc.obj-code)
                  ).
  end.
  if (p-mode = {&add-def}
      and not buf_chk-doc.chk-date = p-doc-date)
  or (p-mode = {&update}
      and not buf_chk-doc.chk-date = buf_icnt-doc.doc-date)
  then do:
    undo main-block, return error
    substitute( "Чек с номером &1 от &2, а док-нт измерения погрешности ТРК &3 - от &4"
                  , p-chk-doc-code
                  , buf_chk-doc.chk-date
                  , p-icnt-doc-code
                  , (if p-mode = {&add-def} then p-doc-date else buf_icnt-doc.doc-date)
                  ).
  end.
  if p-mode = {&update}
  and buf_chk-doc.doc-code = p-icnt-doc-code then do:
    undo main-block, return error
    substitute( "Чек с номером &1 уже используется данным док-нтом измерения погрешности ТРК &2"
                  , p-chk-doc-code
                  , p-icnt-doc-code
                  ).

  end.
  if buf_chk-doc.out-2-code <> ? then do:
    undo main-block, return error
    substitute( "Чек с номером &1 уже используется док-нтом измерения погрешности ТРК &2"
                  , buf_chk-doc.doc-code
                  , buf_chk-doc.out-2-code
                  ).
  end.

&scop undo-tt    do v-ii = 1 to num-entries(v-recid-list): ~
        find first buf_tt-icnt-line where ~
                  recid(buf_tt-icnt-line) = integer(entry(v-ii, v-recid-list)) . ~
        delete buf_tt-icnt-line. ~
      end

  for each buf_chk-gds no-lock where
        buf_chk-gds.doc-code = buf_chk-doc.doc-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    /*надо найти ТРК пистолет товар*/
    assign
    v-pump-code =  buf_chk-gds.pump
    v-nozzle-code = buf_chk-gds.nozzle-code
    v-loc1-code = buf_chk-gds.loc1
    .
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_chk-gds.b-code no-error.
    if not available buf_bar-code then do:
      {&undo-tt}.
      undo main-block, return error
      substitute( "Чек с номером &1 - ошибочный - не удалось определить товар по бар-коду &2 в строке &3"
                    , p-chk-doc-code
                    , buf_chk-gds.b-code
                    , buf_chk-gds.line-num
                    ).

    end.
    v-gds-code = buf_bar-code.gds-code.
    if v-nozzle-code = 0 then do:
      run findtank in this-procedure ( input buf_chk-doc.obj-type
                                      ,input buf_chk-doc.obj-code
                                      ,input v-pump-code
                                      ,input v-nozzle-code
                                      ,input buf_chk-gds.pl-code
                                      ,input v-gds-code
                                      ,output v-pl-code ) no-error.

      if error-status:error
        or v-pl-code = ?
      then do:
        {&undo-tt}.
        undo main-block, return error
        substitute( "Чек с номером &1 - ошибочный - не удалось определить резервуар для ТРК &2 для товара по бар-коду &3 в строке &4"
                      , p-chk-doc-code
                      , v-pump-code
                      , buf_chk-gds.b-code
                      , buf_chk-gds.line-num
                      ).

      end.
      run find-nzl in this-procedure ( input buf_chk-doc.obj-type
                                      ,input buf_chk-doc.obj-code
                                      ,input v-pump-code
                                      ,input v-gds-code
                                      ,input v-pl-code
                                      ,output v-nozzle-code) no-error.
      if error-status:error then do:
        {&undo-tt}.
        undo main-block, return error
        substitute( "Чек с номером &1 - ошибочный - не удалось определить пистолет на ТРК &2 для товара по бар-коду &3 в строке &4"
                      , p-chk-doc-code
                      , v-pump-code
                      , buf_chk-gds.b-code
                      , buf_chk-gds.line-num
                      ).

      end.
    end.
    find first buf_tt-icnt-line where
              buf_tt-icnt-line.doc-code = p-icnt-doc-code
          and buf_tt-icnt-line.obj-type = p-obj-type
          and buf_tt-icnt-line.obj-code = p-obj-code
          and buf_tt-icnt-line.pump-code = v-pump-code
          and buf_tt-icnt-line.nozzle-code = v-nozzle-code no-error.
    if available buf_tt-icnt-line then do:
      {&undo-tt}.
      undo main-block, return error
      substitute( "Уже есть строка док-та измерения погрешности для ТРК &1, пистолет &2 - нельзя добавить строки из чека &3"
                    , v-pump-code
                    , v-nozzle-code
                    , p-chk-doc-code
                    ).

    end.
    create buf_tt-icnt-line.
    assign
    buf_tt-icnt-line.doc-code = p-icnt-doc-code
    buf_tt-icnt-line.obj-type = p-obj-type
    buf_tt-icnt-line.obj-code = p-obj-code
    buf_tt-icnt-line.pump-code = v-pump-code
    buf_tt-icnt-line.nozzle-code = v-nozzle-code
    buf_tt-icnt-line.gds-code = v-gds-code
    buf_tt-icnt-line.state-el-cnt = buf_chk-gds.doc-qnty
    buf_tt-icnt-line.state-mh-cnt = buf_chk-gds.doc-qnty
    v-recid-list = v-recid-list + (if v-recid-list = '':U
                                   then '':u
                                   else {&comma-char}) +
                   string(recid(buf_tt-icnt-line))
    .
  end. /*for each buf_chk-gds no-lock where*/
  p-ptrlcheck = p-ptrlcheck + (if p-ptrlcheck = '':U then '':U else {&comma-char}) + buf_chk-doc.doc-code.
  buf_chk-doc.out-2-code = '':U.
end.

end procedure. /* add-icnt-line-err */


/* $Workfile$ e n d */