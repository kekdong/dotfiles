# Daily Configuration Study Plan

## 현재 환경 요약
- Nord 테마를 중심으로 `zsh`·`tmux`·`Neovim` 구성이 통일되어 있으며, `znap`과 `lazy.nvim`으로 경량 플러그인 관리를 수행 중.
- `pyenv`, `nvm`, `tmux`(TPM), Neovim 기본 플러그인(`gitsigns`, `fugitive`, `nvim-tree`)과 Powerlevel10k 프롬프트를 사용해 개발/머신러닝 워크플로를 구성.
- `~/Workspace/Deep_Pocket_of_Daedalus` 프로젝트는 PyTorch 2.8, FastAPI, CCXT 기반 트레이딩/모니터링 파이프라인으로 Python 가상환경 중심의 작업 패턴을 보여줌.

---

## Day 1 — Telekasten.nvim + Obsidian 베이스 노트 연동
- **설정 요약:** `lazy.nvim`에 `renerocksai/telekasten.nvim` 추가, `telekasten.nvim` vault 경로를 Obsidian vault(예: `~/Workspace/notes`)로 지정, 데일리/프로젝트 노트 템플릿 작성.
- **장점:** NVim과 Obsidian 간 양방향 노트 관리, 프로젝트별 링크 네비게이션, Zettelkasten 워크플로 확장.
- **Codex 메모:** `ripgrep`과 `fd`를 함께 설치하면 Telekasten 검색 속도가 크게 향상; Vault는 SSD 상주 디렉터리에 두고 Git으로 버전 관리 추천.

## Day 2 — fzf 기반 단축키 통합 (Zsh + Neovim)
- **설정 요약:** `fzf`와 `fzf-tab`을 `znap`으로 추가, Zsh에 `CTRL+T`, `CTRL+R` 키바인딩 설정; Neovim에는 `ibhagwan/fzf-lua` 혹은 `junegunn/fzf` + `telescope-fzf-native.nvim`을 `lazy.nvim`에 추가.
- **장점:** 대규모 리포지토리에서도 빠른 파일/커맨드/히스토리 탐색, `ripgrep`과 결합해 코드 검색 효율 상승.
- **Codex 메모:** Arch Linux에서는 `pacman -S fzf ripgrep fd`로 기본 바이너리 확보; GPU 리소스 소모 영향은 미미.

## Day 3 — thoughtbot 스타일 dotfiles 모듈화
- **설정 요약:** `~/.dotfiles` 내에 `zsh/`, `tmux/`, `nvim/` 하위 모듈을 명시적으로 분할하고, `install.sh`를 `script/bootstrap`·`script/install`·`script/update` 구조로 재편.
- **장점:** 설정 테스트/롤백이 명확해지고, 새 머신 프로비저닝 시 단계적 셋업 가능.
- **Codex 메모:** 현재 `install.sh`에 포함된 pyenv/nvm 부트스트랩 로직을 분리하면 CI나 서버 환경에서 부분 실행이 용이.

## Day 4 — Oh My Tmux 기능 채택
- **설정 요약:** `gpakosz/.tmux`에서 제공하는 상태바, 세션 복구 스크립트, 매크로 중 필요한 부분만 cherry-pick하여 `tmux.conf`에 반영.
- **장점:** 가시성 높은 상태바, 세션 자동 복원, 표준화된 키맵을 통해 원격/로컬 환경 전환이 쉬워짐.
- **Codex 메모:** 기존 Nord 테마 유지 위해 `status-left`, `status-right` 색상은 Nord 팔레트(#3B4252 등)로 맞춤 필요.

## Day 5 — CLI 필수 도구 세트 확장
- **설정 요약:** `bat`, `fd`, `lsd`, `exa`(선호 시), `zoxide`, `tldr` 등을 Arch 패키지로 설치하고 zsh alias/function으로 통합.
- **장점:** 기본 `ls`/`cat` 대비 시인성과 탐색 속도 향상, 대규모 코드베이스 추적 효율 개선.
- **Codex 메모:** GPU 연산 작업에 영향 없으며, 패키지 설치 후 `zshrc` alias 충돌 여부 확인.

## Day 6 — Git 워크플로 자동화 스크립트
- **설정 요약:** `scripts/` 디렉터리에 공통 Git 액션(예: 린트+테스트+커밋 템플릿)을 추가하고, Zsh alias로 연결.
- **장점:** ML 실험/리포트 커밋 시 휴먼 에러 감소, 표준화된 파이프라인 적용.
- **Codex 메모:** 현재 프로젝트의 `Makefile`·`scripts` 구조를 활용해 `pre-commit` 또는 `ruff --fix` 자동 실행 Hook 도입 고려.

## Day 7 — 시스템 모니터링 패널 (tmux + nvtop)
- **설정 요약:** `nvtop`, `bpytop` 등을 설치해 tmux pane에 GPU/CPU/메모리 모니터 패널을 구성.
- **장점:** RTX 5090 학습 시 실시간 리소스 확인, 프로세스 병목 파악 용이.
- **Codex 메모:** GPU가 32GB VRAM이므로 `nvtop` 3.x 이상에서 제공하는 per-process VRAM 뷰 활용; tmux pane 업데이트 주기를 2s 이상으로 설정해 과도한 refresh 방지.

## Day 8 — OSC52 기반 클립보드 통합 (Konsole + iTerm2)
- **설정 요약:** `tmux.conf`에 `set -g set-clipboard on`을 추가하고 `tmux-yank`가 OSC52 문자열을 전송하도록 설정. Neovim에는 `ojroques/nvim-osc52`를 `lazy.nvim`으로 추가해 `y`, `yy`, 비주얼 모드 `y` 동작이 자동으로 시스템 클립보드에 동기화되도록 구성. Konsole에서는 “설정 ▸ 일감 ▸ 텍스트 ▸ 애플리케이션이 클립보드 접근 허용”을 활성화하고, iTerm2는 기본 OSC52 허용 상태를 유지.
- **장점:** SSH/tmux/로컬 어디서든 동일한 복사·붙여넣기 경험 확보, 추가 바이너리 없이 Wayland/X11/macOS 간 호환, 기존 `tmux-yank` 플러그인과 자연스럽게 연동.
- **Codex 메모:** tmux 3.2 이상에서 동작이 가장 안정적. 원격 서버에서 `Accept OSC 52`가 차단된 경우 `tmux set-option -sa terminal-overrides ',*:clipboard'`로 예외 처리 가능하며, 필요 시 `OSC52` 길이 제한도 `set -ga terminal-overrides ',*:Ms=80'` 등으로 조정.

---

## 향후 확장 아이디어
- Arch용 `paru`/`yay` 스크립트 추가로 AUR 패키지 동기화 자동화.
- `chezmoi` 또는 `stow`를 활용한 dotfiles 버전관리를 실험하여 멀티머신 동기화 준비.
