func! s:call_in_term(cmd)
  split
  wincmd j
  enew
  call termopen(a:cmd)
endfun

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
    let command = substitute(g:ansible_execute_task_command, "$FILE", fname, "")
    call s:call_in_term(command)
endfunction
command! -range AnsibleExecuteTask :call <SID>AnsibleExecuteTask()

" Executes the current file by replacing $FILE in
" g:ansible_execute_task_command to the current opened
" buffer
function s:AnsibleExecuteFile(file) abort
    let command = substitute(g:ansible_execute_task_command, "$FILE", a:file, "")
    call s:_call_in_term(command)
endfunction
command! AnsibleExecuteFile :call <SID>AnsibleExecuteFile(expand("%:p"))

" Executes the opened playbook
function s:AnsibleExecutePlaybook(playbook) abort
    let command = substitute(g:ansible_execute_playbook_command, "$FILE", a:playbook, "")
    call s:_call_in_term(command)
endfunction
command! AnsibleExecutePlaybook :call <SID>AnsibleExecutePlaybook(expand("%:p"))

vnoremap <Plug>AnsibleExecuteTask      <ESC>:AnsibleExecuteTask<CR>
nnoremap <Plug>AnsibleExecuteFile      :AnsibleExecuteFile<CR>
nnoremap <Plug>AnsibleExecutePlaybook  :AnsibleExecutePlaybook<CR>
