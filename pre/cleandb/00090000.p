block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 08/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00090000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/0009000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter varcall-back           as handle no-undo.
define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.
define buffer buf_clients for ub.clients.
find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
define variable is-del as logical   no-undo .
define buffer trn-doc             for ub.trn-doc.
define buffer fin-ob              for ub.fin-ob.
define buffer buf_fin-ob          for ub.fin-ob.
define buffer fin-ob-before       for ub.fin-ob-before.
define buffer buf_fin-ob-before   for ub.fin-ob-before.
define buffer fin-doc             for ub.fin-doc.
define buffer buf_fin-doc         for ub.fin-doc.
define buffer fin-statement       for ub.fin-statement.
define buffer buf_fin-statement   for ub.fin-statement.
DEFINE temp-table temp-del-yes no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY host-code doc-code type
.
DEFINE temp-table temp-del-no no-undo
  field host-code  as integer
  field doc-code   as character
  field type       as integer
  INDEX pi IS PRIMARY host-code doc-code type
.
DEFINE temp-table temp-cur no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY host-code doc-code type
.
on delete of ub.fin-ob             override do: end.
on delete of ub.fin-ob-before      override do: end.
on delete of ub.fin-doc            override do: end.
on delete of ub.fin-statement      override do: end.
for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
for each fin-ob no-lock where
         fin-ob.host-code = buf_clients.host-code
     and fin-ob.doc-date  < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  assign is-del = no .
  if fin-ob.fact-date < vardate-actual-docs then do:
    assign is-del = yes .
    if fin-ob.con-stat < 2 then
    do:
      if fin-ob.con-stat = 0  then
        assign is-del = yes .
      else assign is-del = no .
    end.
    else do:
      run CheckDel ( input fin-ob.host-code, input fin-ob.doc-code, input 0 , output is-del ) .
      if is-del = yes then do:
        for each temp-cur :
          find first temp-del-yes where
                     temp-del-yes.host-code = temp-cur.host-code and
                     temp-del-yes.doc-code  = temp-cur.doc-code  and
                     temp-del-yes.type      = temp-cur.type no-error .
          if not available temp-del-yes then do:
             create temp-del-yes.
             BUFFER-COPY temp-cur TO temp-del-yes no-error .
          end.
          delete temp-cur .
        end.
      end.
      else do:
        for each temp-cur :
          find first temp-del-no where
                     temp-del-no.host-code = temp-cur.host-code and
                     temp-del-no.doc-code  = temp-cur.doc-code  and
                     temp-del-no.type      = temp-cur.type no-error .
          if not available temp-del-no then do:
            create temp-del-no.
            BUFFER-COPY temp-cur TO temp-del-no no-error .
          end.
          delete temp-cur .
        end.
      end.
    end.
  end.
  if is-del then do:
    run cleanFinOb in this-procedure.
    find first buf_fin-ob exclusive-lock where
           recid(buf_fin-ob) = recid(fin-ob) no-error no-wait.
if not avail buf_fin-ob then
do:
  undo, return error "Ошибка удаления fin-ob. Запись занята другим пользователем.".
end.
delete buf_fin-ob.
vDeleted = vDeleted + 1.
  end.
end.
for each fin-ob-before no-lock where
         fin-ob-before.host-code = buf_clients.host-code
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  if fin-ob-before.status_ = 'факт':U or fin-ob-before.doc-code <> ""  then
  do:
    find first trn-doc no-lock where trn-doc.doc-code = fin-ob-before.trn-doc-code no-error .
    if not available trn-doc then
    do:
      run cleanFinObBefore in this-procedure.
      find first buf_fin-ob-before exclusive-lock where
           recid(buf_fin-ob-before) = recid(fin-ob-before) no-error no-wait.
if not avail buf_fin-ob-before then
do:
  undo, return error "Ошибка удаления fin-ob-before. Запись занята другим пользователем.".
end.
delete buf_fin-ob-before.
vDeleted = vDeleted + 1.
    end.
  end.
end.
for each fin-doc no-lock where
         fin-doc.host-code = buf_clients.host-code
     and fin-doc.doc-date  < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  assign is-del = no .
  if fin-doc.fact-date < vardate-actual-docs then do:
    if fin-doc.con-stat < 2 then assign is-del = no .
    else do:
      find first temp-del-yes where
                 temp-del-yes.host-code = fin-doc.host-code
              and temp-del-yes.doc-code  = string(fin-doc.fin-doc-code)
              and temp-del-yes.type      = 1
      no-error .
      if available temp-del-yes then is-del = yes .
    end.
  end.
  if is-del then do :
    run cleanFinDoc in this-procedure.
    find first buf_fin-doc exclusive-lock where
           recid(buf_fin-doc) = recid(fin-doc) no-error no-wait.
if not avail buf_fin-doc then
do:
  undo, return error "Ошибка удаления fin-doc. Запись занята другим пользователем.".
end.
delete buf_fin-doc.
vDeleted = vDeleted + 1.
  end.
end.
for each fin-statement no-lock where
         fin-statement.host-code = buf_clients.host-code
     and fin-statement.doc-date  < vardate-actual-docs
     and fin-statement.fact-date < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  run cleanFinStatement in this-procedure.
  find first buf_fin-statement exclusive-lock where
           recid(buf_fin-statement) = recid(fin-statement) no-error no-wait.
if not avail buf_fin-statement then
do:
  undo, return error "Ошибка удаления fin-statement. Запись занята другим пользователем.".
end.
delete buf_fin-statement.
vDeleted = vDeleted + 1.
end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Финансовые док-ты и обязательства с историей", vDeleted).
return vResult.
procedure CheckDel :
  do on error undo, return error return-value :
    define input  parameter p-host-code as integer   no-undo .
    define input  parameter p-doc-code  as character no-undo .
    define input  parameter p-type      as integer   no-undo .
    define output parameter p-is-del    as logical   no-undo .
    define buffer bf_fin-ob   for ub.fin-ob .
    define buffer bf_fin-doc  for ub.fin-doc .
    define buffer fin-connect for ub.fin-connect.
    assign p-is-del = yes .
    find first temp-cur where
      temp-cur.host-code = p-host-code and
      temp-cur.doc-code  = p-doc-code  and
      temp-cur.type      = p-type     no-error .
      if  not available  temp-cur then do:
          create temp-cur .
          assign
            temp-cur.host-code = p-host-code
            temp-cur.doc-code  = p-doc-code
            temp-cur.type      = p-type
          .
    end.
    find first temp-del-yes
      where temp-del-yes.host-code = p-host-code
        and temp-del-yes.doc-code  = p-doc-code
        and temp-del-yes.type      = p-type
    no-error .
    if available temp-del-yes then do:
      assign p-is-del = yes .
      return .
    end.
    find first temp-del-no
      where temp-del-no.host-code = p-host-code
        and temp-del-no.doc-code  = p-doc-code
        and temp-del-no.type      = p-type
    no-error .
    if available temp-del-no then do:
      assign p-is-del = no .
      return .
    end.
    if p-type = 0 then do:
      for each fin-connect no-lock
        where fin-connect.host-code   = p-host-code
          and fin-connect.fin-ob-code = p-doc-code
        :
        find first bf_fin-doc no-lock
          where bf_fin-doc.host-code    = fin-connect.host-code
            and bf_fin-doc.fin-doc-code = fin-connect.fin-doc-code
        no-error .
        if available bf_fin-doc then do:
          if ( bf_fin-doc.con-stat = 1  ) or bf_fin-doc.fact-date >= vardate-actual-docs then do:
            assign p-is-del = no .
            return  .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = string(bf_fin-doc.fin-doc-code) and
                       temp-cur.type = 1
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-doc.fin-doc-code, input 1 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
    else do:
      for each fin-connect no-lock
        where fin-connect.host-code   = p-host-code
          and fin-connect.fin-doc-code = integer (p-doc-code)
        :
        find first bf_fin-ob no-lock
          where bf_fin-ob.host-code = fin-connect.host-code
            and bf_fin-ob.doc-code  = fin-connect.fin-ob-code
        no-error .
        if available bf_fin-ob then do:
          if ( bf_fin-ob.con-stat = 1 and bf_fin-ob.fact-date < vardate-actual-docs ) or bf_fin-ob.fact-date >= vardate-actual-docs then do:
            assign p-is-del = no .
            return .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = bf_fin-ob.doc-code and
                       temp-cur.type = 0
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-ob.doc-code, input 0 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cleanFinOb:
    define buffer fin-connect         for ub.fin-connect  .
    define buffer c-fin-connect       for ub.c-fin-connect.
    on delete of ub.fin-connect override do: end.
    on delete of ub.c-fin-connect override do: end.
    for each fin-connect no-lock
       where fin-connect.host-code   = fin-ob.host-code
         and fin-connect.fin-ob-code = fin-ob.doc-code
    :
      for each c-fin-connect no-lock
         where c-fin-connect.host-code    = fin-connect.host-code
           and c-fin-connect.connect-code = fin-connect.connect-code
      :
        delete fin-connect.
        vDeleted = vDeleted + 1.
      end.
      delete fin-connect.
      vDeleted = vDeleted + 1.
    end.
    define buffer fin-ob-attr for ub.fin-ob-attr.
on delete of ub.fin-ob-attr override do: end.
for each fin-ob-attr exclusive-lock
    where fin-ob-attr.host-code = fin-ob.host-code
         and fin-ob-attr.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete fin-ob-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer fin-ob-tax for ub.fin-ob-tax.
on delete of ub.fin-ob-tax override do: end.
for each fin-ob-tax exclusive-lock
    where fin-ob-tax.host-code = fin-ob.host-code
         and fin-ob-tax.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete fin-ob-tax no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer fin-ob-tax-attr for ub.fin-ob-tax-attr.
on delete of ub.fin-ob-tax-attr override do: end.
for each fin-ob-tax-attr exclusive-lock
    where fin-ob-tax-attr.host-code = fin-ob.host-code
         and fin-ob-tax-attr.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete fin-ob-tax-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer fin-gds-part for ub.fin-gds-part.
on delete of ub.fin-gds-part override do: end.
for each fin-gds-part exclusive-lock
    where fin-gds-part.host-code = fin-ob.host-code
         and fin-gds-part.fin-ob-code  = fin-ob.doc-code
on error undo, return error
:
      delete fin-gds-part no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer fin-gds-part-attr for ub.fin-gds-part-attr.
on delete of ub.fin-gds-part-attr override do: end.
for each fin-gds-part-attr exclusive-lock
    where fin-gds-part-attr.host-code = fin-ob.host-code
         and fin-gds-part-attr.fin-ob-code  = fin-ob.doc-code
on error undo, return error
:
      delete fin-gds-part-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer fin-ob-trn          for ub.fin-ob-trn.
    on delete of ub.fin-ob-trn override do: end.
    for each fin-ob-trn no-lock
       where fin-ob-trn.host-code = fin-ob.host-code
         and fin-ob-trn.doc-code  = fin-ob.doc-code
    :
      find first trn-doc no-lock where trn-doc.doc-code = fin-ob-trn.trn-doc-code no-error .
      if available trn-doc then next .
      delete fin-ob-trn.
      vDeleted = vDeleted + 1.
    end.
    define buffer c-fin-ob for ub.c-fin-ob.
on delete of ub.c-fin-ob override do: end.
for each c-fin-ob exclusive-lock
    where c-fin-ob.host-code = fin-ob.host-code
         and c-fin-ob.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete c-fin-ob no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-fin-ob-attr for ub.c-fin-ob-attr.
on delete of ub.c-fin-ob-attr override do: end.
for each c-fin-ob-attr exclusive-lock
    where c-fin-ob-attr.host-code = fin-ob.host-code
         and c-fin-ob-attr.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete c-fin-ob-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-fin-ob-tax for ub.c-fin-ob-tax.
on delete of ub.c-fin-ob-tax override do: end.
for each c-fin-ob-tax exclusive-lock
    where c-fin-ob-tax.host-code = fin-ob.host-code
         and c-fin-ob-tax.doc-code  = fin-ob.doc-code
on error undo, return error
:
      delete c-fin-ob-tax no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-fin-gds-part for ub.c-fin-gds-part.
on delete of ub.c-fin-gds-part override do: end.
for each c-fin-gds-part exclusive-lock
    where c-fin-gds-part.host-code = fin-ob.host-code
         and c-fin-gds-part.fin-ob-code  = fin-ob.doc-code
on error undo, return error
:
      delete c-fin-gds-part no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
procedure cleanFinObBefore:
  define buffer fin-ob-tax-before for ub.fin-ob-tax-before.
on delete of ub.fin-ob-tax-before override do: end.
for each fin-ob-tax-before exclusive-lock
     where fin-ob-tax-before.host-code   = fin-ob-before.host-code
        and fin-ob-tax-before.before-code = fin-ob-before.before-code
on error undo, return error
:
      delete fin-ob-tax-before no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
procedure cleanFinDoc:
  define buffer fin-doc-attr for ub.fin-doc-attr.
on delete of ub.fin-doc-attr override do: end.
for each fin-doc-attr exclusive-lock
    where fin-doc-attr.host-code    = fin-doc.host-code
       and fin-doc-attr.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete fin-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fin-doc-tax for ub.fin-doc-tax.
on delete of ub.fin-doc-tax override do: end.
for each fin-doc-tax exclusive-lock
    where fin-doc-tax.host-code    = fin-doc.host-code
       and fin-doc-tax.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete fin-doc-tax no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fin-doc-tax-attr for ub.fin-doc-tax-attr.
on delete of ub.fin-doc-tax-attr override do: end.
for each fin-doc-tax-attr exclusive-lock
    where fin-doc-tax-attr.host-code    = fin-doc.host-code
       and fin-doc-tax-attr.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete fin-doc-tax-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fin-doc-obj for ub.fin-doc-obj.
on delete of ub.fin-doc-obj override do: end.
for each fin-doc-obj exclusive-lock
    where fin-doc-obj.host-code    = fin-doc.host-code
       and fin-doc-obj.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete fin-doc-obj no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-doc for ub.c-fin-doc.
on delete of ub.c-fin-doc override do: end.
for each c-fin-doc exclusive-lock
    where c-fin-doc.host-code    = fin-doc.host-code
       and c-fin-doc.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete c-fin-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-doc-attr for ub.c-fin-doc-attr.
on delete of ub.c-fin-doc-attr override do: end.
for each c-fin-doc-attr exclusive-lock
    where c-fin-doc-attr.host-code    = fin-doc.host-code
       and c-fin-doc-attr.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete c-fin-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-doc-tax for ub.c-fin-doc-tax.
on delete of ub.c-fin-doc-tax override do: end.
for each c-fin-doc-tax exclusive-lock
    where c-fin-doc-tax.host-code    = fin-doc.host-code
       and c-fin-doc-tax.fin-doc-code = fin-doc.fin-doc-code
on error undo, return error
:
      delete c-fin-doc-tax no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
procedure cleanFinStatement:
  define buffer fin-statement-attr for ub.fin-statement-attr.
on delete of ub.fin-statement-attr override do: end.
for each fin-statement-attr exclusive-lock
    where fin-statement-attr.host-code = fin-statement.host-code
       and fin-statement-attr.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete fin-statement-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fin-statement-line for ub.fin-statement-line.
on delete of ub.fin-statement-line override do: end.
for each fin-statement-line exclusive-lock
    where fin-statement-line.host-code = fin-statement.host-code
       and fin-statement-line.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete fin-statement-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fin-statement-line-attr for ub.fin-statement-line-attr.
on delete of ub.fin-statement-line-attr override do: end.
for each fin-statement-line-attr exclusive-lock
    where fin-statement-line-attr.host-code = fin-statement.host-code
       and fin-statement-line-attr.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete fin-statement-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-statement for ub.c-fin-statement.
on delete of ub.c-fin-statement override do: end.
for each c-fin-statement exclusive-lock
    where c-fin-statement.host-code = fin-statement.host-code
       and c-fin-statement.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete c-fin-statement no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-statement-attr for ub.c-fin-statement-attr.
on delete of ub.c-fin-statement-attr override do: end.
for each c-fin-statement-attr exclusive-lock
    where c-fin-statement-attr.host-code = fin-statement.host-code
       and c-fin-statement-attr.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete c-fin-statement-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fin-statement-line for ub.c-fin-statement-line.
on delete of ub.c-fin-statement-line override do: end.
for each c-fin-statement-line exclusive-lock
    where c-fin-statement-line.host-code = fin-statement.host-code
       and c-fin-statement-line.sttm-code = fin-statement.sttm-code
on error undo, return error
:
      delete c-fin-statement-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
