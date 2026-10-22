class KubectlShell < Formula
  desc "Practice kubectl with Tab completion on a sample cluster"
  homepage "https://github.com/NadafMM/kubectl-shell"
  url "https://github.com/NadafMM/kubectl-shell/releases/download/v0.1.0/kubectl-shell-0.1.0.tar.gz"
  sha256 "925ecb16ce2e1379b47da2afb79a05fd70eea9bfe3bdba4e76ba3562cbd4fcae"

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
