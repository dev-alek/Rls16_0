/*

$Revision: 1d6ea42ddaad, 1178, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: imptank-imp.cls $
$Archive: ibs/th/bge/1crn/import/imptank-imp.cls $

Класс ипорта данных imptank-imp из 1С

Автор: Елена Шкляр
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.placelib from propath .


block-level on error undo, throw.

class ibs.th.bge.1crn.import.imptank-imp implements ibs.th.bge.1crn.import.iimpsubject: 

  define variable placelib as class placelib no-undo .
  
  { cmp/str-glbl.i class }
  { gbl/cur-time.i class }
   
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):

    define variable v-tank         as class tank-imp         no-undo.
    define variable v-cal-tbl-line as class tank-imp_cal-tbl no-undo.
    define variable v-belt-tbl-line as class tank-imp_belt-tbl no-undo.
    
    define variable v_cal-tbl      as class subjects         no-undo.
    define variable v_belt-tbl      as class subjects         no-undo.
    
    define buffer buf_place-imp      for ub.place-imp .
    define buffer bf_place-imp       for ub.place-imp .
    define buffer buf_place-imp-attr for ub.place-imp-attr .
    define buffer buf_pl-level-imp   for ub.pl-level-imp .
    define buffer bf_pl-level-imp    for ub.pl-level-imp .
    define buffer buf_clients        for ub.clients .
    define buffer buf_pl-level-attr  for ub.pl-level-attr .
    define buffer buf_pl-level-mm-imp   for ub.pl-level-mm-imp .
    define buffer buf_shift-obj      for ub.shift-obj .
    define buffer buf_place-attr     for ub.place-attr .
    
    define variable v-mode  as character no-undo .
    define variable v-rec   as recid     no-undo .
    define variable ii      as integer   no-undo .
    define variable v-code  as character no-undo .
    define variable v-value as character no-undo .
    define variable v-ok    as logical   no-undo .
    
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .

    v-tank = cast (subjectObj, tank-imp).
    v_cal-tbl = v-tank:cal-tbl .
    v_belt-tbl = v-tank:belt-tbl .
    
    find first buf_clients no-lock  where buf_clients.obj-type = {&shop} 
      and buf_clients.obj-code = integer(v-tank:gs-code) no-error .
    if not AVAILABLE (buf_clients) then 
    do:
      Msg = "Нет объекта с кодом: " + v-tank:gs-code . 
      return error .
    end.      

    find first buf_place-imp no-lock where buf_place-imp.obj-type = buf_clients.obj-type
                                       and buf_place-imp.obj-code = buf_clients.obj-code
                                       and buf_place-imp.pl-code  = integer(v-tank:tank-code)
                                       and buf_place-imp.table-version >= v-tank:table-version
                                       no-error .
    if NOT AVAILABLE (buf_place-imp) then 
    do:
      
      create buf_place-imp .
      assign
        buf_place-imp.obj-type      = buf_clients.obj-type     
        buf_place-imp.obj-code      = buf_clients.obj-code     
        buf_place-imp.pl-code       = integer(v-tank:tank-code) 
        buf_place-imp.table-version = v-tank:table-version
        
        buf_place-imp.status_       = 0
        
        buf_place-imp.max-qnty      = v-tank:max-qnty
        buf_place-imp.d-qnty        = v-tank:d-qnty
        buf_place-imp.tank-d        = v-tank:tank-d
        buf_place-imp.dc-height     = v-tank:dc-height
        buf_place-imp.dnsty         = v-tank:dnsty
        buf_place-imp.main-mi-code  = if v-tank:main-mi-code <> ? then integer(v-tank:main-mi-code) else ?
        buf_place-imp.position      = v-tank:position_ + 1 /* в обмене 0 - наземный, 1 - подземный; у нас 1 - наземный, 2 - подземный */
        buf_place-imp.tank-tk       = v-tank:tank-tk
        buf_place-imp.pontoon       = v-tank:pontoon
        buf_place-imp.wght-pntn     = v-tank:wght-pntn
        buf_place-imp.srfcng-pntn   = v-tank:srfcng-pntn
      .
      
      for each bf_pl-level-imp where bf_pl-level-imp.obj-code = buf_place-imp.obj-code
        and bf_pl-level-imp.obj-type = buf_place-imp.obj-type
        and bf_pl-level-imp.pl-code = buf_place-imp.pl-code
        and bf_pl-level-imp.table-version = buf_place-imp.table-version:
/*                                                                     */
/*        for each buf_pl-level-attr exclusive-lock where              */
/*                 buf_pl-level-attr.obj-type  = buf_place-imp.obj-type*/
/*             and buf_pl-level-attr.obj-code  = buf_place-imp.obj-code*/
/*             and buf_pl-level-attr.pl-code   = buf_place-imp.pl-code */
/*             and buf_pl-level-attr.pl-level  = bf_pl-level.pl-level: */
/*          delete buf_pl-level-attr.                                  */
/*        end.                                                         */
        delete bf_pl-level-imp .
      end.
      for each buf_pl-level-mm-imp where buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
        and buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
        and buf_pl-level-mm-imp.pl-code = buf_place-imp.pl-code
        and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version:

        delete buf_pl-level-mm-imp .
      end.
              
      if VALID-OBJECT (v_cal-tbl) then 
      do:
        do ii = 1 to v_cal-tbl:Get(ii):
          v-cal-tbl-line = cast(v_cal-tbl:SubjectObjCurr, tank-imp_cal-tbl) .
          find first buf_pl-level-imp EXCLUSIVE-LOCK where buf_pl-level-imp.obj-code = buf_place-imp.obj-code
            and buf_pl-level-imp.obj-type = buf_place-imp.obj-type
            and buf_pl-level-imp.pl-code = buf_place-imp.pl-code
            and buf_pl-level-imp.table-version = buf_place-imp.table-version
            and buf_pl-level-imp.pl-level = v-cal-tbl-line:lvl_ no-error .
          if not AVAILABLE (buf_pl-level-imp) then 
          do:
            create buf_pl-level-imp.
            assign
              buf_pl-level-imp.obj-type = buf_place-imp.obj-type
              buf_pl-level-imp.obj-code = buf_place-imp.obj-code
              buf_pl-level-imp.pl-code  = buf_place-imp.pl-code
              buf_pl-level-imp.table-version = buf_place-imp.table-version
              buf_pl-level-imp.pl-level = v-cal-tbl-line:lvl_
              buf_pl-level-imp.pl-qnty  = v-cal-tbl-line:amnt
              buf_pl-level-imp.tarir-delta = v-cal-tbl-line:comp-err
              buf_pl-level-imp.deltaV   = v-cal-tbl-line:deltaV
            .
          end.
/*          if v-cal-tbl-line:comp-err <> ? then                                                                    */
/*          do:                                                                                                     */
/*            find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_place-imp.obj-type*/
/*                                              and buf_pl-level-attr.obj-code  = buf_place-imp.obj-code            */
/*                                              and buf_pl-level-attr.pl-code   = buf_place-imp.pl-code             */
/*                                              and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level             */
/*                                              and buf_pl-level-attr.attr-code = "tarir-delta"                     */
/*                                              no-error .                                                          */
/*            if not available buf_pl-level-attr                                                                    */
/*            then do :                                                                                             */
/*              create buf_pl-level-attr .                                                                          */
/*              assign                                                                                              */
/*                buf_pl-level-attr.obj-type  = buf_place-imp.obj-type                                              */
/*                buf_pl-level-attr.obj-code  = buf_place-imp.obj-code                                              */
/*                buf_pl-level-attr.pl-code   = buf_place-imp.pl-code                                               */
/*                buf_pl-level-attr.pl-level  = buf_pl-level.pl-level                                               */
/*                buf_pl-level-attr.attr-code = "tarir-delta"                                                       */
/*              .                                                                                                   */
/*            end.                                                                                                  */
/*            buf_pl-level-attr.attr-value = string(v-cal-tbl-line:comp-err).                                       */
/*          end.                                                                                                    */
        end.  
      end.

      if VALID-OBJECT (v_belt-tbl) then 
      do:
        do ii = 1 to v_belt-tbl:Get(ii):
          v-belt-tbl-line = cast(v_belt-tbl:SubjectObjCurr, tank-imp_belt-tbl) .
          find first buf_pl-level-mm-imp EXCLUSIVE-LOCK where buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
            and buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
            and buf_pl-level-mm-imp.pl-code = buf_place-imp.pl-code
            and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
            and buf_pl-level-mm-imp.zone = v-belt-tbl-line:num-belt
            and buf_pl-level-mm-imp.level = v-belt-tbl-line:tbl-lvl no-error .
          if not AVAILABLE (buf_pl-level-mm-imp) then 
          do:
            create buf_pl-level-mm-imp.
            assign
              buf_pl-level-mm-imp.obj-type  = buf_place-imp.obj-type
              buf_pl-level-mm-imp.obj-code  = buf_place-imp.obj-code
              buf_pl-level-mm-imp.pl-code   = buf_place-imp.pl-code
              buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
              buf_pl-level-mm-imp.zone      = v-belt-tbl-line:num-belt
              buf_pl-level-mm-imp.min-level = v-belt-tbl-line:low-lvl
              buf_pl-level-mm-imp.max-level = v-belt-tbl-line:up-lvl
              buf_pl-level-mm-imp.level     = v-belt-tbl-line:tbl-lvl
              buf_pl-level-mm-imp.capacity  = v-belt-tbl-line:belt-capacity * 1000
            .
          end.
        end.  
      end.
      
      cur-time (output v-today
               ,output v-time
               ).
      
      assign
        buf_place-imp.corr-date     = v-today
        buf_place-imp.corr-time     = v-time
      .
      
      run str/prep1C-status-cal-tbl.p (input buf_place-imp.table-version,
                                       input buf_place-imp.pl-code,
                                       input buf_place-imp.corr-date,
                                       input buf_place-imp.corr-time,
                                       input buf_place-imp.status_)
                                       no-error .
                                   
      find first buf_shift-obj
        where buf_shift-obj.obj-type = buf_clients.obj-type
          and buf_shift-obj.obj-code = buf_clients.obj-code
          and buf_shift-obj.status_ = {&sht-current}
      use-index pi
      no-error.
      if not available buf_shift-obj
      then do : /* Нет открытой смены на объекте - сразу применяем новые параметры и градуировочные таблицы */
        run str/apply_place-imp.p (input buf_place-imp.obj-type,
                                   input buf_place-imp.obj-code,
                                   input buf_place-imp.pl-code,
                                   input buf_place-imp.table-version)
                                   no-error .
        if error-status:error
        then do :
          Msg = "Ошибка при применении новых параметров резервуара " + v-tank:tank-code + " и градуировочных таблиц" .
          return error .
        end .
      end .
      else do :
        find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = buf_place-imp.obj-type
                                                   and buf_place-attr.obj-code = buf_place-imp.obj-code
                                                   and buf_place-attr.pl-code  = buf_place-imp.pl-code
                                                   and buf_place-attr.attr-code = "pending-table-version"
                                                   no-error .
        if not available buf_place-attr
        then do :
          create buf_place-attr .
          assign
            buf_place-attr.obj-type = buf_place-imp.obj-type  
            buf_place-attr.obj-code = buf_place-imp.obj-code  
            buf_place-attr.pl-code  = buf_place-imp.pl-code   
            buf_place-attr.attr-code = "pending-table-version"
          .
        end .
        assign
          buf_place-attr.attr-value = buf_place-attr.attr-value + "," + string(buf_place-imp.table-version)
          buf_place-attr.attr-value = trim(buf_place-attr.attr-value, ",")
        .
        
        find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = buf_place-imp.obj-type
                                                   and buf_place-attr.obj-code = buf_place-imp.obj-code
                                                   and buf_place-attr.pl-code  = buf_place-imp.pl-code
                                                   and buf_place-attr.attr-code = "message-table-version"
                                                   no-error .
        if not available buf_place-attr
        then do :
          create buf_place-attr .
          assign
            buf_place-attr.obj-type = buf_place-imp.obj-type  
            buf_place-attr.obj-code = buf_place-imp.obj-code  
            buf_place-attr.pl-code  = buf_place-imp.pl-code   
            buf_place-attr.attr-code = "message-table-version"
          .
        end .
        assign buf_place-attr.attr-value = "pending" .
      end .
    end.
    else do:
      Msg = "Уже есть данные для резервуара " + v-tank:tank-code + " с номером версии " + string(v-tank:table-version) . 
      return true .
    end.  
  end method.
end class.