if exists('b:vim_ansible_execute_task')
    finish
endif
let b:vim_ansible_execute_task = 1

func! s:findbuf(bufpat) abort
  redir @o
  silent! ls
  redir END
  let buffers = split(@o, "\n")
  let found = -1
python3 <<EOF
import re
from shlex import split as shsplit

bufpat = vim.eval("a:bufpat")
buffers = vim.eval("buffers")
buffers = map(shsplit, buffers)
buffers = [(v[0], v[2]) for v in buffers]
for id_, name  in buffers:
  if re.search(bufpat, name) is not None:
    vim.command(f"let found = {id_}")
    break
EOF
  return found
endfunc

func! s:call_in_term(command) abort
  let bufid = s:findbuf(a:command)
  if bufid != -1
    try
      execute "bdelete! ".bufid
    catch /No buffers were deleted/
    endtry
  endif
  split a:command
  startinsert
  call termopen(a:command)
endfunc

" Executes the selected text as an ansible task. The command
" is gathered from g:ansible_execute_task_command. The responsibity
" of selecting the right amout of text is to the user, the selected
" text is copied to a temporary file and g:ansible_exexute_task_command
" is executed by replacing $FILE substring by the temporary file created
" before.
function s:AnsibleExecuteTask() range abort
    silent! normal gvy
    let lines = split(@", '\n')
    let fname = "/tmp/vim-ansible-execute-task.vim.data"
    let res = writefile(lines, fname)
    if res == -1
      throw "writefile error ".res
    end
" Copy templates files to /tmp/template prior executing templates
python3 <<EOF
import shutil, yaml, os, sys
from pathlib import Path
lines = vim.eval('@"')
data = yaml.safe_load(lines)
playpath = Path(vim.eval('expand("%:p:h")'))
if data is not None and isinstance(data, list) and data:
  for task in data:
    src = task.get("template", {}).get("src")
    if src is not None:
      path = playpath / '../../templates' / src
      if not path.exists():
        path.mkdir(parents=True)
      try:
        shutil.copyfile(str(path), Path("/tmp/templates") / src)
      except:
        pass
    include_tasks = task.get("include_tasks")
    if include_tasks is not None:
      try:
        shutil.copyfile(playpath/ include_tasks, Path("/tmp") / include_tasks)
      except:
        pass
EOF
    let command = substitute(g:ansible_execute_task_command, "$FILE", fname, "")
    call s:call_in_term(command)
endfunction
command! -range AnsibleExecuteTask :call <SID>AnsibleExecuteTask()

" Executes the current file by replacing $FILE in
" g:ansible_execute_task_command to the current opened
" buffer
function s:AnsibleExecuteFile(file) abort
    let command = substitute(g:ansible_execute_task_command, "$FILE", a:file, "")
    call s:call_in_term(command)
endfunction
command! AnsibleExecuteFile :call <SID>AnsibleExecuteFile(expand("%:p"))

" Executes the opened playbook
function s:AnsibleExecutePlaybook(playbook) abort
    let command = substitute(g:ansible_execute_playbook_command, "$FILE", a:playbook, "")
    call s:call_in_term(command)
endfunction
command! AnsibleExecutePlaybook :call <SID>AnsibleExecutePlaybook(expand("%:p"))

vnoremap <Plug>AnsibleExecuteTask      <ESC>:AnsibleExecuteTask<CR>
nnoremap <Plug>AnsibleExecuteFile      :AnsibleExecuteFile<CR>
nnoremap <Plug>AnsibleExecutePlaybook  :AnsibleExecutePlaybook<CR>
