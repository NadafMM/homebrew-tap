class KubectlShell < Formula
  desc "kubectl shell with live Tab completion and a terminal resource view"
  homepage "https://github.com/NadafMM/kubectl-shell"
  url "https://github.com/NadafMM/kubectl-shell/releases/download/v0.5.1/kubectl-shell-0.5.1.tar.gz"
  sha256 "4189b6d4472d4a14ea8fcf9a82d6d7ed0dd11f532b6e2bdb910f128c415044cd"
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
