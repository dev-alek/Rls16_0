block-level on error undo, throw.
/*

$Revision: 6557e99634e7, 3192, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: chkshift.p $
$Archive: str/chkshift.p $

Изменение даты, номера смены или резервуара(для линий в чеке) для одного чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/05
Author: Bakhtadze Natalya
Creation date: 10/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-shift-on as logical no-undo . /*сменная работа BO*/
define input parameter p-chk-rec as recid no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-shift-reservoir-from as int no-undo.
define input parameter p-shift-reservoir-to as int no-undo.
define input parameter p-change-fields as character no-undo .
define input parameter p-can-back-shift as logical no-undo .
define output parameter p-added as logical no-undo .
define output parameter p-changed as logical no-undo. /* если в чеке что-то поменялось, то возвращает true */

/*параметр имеет смысл только для сменной работы в BO*/
/*будет равняться yes если в результате изменения чека он СТАНЕТ ПОППАДАТ В текущую смену BO*/

define variable vss-revision    as character no-undo init "$Revision: 6557e99634e7, 3192, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkshift.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkshift.p $":U .
define variable vss-description as character no-undo init "Изменение даты и или номера смены для одного чека".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
DEFINE VARIABLE cas-shft as logical no-undo .
DEFINE VARIABLE conf-attr as character no-undo .
define variable v-is-update as logical no-undo .
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable v-shift-name2 as character no-undo .
define variable v-check-shift-date as date no-undo.
define variable v-check-shift-num as integer no-undo.
define variable v-check-shift-name as character no-undo .

define buffer bf_chk-doc for ub.chk-doc .
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_place for ub.place.
define buffer bf_chk-discnt for ub.chk-discnt.

do
on error undo, return error
:
  find first bf_chk-doc where
             recid(bf_chk-doc) = p-chk-rec.
  /*проверим легальность изменений*/
  /*для каждого чека находимм cas-shft - использовать смены на кассе или нет*/

  if bf_chk-doc.out-code <> ? then return error.
  if bf_chk-doc.chk-type = 13 or bf_chk-doc.chk-type = 40 then return error . 
  assign
  cas-shft = no.
  { gbl/cas-shft.i bf_chk-doc.obj-type bf_chk-doc.obj-code cas-shft }
  assign
  v-check-shift-date = (if lookup("shift-date":U, p-change-fields) > 0
                        then p-shift-date
                        else bf_chk-doc.shift-date)
  v-check-shift-num = (if lookup("shift-num":U, p-change-fields) > 0
                        then p-shift-num
                        else bf_chk-doc.shift-num
                        )
  v-check-shift-name = (if lookup("shift-name":U, p-change-fields) > 0
                        then p-shift-name
                        else bf_chk-doc.shift-name
                        )
 .

  CASE cas-shft:
    when yes then do:
      if v-check-shift-date = ? then return error.
      if p-shift-on then do:
        { gbl/curshift.i bf_chk-doc.obj-type bf_Chk-doc.obj-code v-shift-date v-shift-num v-shift-name2 no-error }
        
        if error-status:error then do:
          if p-can-back-shift = no then do:
            return error return-value .
          end.
        end.
        find first buf_shift-obj no-lock where
                  buf_shift-obj.obj-type = bf_chk-doc.obj-type
              and  buf_shift-obj.obj-code = bf_chk-doc.obj-code
              and  buf_shift-obj.shift-date = v-check-shift-date
              and  buf_shift-obj.shift-num =  v-check-shift-num
              and  buf_shift-obj.shift-name =  v-check-shift-name
              no-error.
              
        if not available buf_shift-obj then return error substitute('Нет смены &1(&2) от &3 для &4&5'
                                                                    ,v-check-shift-name
                                                                    ,v-check-shift-num
                                                                    ,string(v-check-shift-date, "99/99/9999")
                                                                    ,bf_chk-doc.obj-type
                                                                    ,bf_chk-doc.obj-code).

        /*если включен сменный режим то мы ПЕРЕПРАВИТЬ ТОЛЬКО НА ТЕКУЩУЮ СМЕНУ ИЛИ ОЖИДАЕМУЮ!!!*/
        if v-check-shift-date <> v-shift-date
        or v-check-shift-num <> v-shift-num
        or integer(v-check-shift-name) <> integer(v-shift-name2)
        then do:
          /*Ищем в справочнике смен*/
          if p-can-back-shift then do:
            if available buf_shift-obj
            and not (buf_shift-obj.status_ = {&sht-current}
                  or buf_shift-obj.status_ = {&sht-expected}
                  or buf_shift-obj.status_ = {&sht-closed})
                  then do:
              if not available buf_shift-obj then return error substitute('Смена &1(&2) от &3 для &4&5&6" +
                                                                          "имеет статус &7'
                                                                          ,buf_shift-obj.shift-name
                                                                          ,buf_shift-obj.shift-num
                                                                          ,string(buf_shift-obj.shift-date, "99/99/9999")
                                                                          ,bf_chk-doc.obj-type
                                                                          ,bf_chk-doc.obj-code
                                                                          ,{&new-line}
                                                                          ,buf_shift-obj.status_
                                                                          ).
            end. /*if available buf_shift-obj*/
          end.
          else do:
            if available buf_shift-obj
            and not (buf_shift-obj.status_ = {&sht-current}
                  or buf_shift-obj.status_ = {&sht-expected}) then do:
              if not available buf_shift-obj then return error substitute('Смена &1(&2) от &3 для &4&5&6" +
                                                                          "имеет статус &7'
                                                                          ,buf_shift-obj.shift-name
                                                                          ,buf_shift-obj.shift-num
                                                                          ,string(buf_shift-obj.shift-date, "99/99/9999")
                                                                          ,bf_chk-doc.obj-type
                                                                          ,bf_chk-doc.obj-code
                                                                          ,{&new-line}
                                                                          ,buf_shift-obj.status_
                                                                          ).
            end.
          end.
        end.
        /*если сменная работа в TH - отследим случай когда в результате изменения ЧЕК СТАЛ НАЩЕЙ СМЕНОЙ!!!*/
        if (bf_chk-doc.shift-date <> buf_shift-obj.shift-date
        or bf_chk-doc.shift-num <> buf_shift-obj.shift-num
        or integer(bf_chk-doc.shift-name) <> integer(buf_shift-obj.shift-name)
        ) then do:
          assign
          p-added = yes.
        end.
      end.
      else do:
        if v-check-shift-num = 0 then return error.
        if v-check-shift-date > bf_chk-doc.chk-date then return error.
        if integer(v-check-shift-name) = 0 then return error.
      end.
    end.
    when no then do:
      if v-check-shift-date > bf_chk-doc.chk-date then return error.
      if v-check-shift-num <> 0 then return error.
      if integer(v-check-shift-name) <> 0 then return error.
      if bf_chk-doc.shift-date <> v-shift-date
      then do:
        assign
        p-added = yes.
      end.
    end.
  END CASE.
  run trg/chk-doch.p (
                  buffer bf_chk-doc
                , input no
                , input no /*p-add*/
                , input no /*p-del*/
                , input-output v-chip-num
                , output v-is-update).

  assign
  bf_chk-doc.shift-date = v-check-shift-date
  bf_chk-doc.shift-num = v-check-shift-num
  bf_chk-doc.shift-name = string(integer(v-check-shift-name))
  .
  /* если изменилось что-то, то пишем в параметр об изменении этого чека */
  if bf_chk-doc.shift-date    <> v-check-shift-date
    or bf_chk-doc.shift-num   <> v-check-shift-num
    or bf_chk-doc.shift-name  <> string(integer(v-check-shift-name)) then
        p-changed = true.
    for each bf_chk-discnt where bf_chk-discnt.doc-code = bf_chk-doc.doc-code:
    assign
      bf_chk-discnt.shift-date = v-check-shift-date
      bf_chk-discnt.shift-num = v-check-shift-num
      .    
    release bf_chk-discnt.        
    end.
  if lookup("shift-reservoir-to", p-change-fields) > 0 then
    do:
      /* меняем резеруар у товаров в чеке */
      for each buf_chk-gds
        where buf_chk-gds.doc-code = bf_chk-doc.doc-code
            and buf_chk-gds.pl-code = p-shift-reservoir-from /* сравниваем с резервуаром */
                :
                    find first buf_place
                        where buf_place.pl-code = p-shift-reservoir-to
                        no-error.
                        
                    if avail buf_place then do:
                        buf_chk-gds.pl-code = buf_place.pl-code.
                        buf_chk-gds.loc1    = buf_place.loc1.
                        
                        /* если меняем резервуар, то пишем в параметр об изменение этого чека */
                        p-changed = true.
                    end.
      end.
    end.
  
  if (bf_chk-doc.shift-date = v-shift-date
  and bf_chk-doc.shift-num = v-shift-num
  and bf_chk-doc.shift-name = v-shift-name2
      )
  or (p-shift-on
      and
      bf_chk-doc.shift-date = buf_shift-obj.shift-date
      and
      bf_chk-doc.shift-num = buf_shift-obj.shift-num
      and
      bf_chk-doc.shift-name = buf_shift-obj.shift-name)
  then do:
    assign
    bf_chk-doc.office = replace(bf_chk-doc.office, {&shift-err}, '':U)
    bf_chk-doc.office = replace(bf_chk-doc.office, ({&comma-char} + {&comma-char}), {&comma-char})
    bf_chk-doc.office = trim(bf_chk-doc.office, {&comma-char})
    bf_chk-doc.correct = (replace(replace(replace(bf_chk-doc.office, {&gds-goods}, '':U), {&gds-office}, ''), {&comma-char}, '') = '')
    .
  end.


  run trg/chk-doch.p (
                  buffer bf_chk-doc
                , input yes
                , input no /*p-add*/
                , input no /*p-del*/
                , input-output v-chip-num
                , output v-is-update).
  bf_chk-doc.ps = if v-is-update
                  then (if index(bf_chk-doc.ps, "shift!") > 0
                        then bf_chk-doc.ps
                        else ("!shift!":U +  left-trim(bf_chk-doc.PS, "!":U))
                        )

                  else bf_chk-doc.ps.

end.
