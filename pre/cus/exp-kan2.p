block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-kan2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/exp-kan2.p $":U .
define variable vss-description as character no-undo init "Экспорт текущих остатков по признакам".
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
define temp-table mapobj no-undo
field obj-type as character
field obj-code as integer
field kan-code as character
index pi is unique primary obj-type obj-code.
define variable map-str as character no-undo.
define variable c_obj-type as character no-undo.
define variable i_obj-code as integer no-undo.
define variable c_kan-code as character no-undo.
input from value(search('mapobj.txt')).
repeat:
  import unformatted map-str.
  assign
  c_obj-type = entry(1, entry(1, map-str, ';'), ',')
  i_obj-code = integer(entry(2, entry(1, map-str, ';'), ','))
  c_kan-code = entry(2, map-str, ';') no-error.
  if error-status:error then do:
      message "Ошибка при чтении файла mapobj.txt" view-as alert-box error.
      return.
  end.
  create mapobj.
  assign
  mapobj.obj-type = c_obj-type
  mapobj.obj-code = i_obj-code
  mapobj.kan-code = c_kan-code.
end.
input close.
define stream txt.
define variable file-name as char no-undo.
define variable obj as char no-undo.
define variable simv as char no-undo.
define variable prt-name as char no-undo.
define variable glog as logical no-undo .
glog = no.
message "Экспорт остатков в файл." skip (2)
        "Продолжать ?"
       view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.
system-dialog get-file file-name
  TITLE "Выберите файл для экспорта"
  filters " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "         "*.*"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "txt".
if not glog then return.
if trim(file-name) = "" then do:
     message "Не задан файл для экспорта". pause.
     return.
end.
output stream txt to value (file-name) no-echo.
put stream txt  unformatted
    "SHOP ID;DATE;INDEX-COLOR-SIZE;QUANTITY"
skip.
FIND FIRST sys-ctrl No-LOCK.
FIND FIRST db no-LOCK where
           db.db-num = sys-ctrl.db-num.
for each clients where
    clients.db-num = db.db-num no-lock:
    if clients.obj-type = "маг" then  obj = "R".
    else  obj = "W".
    for each prt-obj no-lock where
                     prt-obj.obj-type  = clients.obj-type
               and prt-obj.obj-code  = clients.obj-code
               and prt-obj.is-term    = yes
               and prt-obj.fact-qnty  <> 0
              use-index pi :
              display
                  prt-obj.obj-type
                  prt-obj.obj-code
                  prt-obj.artic
                with frame ff view-as dialog-box
              title ": Остатки по товарам ".
              pause 0.
              find first mapobj no-lock where mapobj.obj-type = prt-obj.obj-type
                                               and mapobj.obj-code = prt-obj.obj-code no-error.
              if available mapobj then obj = mapobj.kan-code.
              else obj = obj + string(prt-obj.obj-code, "99").
              find gds-prt where gds-prt.node-code = prt-obj.prt-code no-lock no-error.
              if not avail gds-prt then next.
              prt-name = gds-prt.f-name.
              simv  = "-".
              if  r-index(prt-name, "/") > 0 then overlay ( prt-name, r-index(prt-name, "/"), 1) = simv.
              else next.
              put stream txt  unformatted
                  trim(string(obj)) + ";" +
                  trim(string(year(today), "9999")) + "-" +
                  trim(string(month(today), "99")) + "-" +
                  trim(string(DAY(today), "99")) + ";" +
                  trim(string(prt-obj.artic)) + "-" +
                  trim(string(prt-name)) + ";" +
                  trim(string(prt-obj.fact-qnty))
              skip.
    end.
end.
output close.
message "Экспорт в файл закончен.".
