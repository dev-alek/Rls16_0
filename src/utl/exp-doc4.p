block-level on error undo, throw.
/*

$Revision: 0100a4d3b790, 1441, test $
$Author: SMMolotkov $
$Date: Fri Jun 29 18:00:05 2018 +0300 $
$Workfile: exp-doc4.p $
$Archive: utl/exp-doc4.p $

Выгружает все партии свободной зоны

Автор: Молотков Сергей
Дата создания: 10/04/18
Author: Molotkov Sergey
Creation date: 10/04/18

Формат:
PART: артикул;;part-code партии;in-code партии;доп-бар-код;<цена>;<количество>;;;;[НДС];;;[ГТД];;;[срок годности];;;[Код поставщика];[Тип поставщика];[Номер договора]
*/
define input  parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 0100a4d3b790, 1441, test $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 18:00:05 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-doc4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-doc4.p $":U .
define variable vss-description as character no-undo init "Выгружает все партии свободной зоны".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/library.i }
{ str/lib-trn.i }
{ gbl/waitfram.i }


define temp-table tt-rest no-undo
  field contract-code as integer
  field supp-code     as integer
  field gds-code      like ub.gds-obj.gds-code
  field artic         like ub.parts.artic
  field part-code     as character
  field in-code       as character
  field fact-qnty     as decimal
  field prc_rubl      as decimal
  field sum_rubl      as decimal
  field vat-tax-value as decimal
  field supp-type     like ub.parts.supp-type
  field name-gtd      as character
  field srok-god      as character
  index pi is primary in-code
  index i-supp supp-code contract-code
  index i-gds gds-code
.


define variable g-log        as logical no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable c_cli-list   as character no-undo .
define variable c_ind        as integer no-undo .
define variable c_size       as integer no-undo .
define variable v-obj-code   as integer no-undo .
define variable v-obj-type   as character no-undo .
define variable v-host-code  as integer   no-undo . /* код фирмы */
define variable c_supp-code  as character no-undo .
define variable v-supp-code  as integer no-undo .
define variable v-cont-code  as integer no-undo .
define variable v-start-fact-order  as decimal no-undo .
define variable v-vat-tax-value as decimal no-undo .
define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable v-now        as datetime no-undo .
define variable v-mtime      as integer no-undo .
define variable v-stime      as character no-undo .
define variable v-sdate      as character no-undo .
define variable v-objnm      as character no-undo .
define variable v-fsupp      as character no-undo .
define variable v-contn      as character no-undo .
define variable v-fcont      as character no-undo .
define variable v-fpref      as character no-undo .
define variable v-srok-god   as character no-undo .
define variable f-name       as character no-undo .
define variable v-wait-msg   as character no-undo .
define variable v-lines      as integer no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define buffer buf_gds-obj   for ub.gds-obj .
define buffer buf_parts     for ub.parts .
define buffer buf_clients   for ub.clients .
define buffer buf_contract  for ub.contract .
define buffer buf_tt-rest   for tt-rest .
define stream f-txt .

define button btn-ok     AUTO-GO .
define button btn-cancel AUTO-ENDKEY .
define button btn-dir .
define frame f-dialog
          space(1) v-obj-code attr-space auto-return format ">>>>>>>>9" view-as fill-in native
                              label "Введите код магазина для выгрузки остатков"
  skip(1)                 
  /* выбор поставщиков, остатки которых надо будет выгружать:
     пусть пока будет строка в которую через запятую будут вводиться коды */
          space(1) "Введите коды выгружаемых поставщиков (пусто - по всем поставщикам)"
  skip(0) space(1) c_cli-list attr-space auto-return format "x(320)" no-label view-as fill-in native size-chars 65 by 1
  skip(1) space(1) btn-dir    label "Выбрать директорию выгрузки"
                   v-dir-name format "x(20)" no-label view-as text
  skip(1) space(1) btn-ok     label "Продолжить"
          space(1) btn-cancel label "Отменить"
  skip(1)
  with title "Выгрузка всех партий свободной зоны" attr-space side-labels view-as dialog-box.

on choose of btn-dir in frame f-dialog do :
  /* Куда будем сохранять файлы */
  run gbl/dir-sel.p
     ( output v-dir-name
      ,output v-type
      ,output v-can-write
      ).
  display v-dir-name with frame f-dialog .
end .

on choose of btn-ok in frame f-dialog do:
  if NOT v-can-write THEN DO:
    message "Укажите путь для сохранения файлов." view-as alert-box error.
    apply "entry" to btn-dir in frame f-dialog.
    return no-apply.
  END.
  assign v-obj-code .
  if v-obj-code > 0 then . else do:
    message "Укажите код магазина, остатки которого требуется выгрузить." view-as alert-box error.
    apply "entry" to v-obj-code in frame f-dialog.
    return no-apply.
  end .
end .


  do on end-key undo, return :
    v-can-write = false .
    c_cli-list = "":U .
    update
      v-obj-code
      c_cli-list
      btn-dir
      btn-ok
      btn-cancel
    with frame f-dialog.
  end .
  assign
    v-obj-type = {&shop}
    c_cli-list = replace(c_cli-list, ' ', '')
    c_size     = num-entries(c_cli-list)
  .
  do c_ind = 1 to c_size :
    entry(c_ind, c_cli-list) = left-trim( entry(c_ind, c_cli-list), "0" ) .
  end .


function fnamereplace returns character (input p-fname as character) :
define variable v-fname as character no-undo .
  v-fname = replace(p-fname, '"', '') .
  v-fname = replace(v-fname, '\', '-') .
  v-fname = replace(v-fname, '/', '-') .
  v-fname = replace(v-fname, "'", "") .
  v-fname = replace(v-fname, ':', '') .
  v-fname = replace(v-fname, '?', '') .
  v-fname = replace(v-fname, '|', '') .
  v-fname = replace(v-fname, '>', '') .
  v-fname = replace(v-fname, '<', '') .
  return v-fname .
end function .
       
    /* fact-order на начало периода;
       скопировано из rep/ostatok.i */
    define buffer buf_stk-tot for ub.stk-tot .
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type = v-obj-type
          and buf_stk-tot.obj-code = v-obj-code
          and buf_stk-tot.sum-type = {&arh-crsa}
          and buf_stk-tot.cat-id   = {&root-cat-id}
    USE-INDEX Shift-num no-error .
    if available buf_stk-tot then v-start-fact-order = buf_stk-tot.Fact-order .
    else do:
      message
        substitute( "Для объекта &3&4 на сегодня отсуствуют предшествующие остатки"
                  , v-obj-type, v-obj-code
        )
      view-as alert-box error .
      return .
    end .

    /* host-code используется для менее точного поиска ставки НДС на товаре */
    {gbl/hostcode.i v-obj-type v-obj-code v-host-code}
    
    assign
      v-wait-msg = "Сбор текущих остатков. Строк: &1"
      v-lines    = 0
      v-ln-prev  = v-lines + 100
      v-tm-prev  = time + 1
      v-now   = now
      v-mtime = mtime (v-now)
      v-stime = string (integer(truncate(v-mtime / 1000, 0)), "hh:mm")
      v-sdate = substitute(  "&1&2&3&4&5",
        string(year(v-now),"9999"),  string(month(v-now),"99"),  string(day(v-now),"99"),
        substring(v-stime, 1, 2),  substring(v-stime, 4, 2)
      )
    .
    run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
    v-fpref = substitute("&1\&2&3_&4", v-dir-name, v-obj-type, v-obj-code, v-sdate) no-error .
    
define stream f-log .
define variable f-logname as character no-undo .
  f-logname = substitute("&1.log", v-fpref) no-error .

output stream f-log to value(f-logname) .
    empty temp-table tt-rest.
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = v-obj-type
         and buf_gds-obj.obj-code = v-obj-code :
      /* Выгружаются все товары кроме топлива. */
      { str/is-petrl.i
          buf_gds-obj.artic
          buf_gds-obj.prod-type
          buf_gds-obj.prod-code
          is-petrolium
          is-pieces
      }
      if is-petrolium then next .
put stream f-log unformatted "01 товар " buf_gds-obj.artic " " buf_gds-obj.prod-type " " buf_gds-obj.prod-code skip .

      for each buf_parts no-lock
         where buf_parts.out-code  = {&free-code}
           and buf_parts.obj-type  = buf_gds-obj.obj-type
           and buf_parts.obj-code  = buf_gds-obj.obj-code
           and buf_parts.artic     = buf_gds-obj.artic
           and buf_parts.prod-type = buf_gds-obj.prod-type
           and buf_parts.prod-code = buf_gds-obj.prod-code
        /* abd buf_parts.status_ ... */ :
        v-lines = v-lines + 1 .
        if v-lines > v-ln-prev then do:
          v-ln-prev = v-lines + 100.
          if v-tm-prev < time then do:
            v-tm-prev  = time + 1 .
            run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
          end .
        end.
      
put stream f-log unformatted "02 партия " buf_parts.supp-code " [" + left-trim( string(buf_parts.supp-code), "0") + "] " can-do (c_cli-list, left-trim( string(buf_parts.supp-code), "0")) skip .
        /* Поставщик партии - parts.supp-code */
        if c_cli-list <> "" then do:
          /* если заданы поставщики, то выгружать только по ним */           
          c_supp-code = left-trim( string(buf_parts.supp-code), "0") no-error .
          if not can-do (c_cli-list, c_supp-code) then next .
        end .
        assign
          v-supp-code = buf_parts.supp-code
          v-cont-code = buf_parts.contract-code
        .
          
        /*
        Договор - parts.contract-code (= contract.contract-code).
        Все партии выгружаются единым файлом, без усреднения.
        Т.к. выгружается номер договора, а не его код, то договор должен определять по prn-code.
        */
put stream f-log unformatted "03 выгрузка " v-supp-code skip .
        v-srok-god = trim(string(buf_parts.last-date, "99/99/9999")) no-error .
        create buf_tt-rest .
        assign
          buf_tt-rest.contract-code = v-cont-code
          buf_tt-rest.supp-code     = v-supp-code
          buf_tt-rest.gds-code      = buf_gds-obj.gds-code
          buf_tt-rest.artic     = buf_parts.artic
          buf_tt-rest.part-code = buf_parts.part-code
          buf_tt-rest.in-code   = buf_parts.in-code
          buf_tt-rest.fact-qnty = buf_parts.fact-qnty
          buf_tt-rest.prc_rubl  = buf_parts.price-rubl
          buf_tt-rest.sum_rubl  = buf_parts.fact-qnty * buf_parts.price-rubl
          buf_tt-rest.vat-tax-value = 0
          buf_tt-rest.supp-type = buf_parts.supp-type
          buf_tt-rest.name-gtd  = trim(buf_parts.cst-code)
          buf_tt-rest.srok-god  = if v-srok-god = ? then "" else v-srok-god
        .
      end . /* end_of for_each_parts */
    end . /* end_of for_each_gds-obj */
    run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
output stream f-log close .    
  
    
  /* проставление налогов */
  v-wait-msg = "Проставление ставок налога" .
  run waitfram-show in this-procedure (v-wait-msg) .
  for each buf_tt-rest break by buf_tt-rest.gds-code :
    if first-of (buf_tt-rest.gds-code) then do :
      run найти_ставку_ндс in this-procedure
          ( buf_tt-rest.gds-code
          , v-host-code
          , v-obj-type
          , v-obj-code
          , v-start-fact-order
          , output v-vat-tax-value
          ) .
    end .
    buf_tt-rest.vat-tax-value = v-vat-tax-value .
  end .
    
  /* выгрузка таблицы в файл */
  v-wait-msg = "Выгрузка в файл" .
  run waitfram-show in this-procedure (v-wait-msg) .
  
  f-name = substitute("&1.adb", v-fpref) no-error .
  output stream f-txt to value (f-name) .
      
  for each buf_tt-rest break by buf_tt-rest.supp-code by buf_tt-rest.contract-code :
    if first-of (buf_tt-rest.contract-code) then do :
      if buf_tt-rest.contract-code > 0 then do :
        find first buf_contract no-lock
             where /* buf_contract.host-code     = buf_clients.host-code
               and */ buf_contract.contract-code = buf_tt-rest.contract-code no-error .
        if available buf_contract then do:
             v-contn = buf_contract.contract-prn-code .
        end .
        else v-contn = "0" .
      end .
      else   v-contn = "0" .
    end .
     
    put stream f-txt unformatted
          substitute("PART: &1;", buf_tt-rest.artic)
          ";"
          substitute("&1;", buf_tt-rest.part-code)
          substitute("&1;", buf_tt-rest.in-code)
          buf_tt-rest.gds-code ";"
          buf_tt-rest.prc_rubl ";"
          buf_tt-rest.fact-qnty ";"
          ";"
          ";"
          ";"
          buf_tt-rest.vat-tax-value ";"
          ";"
          ";"
          buf_tt-rest.name-gtd ";"
          ";"
          ";"
          buf_tt-rest.srok-god ";"
          ";"
          ";"
          buf_tt-rest.supp-code ";"
          buf_tt-rest.supp-type  ";"
          v-contn skip
    .
  end . /* end_of for_each_tt-rest */
  output stream f-txt close .
  
  run waitfram-hide in this-procedure .
message "Выгрузка закончена." view-as alert-box information buttons ok.

procedure найти_ставку_ндс private :
define input parameter p-gds-code  as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-start-fact-order as decimal no-undo .
define output parameter p-vat-tax-value as decimal no-undo .
define buffer buf_tax-rate-gds   for ub.tax-rate-gds .
define buffer buf_tax-rate-value for ub.tax-rate-value .
  
      /* ----- найти ставку НДС ----- */      
      /* скопировано из bge/bge-exp-sap.p */
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = p-gds-code
            and buf_tax-rate-gds.tax-code  = {&bef-vat-tax-code}
            and buf_tax-rate-gds.host-code = p-host-code
            and buf_tax-rate-gds.obj-type  = p-obj-type
            and buf_tax-rate-gds.obj-code  = p-obj-code
            and buf_tax-rate-gds.fact-order <= p-start-fact-order no-error .
      if not available buf_tax-rate-gds then
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = p-gds-code
            and buf_tax-rate-gds.tax-code  = {&bef-vat-tax-code}
            and buf_tax-rate-gds.host-code = 0
            and buf_tax-rate-gds.obj-type  = ''
            and buf_tax-rate-gds.obj-code  = 0
            and buf_tax-rate-gds.fact-order <= p-start-fact-order no-error.
      if available buf_tax-rate-gds then do:
        /* скопировано из library.p::pftaxval(), т.к. оригинальный pftaxval() используетс свой fact-order */ 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = p-host-code
              and buf_tax-rate-value.obj-type  = p-obj-type
              and buf_tax-rate-value.obj-code  = p-obj-code
              and buf_tax-rate-value.fact-order <= p-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        if not available buf_tax-rate-value then 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = p-host-code
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= p-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        if not available buf_tax-rate-value then 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = 0
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= p-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        p-vat-tax-value = if available buf_tax-rate-value then buf_tax-rate-value.rate-value else 0 .
      end .
      else p-vat-tax-value = 0 .
      /* ----- end_of найти ставку НДС ----- */

end procedure. /* end_of найти_ставку_ндс */