<!-- markdownlint-disable MD033 -->

# apt-cacher-ng

<!-- CI Badges -->

[![build](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/build.yml/badge.svg)](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/build.yml)
[![release](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/release.yml/badge.svg)](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/release.yml)
[![security](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/security.yml/badge.svg)](https://github.com/tprasadtp/apt-cacher-ng-docker/actions/workflows/security.yml)
[![releases](https://img.shields.io/github/v/tag/tprasadtp/apt-cacher-ng-docker?label=version&sort=semver&logo=semver&color=7f50a6&labelColor=3a3a3a)](https://github.com/tprasadtp/apt-cacher-ng-docker/releases/latest)
[![license](https://img.shields.io/github/license/tprasadtp/apt-cacher-ng-docker?logo=github&labelColor=3A3A3A)](https://github.com/tprasadtp/apt-cacher-ng-docker/blob/master/LICENSE)

## Docker Images

Images are published on [GitHub Container Registry][ghcr].

[ghcr]: https://ghcr.io/tprasadtp/apt-cacher-ng
[releases]: https://github.com/tprasadtp/apt-cacher-ng-docker/releases/latest

## Usage

## docker-compose

Run the stack in background. By default the compose stack uses subnet `10.222.222.0/24`
change it if you have conflicts.

1. Get compose file
    ```console
    curl -sSFL -o apt-cacher-ng.yml https://raw.githubusercontent.com/tprasadtp/apt-cacher-ng-docker/master/docker-compose.yml
    ```
1. Run the stack in background
    ```console
    docker-compose -p apt-cacher-ng -f apt-cacher-ng.yml up -d
    ```

## APT configuration

These configuration spinnets assume that you are using the compose file provided.
Please change IP address/host of your apt-cacher-ng accordingly.

**Do not forget to remove added proxy configuration file in your cleanup steps.**

- For packer builds,

  1. Add proxy configuration before any apt commands are executed

      ```hcl
        provisioner "shell" {
          inline = [
            "printf 'Acquire::HTTP::Proxy \"http://10.222.222.222:3142\";\nAcquire::HTTPS::Proxy \"false\";' > /etc/apt/apt.conf.d/01-buildtime-proxy",
          ]
        }
      ```

  1. Cleanup apt proxy configuration after you are done with all provisioning steps. This is **critical** to avoid having broken apt on built images.

      ```hcl
        # This removes caching proxy confgurations used. during buildtime.
        # Please do not remove this, unless you know what your are doing.
        provisioner "shell" {
          inline = [
            "[[ -e /etc/apt/apt.conf.d/01-buildtime-proxy ]] && rm /etc/apt/apt.conf.d/01-buildtime-proxy",
          ]
        }
      ```
  Do note however this requires the packer instance to have has access to apt-cacher-ng running at, `http://10.222.222.222:3142`. This is mostly the case for chroot, docker and qemu builders running on the same host.

- For Vagrant insert snippet below in your ```Vagrant.configure``` block before you invoke any apt commands.

  ```ruby
    $apt_proxy = <<-SCRIPT
    printf "Acquire::HTTP::Proxy \"http://10.222.222.222:3142\";\nAcquire::HTTPS::Proxy \"false\";" > /etc/apt/apt.conf.d/01-buildtime-proxy"
    SCRIPT
    # Run this before any other provisioners which access apt
    config.vm.provision "shell", inline: $apt_proxy
  ```

- [pi-gen](https://github.com/RPi-Distro/pi-gen) suport is baked in and it takes care of adding and removing apt proxy automagically. Just set your IP in config file,
  ```sh
  echo 'APT_PROXY=http://10.222.222.222:3142' >> config
  ```
