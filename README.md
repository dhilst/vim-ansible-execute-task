# Overview

This plugin let you to execute arbitrary ansible tasks by selecting
a block, running the current file, being it a playbook or a
tasks file.

[![asciicast](https://asciinema.org/a/ezgOAViHxSNOjPaNf8vDhEqRx.svg)](https://asciinema.org/a/ezgOAViHxSNOjPaNf8vDhEqRx)

# Installation

[vim-plug](https://github.com/junegunn/vim-plug) is recommended, in this case
just place the bellow in vim-plug block, between call plug#begin(...) and call
plug#end()

`plug 'dhilst/vim-ansible-execute-task'`

restart vim and run `:pluginstall`

# Configuration

This plugin provides commands to execute ansible tasks in various ways. It makes possible
to execute a single task by selecting it.

Before begin define the following variables in your .vimrc

    let g:ansible_execute_task_command = "ansible -m include_tasks -a $FILE all"
    let g:ansible_execute_playbook_command = "ansible-playbook -v $FILE"

$FILE will be replaced by a file contaning the selected contents/file/playbook before
the command is run. You're free to put anything in there as long as it works for you.

I have other examples here:

    let g:ansible_execute_task_command = "ansible-playbook -v test/include_tasks.yaml -i inventory/test_hosts -e file=$FILE"
    let g:ansible_execute_playbook_command = "ansible-playbook -v $FILE -i inventory/test_hosts --limit ansible-test1"

`g:ansible_execute_task_command` is used by [AnsibleExecuteTask](ansibleexecutetask) command to
execute the selected text. It works by coping the selectec block to a temporary
file and executing the command replacing `$FILE` mark by the temporary file.

When running [AnsibleExecuteFile](ansibleexecutefile) the same strategy is used by there is no temporary
file, the current buffer is passed to `g:ansible_execute_task_command` as it is.

Now `g:ansible_execute_playbook_command` is used to run full playbooks, that
one with `hosts` and `vars` sections, beside `tasks`. This variable is used by
[AnsibleExecutePlaybook](ansibleexecuteplaybook) command to execute the playbook.

# Commands

## AnsibleExecuteTask

Use this command to run single or mulitple tasks (next each other). Is very
handy during development to execute the single task that you're editing.

First use <C-v> to select the task that you want to run, then call
AnsibleExecuteTask command.

## AnsibleExecuteFile

Execute the current buffer in by replacing $FILE in g:ansigle_execute_task by
the absolute file path.

## AnsibleExecutePlaybook

Execute the current file as a playbook. The current file absolute path is
replaced in g:ansible_execute_playbook_command


# Mappings

    vnoremap <Plug>(AnsibleExecuteTask) <ESC>:AnsibleExecuteTask<CR>
    nnoremap <Plug>(AnsibleExecuteFile) :AnsibleExecuteFile<CR>
    nnoremap <Plug>(AnsibleExecutePlaybook) :AnsibleExecutePlaybook<CR>

To map it to <F7>, <F8>, <F9> add the bellow to your `.vimrc`

    au FileType yaml,yaml.ansible vmap <buffer> <F7> <Plug>AnsibleExecuteTask
    au FileType yaml.ansible      nmap <buffer> <F8> <Plug>AnsibleExecuteFile
    au FileType yaml              nmap <buffer> <F9> <Plug>AnsibleExecutePlaybook

