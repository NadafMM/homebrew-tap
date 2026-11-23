class KubectlShell < Formula
  desc "kubectl shell with live Tab completion and a terminal resource view"
  homepage "https://github.com/NadafMM/kubectl-shell"
  url "https://github.com/NadafMM/kubectl-shell/releases/download/v0.5.0/kubectl-shell-0.5.0.tar.gz"
  sha256 "c880b8613ac4794e5e15b219e0570448b61d2b0f27e9366333bce8b199db2ffe"
  license "MIT"

  depends_on "node"

  def install
    libexec.install "cli/kube.cjs"
    (bin/"kube").write <<~SH
      #!/bin/bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/kube.cjs" "$@"
    SH
    chmod 0755, bin/"kube"
    generate_completions_from_executable(bin/"kube", "completion", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kube --version")
  end
end
