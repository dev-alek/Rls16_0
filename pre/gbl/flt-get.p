block-level on error undo, throw.
define input  parameter c-p              as character no-undo.
define output parameter flt-rec          as recid     no-undo .
define output parameter filter-name      as character no-undo .
define output parameter where-phrase     as character no-undo .
define output parameter sort-phrase      as character no-undo .
define output parameter where-phrase-rus as character no-undo .
define output parameter sort-phrase-rus  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: flt-get.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/flt-get.p $":U .
define variable vss-description as character no-undo init "Получение текущего значение фильтра".
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
    assign
      p-vss-parameters = substitute('&1',c-p)
    .
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
define variable c-p-name                 as character no-undo .
define variable v-enable-sorting         as logical   no-undo init yes.
function octal-to-char returns character
  ( p-string as character ) :
  define variable v-asc     as integer no-undo .
  define variable v-new-asc as integer no-undo .
  define variable ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
assign
  flt-rec = ?
.
if c-p = '':U then do:
  assign
    flt-rec      = ?
    filter-name  = ""
    where-phrase = ""
    sort-phrase  = ""
  .
end.
if num-entries(c-p, chr(4)) > 2 then do:
  assign
  v-enable-sorting = logical(entry(3, c-p, chr(4)))
  no-error
  .
end.
if num-entries(c-p, chr(4)) > 1 then do:
  assign
  c-p-name = entry(2, c-p, chr(4))
  c-p      = entry(1, c-p, chr(4))
  .
end.
find ubflt.usr-flt no-lock
  where ubflt.usr-flt.user-name  = g#userid
    and ubflt.usr-flt.call-point = c-p
  no-error.
find ubflt.filter no-lock
  where ubflt.filter.call-point = ubflt.usr-flt.call-point
    and ubflt.filter.naim       = ubflt.usr-flt.naim
  no-error.
if available ubflt.filter then do:
  assign
    flt-rec          = recid (ubflt.filter)
    filter-name      = ubflt.usr-flt.naim
    where-phrase     = ""
    sort-phrase      = ""
    where-phrase-rus = ""
    sort-phrase-rus  = ""
  .
  if num-entries(ubflt.filter.where-ysl) > 0 then do:
    assign
      where-phrase = where-phrase
                   + ' and ('
    .
    define variable ind as integer no-undo.
    do ind = 1 to num-entries(ubflt.filter.where-ysl):
      assign
        where-phrase = where-phrase
                    + " " + entry(ind, ubflt.filter.where-ysl)
      .
    end.
    assign
      where-phrase = where-phrase
                   + ')'
    .
  end.
  if num-entries(where-phrase, "^") > 1 then do:
    define variable v-new-where-phrase as character no-undo .
    assign
      v-new-where-phrase = entry(1, where-phrase, "^")
    .
    do ind = 2 to num-entries(where-phrase, "^")
    :
      define variable v-sub-phrase as character no-undo .
      assign
        v-sub-phrase = entry(ind, where-phrase, "^")
      .
      if octal-to-char(substring(v-sub-phrase, 1, 3)) <> ? then do:
        assign
          v-new-where-phrase = v-new-where-phrase
                            + octal-to-char(substring(v-sub-phrase, 1, 3))
                            + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          v-new-where-phrase = v-new-where-phrase
                            + "^"
                            + v-sub-phrase
        .
      end.
    end.
    assign
      where-phrase = v-new-where-phrase
    .
  end.
  if v-enable-sorting then do:
    do ind = 1 to num-entries(ubflt.filter.fields-sort)
    :
      if entry(ind, ubflt.filter.fields-sort) <> "" then do:
        define variable num-sort as integer no-undo.
        do num-sort = 1 to num-entries( entry(ind, ubflt.filter.fields-sort), "*")
        :
          assign
            sort-phrase = sort-phrase
                        + " by "
                        + entry( num-sort , entry(ind, ubflt.filter.fields-sort), "*")
          .
          if entry(ind, ubflt.filter.lst-cend) = '1' then do:
            assign
              sort-phrase = sort-phrase
                          + " descending"
            .
          end.
        end.
      end.
    end.
  end.
  assign
  where-phrase-rus = ubflt.filter.where-ysl-rus
  sort-phrase-rus  = (if v-enable-sorting then ubflt.filter.fields-sort-rus else "":U)
  .
end.
else do:
  assign
    flt-rec      = ?
    filter-name  = ""
    where-phrase = ""
    sort-phrase  = ""
  .
end.
