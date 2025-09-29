# dotfiles

Nord 중심 테마로 정리한 개인용 Linux/macOS dotfiles.

## 구성 요소
- **tmux**: TPM과 `arcticicestudio/nord-tmux` 테마를 사용.
- **Neovim**: `lazy.nvim` 플러그인 매니저, `shaunsingh/nord.nvim`, `lualine.nvim` 등을 포함.
- **Zsh**: `zsh-snap` 기반 플러그인 로딩, Powerlevel10k 프롬프트(agnoster 스타일, Nord 팔레트).

## 선행 요구 사항
- `git`, `zsh`, `tmux`, `neovim`, `pyenv`
- Nerd Font 계열 폰트(프롬프트·상태바의 powerline 글리프용 권장)

## 설치
```bash
./install.sh
```
- 심볼릭 링크 생성만 수행합니다. 최초 실행 후 `zsh`를 다시 열고, 실행 중인 `tmux` 세션이 있다면 `tmux source-file ~/.tmux.conf`로 갱신하세요.
- Neovim은 첫 실행 시 `lazy.nvim`과 지정된 플러그인이 자동 부트스트랩됩니다.

## 참고
- macOS는 Homebrew(`/opt/homebrew`) 경로를 자동으로 앞에 둡니다.
- `pyenv`가 설치되어 있으면 로그인 시 초기화합니다.

## TODO
- tmux/nvim/zsh 설정 분기와 상태바 주기 업데이트 로직은 후속 리팩터링 시 재검토 예정.
