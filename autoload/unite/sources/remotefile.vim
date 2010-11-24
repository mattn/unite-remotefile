let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'remotefile',
      \ }

function! s:unite_source.gather_candidates(args, context)
  return map(unite#sources#remotefile#remotefiles(), '{
        \ "word": v:val,
        \ "source": "remotefile",
        \ "kind": "file",
        \ "action__path": v:val,
        \ }')
endfunction

function! unite#sources#remotefile#remotefiles()
  let list = []
  for server in split(serverlist(), "\n")
    if server != v:servername
      try
        let list += eval(remote_expr(server, "string(unite#sources#remotefile#files())"))
      catch /^Vim\%((\a\+)\)\=:E449/
      endtry
    endif
  endfor
  return list
endfunction

function! unite#sources#remotefile#files()
  let files = ""
  redir => files
  silent files
  redir END
  let list = []
  for line in split(files, '\n')
    call add(list, expand('#'.split(line, '\s')[0].':p'))
  endfor
  return list
endfunction

function! unite#sources#remotefile#define()
  return has('clientserver') ? s:unite_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo