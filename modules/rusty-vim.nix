{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.programs.rust-vim;
in {
  options.programs.rust-vim = {
    enable = mkEnableOption "Rust development environment with Vim";

    # Supprimer openaiApiKey puisque vous utilisez Copilot
    copilotEnabled = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GitHub Copilot";
    };

    extraVimConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Vim configuration";
    };

    rustTools = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ 
        cargo 
        rustc 
        rust-analyzer 
        rustfmt 
      ];
      description = "Rust tools to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.rustTools ++ (with pkgs; [
      # Outils de développement
      gcc
      pkg-config
      openssl
      # Pour certains plugins Vim
      nodejs  # Nécessaire pour Copilot
      python3
    ]);

    programs.vim = {
      enable = true;
      
      plugins = with pkgs.vimPlugins; [
        # LSP et completion
        coc-nvim
        coc-rust-analyzer
        vim-lsp
        rust-vim
        ale
        
        # Navigation et code
        fzf-vim
        fzfWrapper
        ctrlp-vim
        nerdtree
        tagbar
        
        # Utilitaires
        vim-gitgutter
        vim-fugitive
        vim-commentary
        vim-surround
        vim-repeat
        
        # Thème et apparence
        vim-airline
        vim-airline-themes
        nord-vim

        # === COPILOT ===
        copilot-vim
      ];

      extraConfig = ''
        " === Configuration de base ===
        syntax enable
        filetype plugin indent on
        set number
        set relativenumber
        set expandtab
        set tabstop=4
        set shiftwidth=4
        set smartindent
        set cursorline
        
        " === Configuration Rust ===
        let g:rustfmt_autosave = 1
        let g:rust_clip_command = 'xclip -selection clipboard'
        
        " === Configuration ALE (Linting) ===
        let g:ale_linters = {
        \ 'rust': ['analyzer'],
        \}
        let g:ale_fixers = {
        \ 'rust': ['rustfmt'],
        \}
        let g:ale_fix_on_save = 1
        
        " === Configuration CoC (Completion) ===
        " Utiliser <tab> pour la completion
        inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
        
        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction
        
        " Utiliser <cr> pour confirmer la completion
        inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
        
        " Navigation
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)
        
        " Documentation avec K
        nnoremap <silent> K :call ShowDocumentation()<CR>
        
        function! ShowDocumentation()
          if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
          else
            call feedkeys('K', 'in')
          endif
        endfunction
        
        " === CONFIGURATION COPILOT ===
        " Activer Copilot
        let g:copilot_enabled = 1
        let g:copilot_filetypes = {
          \ 'rust': v:true,
          \ '*': v:true,
          \ }
        
        " Raccourcis Copilot
        imap <silent> <C-J> <Plug>(copilot-next)
        imap <silent> <C-K> <Plug>(copilot-previous)
        imap <silent> <C-L> <Plug>(copilot-suggest)
        imap <silent> <C-H> <Plug>(copilot-dismiss)
        
        " Accepter une suggestion avec Tab (quand Copilot est actif)
        function! CheckCopilotAndTab()
          if coc#pum#visible()
            return coc#pum#next(1)
          elseif copilot#Enabled() && copilot#Suggestions#Visible()
            return copilot#Accept()
          else
            return "\<Tab>"
          endif
        endfunction
        
        inoremap <silent> <expr> <Tab> CheckCopilotAndTab()

        " Définir le leader (espace est très accessible)
        let mapleader = " "
        let maplocalleader = " "
        
        " Maintenant <leader>cp devient : Espace + c + p
        " Ce qui est très facile à taper

        " Raccourci pour ouvrir le panel Copilot
        nnoremap <leader>cp :Copilot panel<CR>
        
        " === Raccourcis personnalisés ===
        " Rust-specific mappings
        autocmd FileType rust nmap <leader>c :Cargo check<CR>
        autocmd FileType rust nmap <leader>r :Cargo run<CR>
        autocmd FileType rust nmap <leader>t :Cargo test<CR>
        autocmd FileType rust nmap <leader>d :Cargo doc<CR>
        
        " Navigation entre les erreurs
        nmap <silent> [a <Plug>(coc-diagnostic-prev)
        nmap <silent> ]a <Plug>(coc-diagnostic-next)
        
        " === Configuration supplémentaire utilisateur ===
        ${cfg.extraVimConfig}
      '';
    };

    # Configuration pour les services CoC
    home.file.".config/coc-settings.json".text = builtins.toJSON {
      "languageserver" = {
        "rust" = {
          "command" = "rust-analyzer";
          "filetypes" = [ "rust" ];
          "rootPatterns" = [ "Cargo.toml" ];
        };
      };
    };
  };
}
