class Sbx < Formula
  desc "Build, run, and govern agents across the software development lifecycle"
  homepage "https://github.com/docker/sbx-releases"
  url "https://github.com/docker/sbx-releases/releases/download/v0.49.2/DockerSandboxes-linux.tar.gz"
  sha256 "a3f363998cd9f6caa7b02323a5d671987a9887a278fb888aca20fa9f80851e87"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  depends_on "e2fsprogs"
  depends_on :linux

  resource "sbx-arm64" do
    url "https://github.com/docker/sbx-releases/releases/download/v0.49.2/DockerSandboxes-linux-arm64.tar.gz"
    sha256 "53c5250c480b8ef671d89413d824af62e08575c3b0051570dc5efa9f48a94eb6"

    livecheck do
      formula :parent
    end
  end

  def install
    if Hardware::CPU.arm?
      resource("sbx-arm64").stage { install_runtime }
    else
      install_runtime
    end

    generate_completions_from_executable bin/"sbx", "completion"
  end

  def install_runtime
    bin.install "sbx"

    libexec.install "containerd-shim-nerdbox-v1"
    libexec.install "mkfs.erofs"
    libexec.install "containerd-shim-nerdbox-gpu-v1" if Hardware::CPU.intel?

    libexec.install Dir["nerdbox-kernel-*"]
    libexec.install Dir["nerdbox-rootfs-*.erofs"]
    (libexec/"lib").install "libsailor.so"

    share.install "apparmor-profile"
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
