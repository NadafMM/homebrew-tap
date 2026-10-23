class KubectlShell < Formula
  desc "Practice kubectl with Tab completion on a sample cluster"
  homepage "https://github.com/NadafMM/kubectl-shell"
  url "https://github.com/NadafMM/kubectl-shell/releases/download/v0.2.0/kubectl-shell-0.2.0.tar.gz"
  sha256 "a8d4460fcced5c180f4bbbf0b5bd91dd2e135557b9283238205e238025d16a0c"

  depends_on "node"

  def install
    libexec.install "cli/kube.cjs"
    (bin/"kube").write <<~SH
      #!/bin/bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/kube.cjs" "$@"
    SH
    chmod 0755, bin/"kube"

    node = Formula["node"].opt_bin/"node"
    script = libexec/"kube.cjs"
    bash_completion.mkpath
    fish_completion.mkpath
    zsh_completion.mkpath
    (bash_completion/"kube").write Utils.safe_popen_read(node, script, "completion", "bash")
    (fish_completion/"kube.fish").write Utils.safe_popen_read(node, script, "completion", "fish")
    (zsh_completion/"_kube").write <<~ZSH
      #compdef kube
      local -a vals
      vals=("${(@f)$(kube __complete --cursor "$CURSOR" --line "$BUFFER" 2>/dev/null)}")
      (( ${#vals} )) || return
      if (( ${#vals} == 1 )); then
        local suf=' '
        [[ ${vals[1]} == */ || ${vals[1]} == *= ]] && suf=''
        compadd -S "$suf" -Q -- "${vals[1]}"
      else
        compadd -Q -- "${vals[@]}"
      fi
    ZSH
  end

  test do
    assert_match "CrashLoopBackOff", shell_output("#{bin}/kube get pods")
  end
end
