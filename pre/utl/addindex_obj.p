block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addindex_obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/addindex_obj.p $":U .
define variable vss-description as character no-undo init "Все таблицы с Host-code obj-type obj-code".
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
define buffer buf-_Field for ub._Field  .
define temp-table temp-t no-undo
field nametable as character
field namefield as character
field namefield2 as character
index pi nametable namefield
.
define temp-table temp-i no-undo
field nametable as character
field namefield as character
field nameindex as character
index pi nametable namefield nameindex
.
define stream outstrim.
output stream outstrim to value("c:\ttable.df") .
 run proc-obj.
 run proc-host.
 run proc-host-other.
 run proc-obj-other.
output stream outstrim close.
procedure proc-obj :
  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.
define buffer buf1_Field for ub._Field  .
for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'obj-type'
        no-error .
   find first buf1_Field no-lock of _File
        where buf1_Field._Field-Name = 'obj-code'
        no-error .
    if available _Field and available  buf1_Field then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .
          for each _index no-lock of _file  :
            for each  _index-field no-lock of _index  :
                find first buf-_field no-lock of _index-field no-error .
                if buf-_Field._Field-Name = 'obj-type' then do:
                    create temp-i .
                      assign
                        temp-i.nametable = _File._File-Name
                        temp-i.namefield = _Field._Field-Name
                        temp-i.nameindex = _index._index-name
                      .
                    leave.
                end.
                else do:
                    leave.
                end.
            end.
          end.
   end.
   end.
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :
    put stream outstrim unformatted
      substitute('ADD INDEX &2auto_obj&2 ON &2&1&2' , temp-t.nametable , chr(34)) skip
      substitute('AREA &1Schema Area&1' , chr(34) ) skip
      'INDEX-FIELD "obj-type" ASCENDING' skip
      'INDEX-FIELD "obj-code" ASCENDING' skip " " skip .
end.
  end.
end procedure.
procedure proc-host :
  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.
for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'host-code'
        no-error .
    if available _Field  then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .
          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name = 'host-code' then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield = _Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.
   end.
   end.
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :
    put stream outstrim unformatted
       substitute('ADD INDEX &2auto_host&2 ON &2&1&2' , temp-t.nametable , chr(34)) skip
       substitute('AREA &1Schema Area&1' , chr(34) ) skip
      'INDEX-FIELD "host-code" ASCENDING' skip " " skip .
end.
  end.
end procedure.
procedure proc-host-other :
  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.
for each _File no-lock ,
   first _Field no-lock of _File
        where _Field._Field-Name <> 'host-code'
        and  index(_Field._Field-Name , 'host-code') > 0
   :
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .
          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock where
                           buf-_Field._Field-Name = _Field._Field-Name
                of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name <> 'host-code' and
                           index (buf-_Field._Field-Name, 'host-code' ) > 0
                        then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield =  buf-_Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.
   end.
  for each temp-t where
          not can-find ( first temp-i where
              temp-i.nametable = temp-t.nametable and
              temp-i.namefield = temp-t.namefield )
              :
      put stream outstrim unformatted
        substitute('ADD INDEX &2auto_host_oth&2 ON &2&1&2' , temp-t.nametable , chr(34)) skip
        substitute('AREA &1Schema Area&1' , chr(34) ) skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield, chr(34) )  skip " " skip .
  end.
end.
end procedure.
procedure proc-obj-other :
  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.
define buffer buf2_Field for ub._Field  .
define variable v-pole1 as character no-undo .
define variable v-pole2 as character no-undo .
for each _File no-lock ,
   first _Field no-lock of _File
        where _Field._Field-Name <> 'obj-type'
        and  index(_Field._Field-Name , 'obj-type') > 0
   :
      v-pole1 = _Field._Field-Name .
      v-pole2 = REPLACE ( v-pole1 ,'obj-type' ,'obj-code') .
       find first buf2_Field where buf2_Field._Field-Name = v-pole2
                  of _File no-error .
          if available  buf2_Field then do:
            message  v-pole1  v-pole2 view-as alert-box .
            next.
        end.
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
          temp-t.namefield2 = v-pole2
        .
          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock where
                           buf-_Field._Field-Name = _Field._Field-Name
                of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name <> 'obj-type' and
                           index (buf-_Field._Field-Name, 'obj-type' ) > 0
                        then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield =  buf-_Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.
   end.
  for each temp-t where
          not can-find ( first temp-i where
              temp-i.nametable = temp-t.nametable and
              temp-i.namefield = temp-t.namefield )
              :
      put stream outstrim unformatted
        substitute('ADD INDEX &2auto_obj_oth&2 ON &2&1&2' , temp-t.nametable , chr(34)) skip
        substitute('AREA &1Schema Area&1' , chr(34) ) skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield, chr(34) )  skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield2, chr(34) )  skip " " skip .
  end.
end.
end procedure.
procedure proc-cli :
  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.
define buffer buf1_Field for ub._Field  .
for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'cli-type'
        no-error .
   find first buf1_Field no-lock of _File
        where buf1_Field._Field-Name = 'cli-code'
        no-error .
    if available _Field and available  buf1_Field then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .
          for each _index no-lock of _file  :
            for each  _index-field no-lock of _index  :
                find first buf-_field no-lock of _index-field no-error .
                if buf-_Field._Field-Name = 'cli-type' then do:
                    create temp-i .
                      assign
                        temp-i.nametable = _File._File-Name
                        temp-i.namefield = _Field._Field-Name
                        temp-i.nameindex = _index._index-name
                      .
                    leave.
                end.
                else do:
                    leave.
                end.
            end.
          end.
   end.
   end.
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :
    put stream outstrim unformatted
      substitute('ADD INDEX &2auto_cli&2 ON &2&1&2' , temp-t.nametable , chr(34)) skip
      substitute('AREA &1Schema Area&1' , chr(34) ) skip
      'INDEX-FIELD "cli-type" ASCENDING' skip
      'INDEX-FIELD "cli-code" ASCENDING' skip " " skip .
end.
  end.
end procedure.
