call plug#begin()

Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

Plug 'nanotee/zoxide.vim'

Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'windwp/nvim-autopairs'
Plug 'wakatime/vim-wakatime'
Plug 'lambdalisue/vim-suda'

Plug 'mbbill/undotree'

call plug#end()

set number
set relativenumber

highlight CocFloating ctermbg=black

colorscheme catppuccin-mocha

set tabstop=4
set shiftwidth=4
set expandtab

let g:rustfmt_autosave = 1

lua << EOF
require("ibl").setup()
require("nvim-autopairs").setup {}
EOF

cnoreabbrev sudow SudaWrite

nnoremap <C-t> :Ex<CR>
nnoremap <F5> :UndotreeToggle<CR>
nnoremap J :m .+1<CR>==
nnoremap K :m .-2<CR>==
nnoremap <C-p> "_dP
