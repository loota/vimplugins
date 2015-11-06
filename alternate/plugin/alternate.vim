" TODO clobbers registers, moves cursor and other evilness
"noremap \\ :let hns_word = '<C-r><C-w>'<Cr>:let hns_alternative = system('php ~/script/alternate.php ' . hns_word)<Cr>ciW<C-r>=hns_alternative<Cr><Esc>
nnoremap \\ :call Alternate('<C-r><C-w>')<Cr>
vnoremap \\ y:call Alternate('<C-r>"')<Cr>
vnoremap \\ y:call VisualAlternate(matchstr(getline("."), '\%V.*\%V.'))<Cr>

command! -nargs=+ AlternateAddGroup call AlternateAddGroup(<f-args>)
command! -nargs=1 AlternateRemoveGroup call AlternateRemoveGroup(<f-args>)

function! AlternateAddGroup(config, group, alternatives)
    call system('alternate -a ' . shellescape(a:config) . ' ' . shellescape(a:group) . ' ' . shellescape(a:alternatives))
endfunction

function! AlternateRemoveGroup(config)
    call system('alternate -r ' . shellescape(a:config))
endfunction

function! Alternate(term)
  if a:term == 'if'
    let ifStart = search('if', 'bnc')  
    let ifEnd = search('^\s*}\s*$', 'n')  
    let lines = getline(ifStart, ifEnd)
    let alternateString = join(lines, '\n')
    let alternated = system('alternate ' . shellescape(a:term) . ' ' . shellescape(alternateString))
    exe ifStart . ',' . ifEnd . 'd' 
		let hns_registerA = getreg('a', 1)
		let hns_registerAMode = getregtype('a')
    call setreg('a', alternated)
    silent exe 'norm "aP'
    call setreg('a', hns_registerA, hns_registerAMode)
    return alternated
  endif

  let alternated = system('alternate ' . shellescape(a:term))
  if alternated == 'ALTERNATE_DELETE'
    call setline(".", substitute(getline("."), ' \?\w*\%' . col(".") . 'c\w*', '', ''))
  elseif alternated != ''
    call setline(".", substitute(getline("."), '\w*\%' . col(".") . 'c\w*', escape(alternated, '$'), ''))
  endif

  if alternated != ''
    let currentCharacter = CurrentCharacter()
    if currentCharacter !~ '\w'
      norm ge
    endif
    return alternated
  endif
endfunction

function! CurrentCharacter()
    return matchstr(getline("."), '.', getpos(".")[2]-1)
endfunction

function! VisualAlternate(term)
  let alternated = system('alternate ' . shellescape(a:term))
  echo "." . alternated
  if alternated != ''
    if alternated == 'ALTERNATE_DELETE'
      call setline(".", substitute(getline("."), ' \%V.*\%V.', '', ''))
    else
      call setline(".", substitute(getline("."), '\%V.*\%V.', escape(alternated, '$'), ''))
    endif
  endif
  return alternated
endfunction
