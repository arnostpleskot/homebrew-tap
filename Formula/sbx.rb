class Sbx < Formula
  desc "Build, run, and govern agents across the software development lifecycle"
  homepage "https://github.com/docker/sbx-releases"

  if Hardware::CPU.arm?
    url "https://github.com/docker/sbx-releases/releases/download/v0.38.0/DockerSandboxes-linux-arm64.tar.gz"
    sha256 "051fdf8349f8a66db47a990e11a30cd1d2e013ac6c8e42e48c072bfcec06a1d5"
  else
    url "https://github.com/docker/sbx-releases/releases/download/v0.38.0/DockerSandboxes-linux.tar.gz"
    sha256 "9ebcea831d4d270e25ae1777bf15e24756abfbf8791ad27294754682838ed00b"
  end

  depends_on "e2fsprogs"
  depends_on :linux

  def install
    bin.install "sbx"

    libexec.install "containerd-shim-nerdbox-v1"
    libexec.install "mkfs.erofs"
    libexec.install "containerd-shim-nerdbox-gpu-v1" if Hardware::CPU.intel?

    libexec.install Dir["nerdbox-kernel-*"]
    libexec.install Dir["nerdbox-rootfs-*.erofs"]
    (libexec/"lib").install "libsailor.so"

    share.install "apparmor-profile"

    generate_completions_from_executable(
      bin/"sbx",
      "completion",
    )
  end

  def caveats
    <<~EOS
      Docker Sandboxes requires access to KVM. Ensure your user can access /dev/kvm.

      GPU passthrough on x86_64 requires privileged one-time setup of the
      GPU trampoline:

        sudo #{opt_libexec}/containerd-shim-nerdbox-gpu-v1 install

      An AppArmor profile is bundled at:

        #{opt_share}/apparmor-profile

      Homebrew does not automatically install or activate the profile because
      doing so requires modifying /etc/apparmor.d with elevated privileges.

      On systems using AppArmor, install it manually if required:

        sudo install -m 0644 \
          #{opt_share}/apparmor-profile \
          /etc/apparmor.d/docker-sbx-nerdbox-shim

        sudo apparmor_parser -r -W \
          /etc/apparmor.d/docker-sbx-nerdbox-shim
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sbx --version")
    assert_path_exists libexec/"containerd-shim-nerdbox-v1"
    assert_path_exists libexec/"mkfs.erofs"
    assert_path_exists libexec/"lib/libsailor.so"

    if Hardware::CPU.intel?
      assert_path_exists libexec/"containerd-shim-nerdbox-gpu-v1"
      assert_path_exists libexec/"nerdbox-kernel-x86_64"
      assert_path_exists libexec/"nerdbox-rootfs-x86_64.erofs"
    end
  end
end
