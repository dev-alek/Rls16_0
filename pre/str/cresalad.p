block-level on error undo, throw.
define parameter buffer buf_main_trn-doc for ub.trn-doc.
define parameter buffer buf_trn-doc for ub.trn-doc.
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define output parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cresalad.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cresalad.p $":U .
define variable vss-description as character no-undo init "Генерация дополнительных (помимо простого расхода и возврата) документов, привязанных к продаже".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable v-doc-type like ub.trn-doc.doc-type no-undo .
define variable v-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable v-cli-type like ub.trn-doc.cli-type no-undo .
define variable v-cli-code like ub.trn-doc.cli-code no-undo .
define variable v-cli-name like ub.trn-doc.cli-name no-undo .
define variable v-internal like ub.trn-doc.internal no-undo .
define variable v-pay-code like ub.trn-doc.pay-code no-undo .
define variable v-purch-code like ub.trn-doc.purch-code no-undo .
define variable v-status    like ub.trn-doc.status_ no-undo .
define variable v-ps like ub.trn-doc.ps no-undo .
define variable v-mes as character no-undo .
define variable v-entry as character no-undo .
define variable v-doc-kind as character no-undo .
define variable v-doc-kind-label as character no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-down-pay like ub.shop.down-pay no-undo .
define variable ii as integer no-undo .
define variable v-doc-code-parameter as character no-undo .
define variable v-cntxt-userid as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
_main:
do
on error undo, return error return-value
:
  if lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) = 0 then do:
    v-mes = substitute("Неизвестный вид автодокумента &1 для продажи &2"
                      , p-doc-kind
                      , buf_main_trn-doc.doc-code
                      ).
    undo _main, return error v-mes.
  end.
  if p-doc-kind = 'es':U
  and p-office = 'т':U
  then do:
    v-mes = substitute("Автодокумент &1 для продажи товаров типа &2 с номером &3 должен быть создан вместе с продажей"
                      , p-doc-kind
                      , 'т':U
                      , buf_main_trn-doc.doc-code
                      ).
    undo _main, return error v-mes.
  end.
  if not available buf_main_trn-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Нет записи в буфере-параметре при вызове")
    view-as alert-box error .
    undo _main, return error .
  end.
  if buf_main_trn-doc.ext-doc-type <> 'es':U then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Неверный расш. тип докум &1 &2 в буфере-параметре при вызове"
               , buf_main_trn-doc.doc-code
               , buf_main_trn-doc.ext-doc-type)
    view-as alert-box error .
    undo _main, return error .
  end.
  assign
    v-doc-code-parameter = entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U), 'main,pair,trio-m,quadro,stock-down,quadro,chip') + (if p-office = 'у':U then "_s" else "":U)
  no-error .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Неверно определено или не определено правило создания номера документа для дополнительного документа по продаже вида &1"
                , entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
               )
    view-as alert-box error .
    undo _main, return error .
  end.
  run doc-code in this-procedure
      (input v-doc-code-parameter
      ,input buf_main_trn-doc.obj-type
      ,input buf_main_trn-doc.obj-code
      ,input buf_main_trn-doc.doc-code
      ,output p-doc-code ) no-error.
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации номера дополнительного документа вида &5 для продажи &4:&1&2 &3"
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , p-doc-kind
                      ).
    undo _main, return error v-mes.
  end.
  find first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = p-doc-code
        AND buf_trn-doc.out-code = buf_main_trn-doc.doc-code no-error .
  if locked buf_trn-doc then do:
    return 'locked':U.
  end.
  else do:
    if available buf_trn-doc then return.
  end.
  if lookup(p-doc-kind, 'rwo,trf,swo,ngs,rgs,vir':U) > 0 and p-cli-code = 0 and p-cli-type = "" then do:
    run adm/shattri.p (
        input "get":U
        ,input  buf_main_trn-doc.obj-type
        ,input  buf_main_trn-doc.obj-code
        ,input  'autosale':U
        ,input  'sale-add':U
        ,output v-value-character
        ,output v-value-date
        ,output  v-value-decimal
        ,output  v-value-integer
        ,output  v-value-logical
        ,output par-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    v-mes = substitute("Ошибка при определении контрагента дополнительного документа вида &5 для продажи &4:&1&2 &3"
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                      ).
    if error-status:error
    then do:
      delete object v-tth.
      undo _main, return error v-mes.
    end.
    delete object v-tth.
    _ii:
    do ii = 1 to num-entries(v-value-character, ';':U):
      assign
        v-entry =  ENTRY(ii, v-value-character, ';':U)
        v-doc-kind = ENTRY(1, v-entry)
        v-cli-type = ENTRY(2, v-entry)
        v-cli-code = integer(ENTRY(3, v-entry))
      .
      assign
        v-doc-kind-label = entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
      no-error .
      if v-doc-kind = p-doc-kind then do:
        leave _ii.
      end.
    end.
    if v-cli-type = '':U
    or v-cli-code = 0 then do:
      v-mes = substitute("Ошибка при определении контрагента дополнительного документа вида &5 для продажи &4:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , "Контрагент не задан - задайте контрагента (АРМ Администратор-Справочники-Магазины-Параметры-Опции работы с продажей"
                        , buf_main_trn-doc.doc-code
                        , entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                        ).
      if error-status:error
      then do:
        undo _main, return error v-mes.
      end.
    end.
    find first buf_clients no-lock where buf_clients.obj-type  = v-cli-type
                                     and buf_clients.obj-code  = v-cli-code
    no-error .
    if not available buf_clients then do:
      undo _main, return error v-mes.
    end.
  end.
  v-ps = substitute('&1&2 &1&3&1 Кол-во_чеков 0&1строк_чеков 0&1 товаров 0&1признаков 0&1'
                    , chr(4)
                    , (if buf_main_trn-doc.office then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    ).
  CASE p-doc-kind:
    when 'es':U then do:
      v-mes = '':U.
      assign
        v-ext-doc-type       = 'es':U
        v-doc-type           = 'рас':U
        v-cli-type = buf_main_trn-doc.cli-type
        v-cli-code = buf_main_trn-doc.cli-code
        v-cli-name           = buf_main_trn-doc.cli-name
        v-internal = no
        v-pay-code = buf_main_trn-doc.pay-code
        v-status   = (if buf_main_trn-doc.status_ = 'запрос':U
                      then 'запрос':U
                      else 'касс':U)
        v-purch-code  = buf_main_trn-doc.purch-code
        v-discnt-type = 'касс':U
      .
    end.
    when 'rs':U then do:
      v-mes = '':U.
      assign
        v-ext-doc-type       = 'rs':U
        v-doc-type           = 'возврат':U
        v-cli-type = buf_main_trn-doc.cli-type
        v-cli-code = buf_main_trn-doc.cli-code
        v-cli-name           = buf_main_trn-doc.cli-name
        v-internal = no
        v-pay-code = buf_main_trn-doc.pay-code
        v-status   = (if buf_main_trn-doc.status_ = 'запрос':U
                      then 'запрос':U
                      else 'касс':U)
        v-purch-code  = buf_main_trn-doc.purch-code
        v-discnt-type = 'касс':U
      .
    end.
    when 'trf':U
    or
    when 'rwo':U
    or
    when 'swo':U
    or
    when 'vir':U
    then do:
      case buf_main_trn-doc.obj-type :
        when 'маг':U then do:
          find first buf_shop no-lock where
                  buf_shop.obj-code = buf_main_trn-doc.obj-code.
          v-down-pay = buf_shop.down-pay.
        end.
        when 'скл':U then do:
          find first buf_store no-lock where
                  buf_store.obj-code = buf_main_trn-doc.obj-code.
          v-down-pay = buf_store.down-pay.
        end.
      END CASE.
      v-mes = '':U.
      assign
        v-ext-doc-type       = entry(lookup(p-doc-kind, 'rwo,trf,swo,ngs,rgs,vir':U), 'we,we,we,we,ee':U)
        v-cli-name           = if available(buf_clients) then buf_clients.obj-name else ''
        v-internal = no
        v-pay-code = v-down-pay
        v-ps = '':U
        v-status   = (if buf_main_trn-doc.status_ = 'запрос':U
                then 'запрос':U
                else 'нередакт':U)
        v-purch-code  = ?
        v-discnt-type = 'строка':U
      .
      v-doc-type = if p-doc-kind = 'vir':U then 'рас':U else 'спи':U.
    end.
  END CASE.
  if p-cli-type <> "" and p-cli-code > 0 then do:
    for first buf_clients no-lock where buf_clients.obj-type = p-cli-type
                                    and buf_clients.obj-code = p-cli-code
    :
      assign
        v-cli-type = buf_clients.obj-type
        v-cli-code = buf_clients.obj-code
        v-cli-name = buf_clients.obj-name
      .
    end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf_main_trn-doc.base-rate
,input buf_main_trn-doc.base-scale
,input v-cli-code
,input v-cli-type
,input v-cli-name
,input buf_main_trn-doc.cr-db-num
,input g#userid
,input v-discnt-type
,input p-doc-code
,input buf_main_trn-doc.doc-date
,input v-doc-type
,input no
,input buf_main_trn-doc.host-code
,input v-internal
,input buf_main_trn-doc.obj-code
,input buf_main_trn-doc.obj-type
,input buf_main_trn-doc.office
,input v-pay-code
,input v-ps
,input no
,input ?
,input v-status
,input ?
,input v-ext-doc-type
,input v-purch-code
) no-error
.
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации автодокумента вида &5 для продажи &4:&1&2 &3"
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , p-doc-kind
                      ).
    undo _main, return error v-mes.
  end.
  find buf_trn-doc where buf_trn-doc.doc-code = p-doc-code.
  assign
    buf_trn-doc.fact-date  = buf_main_trn-doc.fact-date
    buf_trn-doc.shift-date = buf_main_trn-doc.shift-date
    buf_trn-doc.shift-num  = buf_main_trn-doc.shift-num
    buf_trn-doc.shift-name = buf_main_trn-doc.shift-name
    buf_trn-doc.exch-code  = buf_main_trn-doc.exch-code
    buf_trn-doc.exch-rate  = buf_main_trn-doc.exch-rate
    buf_trn-doc.exch-scale = buf_main_trn-doc.exch-scale
    buf_trn-doc.print-rubl = buf_main_trn-doc.print-rubl
    buf_trn-doc.out-code   = buf_main_trn-doc.doc-code
    buf_trn-doc.office     = (if p-office = 'у':U then yes else no)
    buf_main_trn-doc.out-code = (if (p-doc-kind = 'rs':U and p-office = 'т':U) then buf_trn-doc.doc-code else buf_main_trn-doc.out-code)
    buf_trn-doc.wrkr = buf_main_trn-doc.wrkr
    buf_trn-doc.agnt = buf_main_trn-doc.agnt
    buf_trn-doc.boss = buf_main_trn-doc.boss
  .
  if p-doc-kind = 'swo':U or
     p-doc-kind = 'trf':U
  then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_trn-doc.doc-code ,
                       input 'othermoves':U ,
                       input yes ) no-error .
  end.
  run saledoc-create  in this-procedure (
                                           input buf_main_trn-doc.doc-code
                                          ,input buf_main_trn-doc.host-code
                                          ,input buf_main_trn-doc.obj-type
                                          ,input buf_main_trn-doc.obj-code
                                          ,input p-doc-kind
                                          ,input p-office
                                          ,input no
                                          ,input '':U
                                          ,input '':U
                                          ,input 0
                                          ,buffer buf_trn-doc ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 во временную таблицу:&1&2 &3"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  , buf_main_trn-doc.doc-code
                                  , p-doc-kind
                                  ).
  end.
end.
