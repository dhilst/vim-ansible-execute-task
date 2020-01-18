" Executes the selected text as an ansible task. The command
" is gathered from g:ansible_execute_task_command. The responsibity
" of selecting the right amout of text is to the user, the selected
" text is copied to a temporary file and g:ansible_exexute_task_command
" is executed by replacing $FILE substring by the temporary file created
" before.
function s:AnsibleExecuteTask() range abort
    silent! normal gvy
    let tempname = tempname()
    let lines = split(@", '\n')
    let res = writefile(lines, tempname)
    if res == -1
      throw "writefile failed " . tempname
    endif
    let command = substitute(g:ansible_execute_task_command, "$FILE", tempname, "")
    try
      execute "!".command
    finally
      silent! execute "!rm -f ".tempname
    endtry
endfunction
command! -range AnsibleExecuteTask :call <SID>AnsibleExecuteTask()

" Executes the current file by replacing $FILE in
" g:ansible_execute_task_command to the current opened
" buffer
function s:AnsibleExecuteFile(file) abort
    let command = substitute(g:ansible_execute_task_command, "$FILE", a:file, "")
    execute "!".command
endfunction
command! AnsibleExecuteFile :call <SID>AnsibleExecuteFile(expand("%:p"))

" Executes the opened playbook
function s:AnsibleExecutePlaybook(playbook) abort
    let command = substitute(g:ansible_execute_playbook_command, "$FILE", a:playbook, "")
    execute "!".command
endfunction
command! AnsibleExecutePlaybook :call <SID>AnsibleExecutePlaybook(expand("%:p"))

vnoremap <Plug>AnsibleExecuteTask      <ESC>:AnsibleExecuteTask<CR>
nnoremap <Plug>AnsibleExecuteFile      :AnsibleExecuteFile<CR>
nnoremap <Plug>AnsibleExecutePlaybook  :AnsibleExecutePlaybook<CR>
