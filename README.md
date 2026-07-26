# dotfiles

Solarized Osaka Dark 중심 테마로 정리한 개인용 Linux/macOS dotfiles.

## 구성 요소
- **WezTerm/tmux**: Solarized Osaka Dark 팔레트와 Nerd Font/ASCII 폴백을 사용.
- **Neovim**: `lazy.nvim` 플러그인 매니저(`lazy-lock.json`으로 버전 고정), `craftzdog/solarized-osaka.nvim`, `lualine.nvim` 등을 포함.
- **Zsh**: `zsh-snap` 기반 플러그인 로딩, Powerlevel10k 프롬프트(agnoster 스타일, Solarized Osaka 팔레트).
- **CLI**: `fzf`는 Solarized Osaka Dark 팔레트, `bat`은 내장 Solarized Dark 테마를 사용.

## 선행 요구 사항
- `git`, `zsh`, `tmux`, `neovim`, `tree-sitter-cli`
- Nerd Font 계열 폰트(프롬프트·상태바의 powerline 글리프용 권장)

## 설치
```bash
./install.sh
```

설치 스크립트는 심볼릭 링크 생성 외에 다음 부트스트랩도 수행합니다.

- **공통**: 설정 파일 심볼릭 링크(zsh, tmux, Neovim, WezTerm, bat, lazydocker, `~/.local/bin/tmux-fzf-open`), TPM(tmux plugin manager)·`zsh-snap`과 zsh 플러그인·`nvm` clone, Telekasten vault clone(`~/Workspace/Commonplace-Book`) 및 템플릿 동기화.
- **macOS**: Homebrew 설치(없을 경우), CLI 패키지 일괄 설치, `im-select`, Sarasa Term K Nerd Font cask 설치.
- **Arch Linux**: `PACMAN_AUTO_INSTALL=1` 설정 시 CLI 패키지 자동 설치, `AUR_AUTO_INSTALL=1` 설정 시 AUR로 WezTerm(`wezterm-git`) 설치. 미설정 시 안내만 출력.

최초 실행 후 `zsh`를 다시 열고, 실행 중인 `tmux` 세션이 있다면 `tmux source-file ~/.tmux.conf`로 갱신하세요. Neovim은 첫 실행 시 `lazy.nvim`이 `lazy-lock.json`에 고정된 커밋으로 플러그인을 설치합니다.

## 참고
- macOS는 Homebrew(`/opt/homebrew`) 경로를 자동으로 앞에 둡니다.
- `pyenv`는 기본 비활성입니다. 별도로 설치한 뒤 `ENABLE_PYENV=1`을 설정한 셸에서만 초기화됩니다(Python 도구는 `uv` 우선).
- zsh 플러그인은 셸 시작 시 네트워크에 접근하지 않습니다. 플러그인이 없으면 안내 메시지가 출력되며, `install.sh`를 실행해 부트스트랩하세요.

## TODO
- tmux/nvim/zsh 설정 분기와 상태바 주기 업데이트 로직은 후속 리팩터링 시 재검토 예정.
